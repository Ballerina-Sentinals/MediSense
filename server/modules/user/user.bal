import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;

public type Patient record {
    int id;
    string name;
    string dob;
    string nic;
    int? doctor_id;
    int? caretaker_id;
};

 public type Doctor record {
    int id;
    string name;
    string dob;
    string? nic;
    string? doctor_lisence;

};

public type care_taker record {
    int id;
    string name;
    string dob;
    string nic;
};


public function createErrorResponse(int statusCode, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setJsonPayload({"error": message});
    return response;
}


public function  patient_info(http:Request req,int user_id,mysql:Client dbClient) returns Patient|http:Response|error? {
        // Prepare the query
    sql:ParameterizedQuery query = `SELECT id, name, dob, nic, doctor_id, caretaker_id FROM patients WHERE id = ${user_id}`;

    Patient|error? resultStream = dbClient->queryRow(query);

        // Create the response
    http:Response response = new;

    if resultStream is sql:Error {
        io:println("Error occurred while executing the query: ", resultStream.toString());
        return createErrorResponse(500, "Internal server error");
    } else if resultStream is error {
        // Handle other possible errors
        io:println("An error occurred: ", resultStream.toString());
        return createErrorResponse(500, "An error occurred");
    } else if resultStream is () {
            // Handle case where no patient is found
        return createErrorResponse(404, "Patient not found");
    }
    io:println(resultStream);
        // Return a successful response with patient info
    response.statusCode = 200;

    return resultStream;
}

public function  doctor_info(int user_id,http:Request req,mysql:Client dbClient) returns http:Response|Doctor|error? {
        // Prepare the query
    sql:ParameterizedQuery query = `SELECT * FROM doctors WHERE id = ${user_id}`;

        //Execute the query and fetch the results
    Doctor|error? resultStream1 = dbClient->queryRow(query);

        // Create the response
    http:Response response = new;

    if resultStream1 is sql:Error {
            // Handle SQL error
        io:println("Error occurred while executing the query: ", resultStream1.toString());
        return createErrorResponse(500, "Internal server error");
    } else if resultStream1 is error {
            // Handle other possible errors
        io:println("An error occurred: ", resultStream1.toString());
        return createErrorResponse(500, "An error occurred");
    } else if resultStream1 is () {
            // Handle case where no doctor is found
        return createErrorResponse(404, "Doctor not found");
    }

        // Return a successful response with doctor info
    response.statusCode = 200;
    return resultStream1;
}

public function  care_taker_info(int user_id,http:Request req,mysql:Client dbClient) returns http:Response|care_taker|error? {
        // Prepare the query
    sql:ParameterizedQuery query = `SELECT id, name, dob, nic FROM caretakers WHERE id = ${user_id}`;

        // Execute the query and fetch the results
    care_taker|error? resultStream1 = dbClient->queryRow(query);

        // Create the response
    http:Response response = new;

    if resultStream1 is sql:Error {
            // Handle SQL error
        io:println("Error occurred while executing the query: ", resultStream1.toString());
        return createErrorResponse(500, "Internal server error");
    } else if resultStream1 is error {
        // Handle other possible errors
        io:println("An error occurred: ", resultStream1.toString());
        return createErrorResponse(500, "An error occurred");
    } else if resultStream1 is () {
            // Handle case where no caretaker is found
        return createErrorResponse(404, "Caretaker not found");
    }

        // Return a successful response with caretaker info
    response.statusCode = 200;
    return resultStream1;
}




import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;

public type Patient record {
    int patient_id;
    int user_id;
    string name;
    string dob;
    string nic;
    int doctor_id ;
    int emergency_contact ;
    decimal weight ;
    decimal height ;
    string allergies ;
};

 public type Doctor record {
    int doctor_id;
    int user_id;
    string name;
    string nic;
    string doctor_license ;
    string description;
};

public type Pharmacy record {
    int pharm_id ;
    int user_id ;
    string name ;
    string district ;
    string town ;
    string street ;
    string con_number ;
    decimal rating ;
};


# Description.
#
# + statusCode - parameter description  
# + message - parameter description
# + return - return value description
public function createErrorResponse(int statusCode, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setJsonPayload({"error": message});
    return response;
}


public function  patient_info(http:Request req,int user_id,mysql:Client dbClient) returns Patient|error?|http:Response {
        // Prepare the query
    sql:ParameterizedQuery query = `SELECT * FROM patients WHERE id = ${user_id}`;

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

public function  doctor_info(http:Request req,int user_id,mysql:Client dbClient) returns http:Response|Doctor|error? {
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

public function  pharmacy_info(http:Request req,int user_id,mysql:Client dbClient) returns http:Response|Pharmacy|error? {
        // Prepare the query
    sql:ParameterizedQuery query = `SELECT * FROM pharmacies WHERE id = ${user_id}`;

        // Execute the query and fetch the results
    Pharmacy|error? resultStream1 = dbClient->queryRow(query);

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
        return createErrorResponse(404, "Pharmacy not found");
    }

        // Return a successful response with caretaker info
    response.statusCode = 200;
    return resultStream1;
}


public function patient_reg(http:Request req,Patient new_patient,mysql:Client dbClient) returns sql:Error|http:Response {
        // Prepare the query
    sql:ParameterizedQuery query = `INSERT INTO patients (user_id, name, dob, nic, doctor_id, emergency_contact, weight, height, allergies)
VALUES (${new_patient.patient_id}, ${new_patient.name}, ${new_patient.dob}, ${new_patient.nic}, ${new_patient.doctor_id}, ${new_patient.emergency_contact},${new_patient.weight},${new_patient.height},${new_patient.allergies});`;
    sql:ExecutionResult|sql:Error resultStream1  = dbClient->execute(query);
        // Create the response
    http:Response response = new;

    if resultStream1 is sql:Error {
            // Handle SQL error
        io:println("Error occurred while executing the query: ", resultStream1.toString());
        return createErrorResponse(500, "Internal server error");
        // Return a successful response with caretaker info
    
    }
    response.statusCode = 200;
    response.setJsonPayload({status:"Registered Successfully"});
    return response;
}







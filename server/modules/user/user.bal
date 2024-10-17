import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerina/time;


public type Patient record {
    int user_id;
    string name;
    time:Civil dob;
    string nic;
    int doctor_id ;
    int emergency_contact ;
    decimal weight ;
    decimal height ;
    string allergies ;
};

 public type Doctor record {
    int user_id;
    string name;
    string nic;
    string doctor_license ;
    string description;
};

public type Pharmacy record {
    int user_id ;
    string name ;
    string district ;
    string town ;
    string street ;
    string con_number ;
    decimal rating ;
};


public type Patient_view record {
    int patient_id;
    int user_id;
    string name;
    time:Civil dob;
    string nic;
    int doctor_id ;
    int emergency_contact ;
    decimal weight ;
    decimal height ;
    string allergies ;
};

 public type Doctor_view record {
    int doctor_id;
    int user_id;
    string name;
    string nic;
    string doctor_license ;
    string description;
};

public type Pharmacy_view record {
    int pharm_id;
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


public function  patient_info(int user_id,mysql:Client dbClient) returns Patient_view|error?|http:Response {
        // Prepare the query
    sql:ParameterizedQuery query = `SELECT * FROM patients WHERE id = ${user_id}`;

    Patient_view|error? resultStream = dbClient->queryRow(query);

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

public function  doctor_info(int user_id,mysql:Client dbClient) returns http:Response|Doctor_view|error? {
        // Prepare the query
    sql:ParameterizedQuery query = `SELECT * FROM doctors WHERE id = ${user_id}`;

        //Execute the query and fetch the results
    Doctor_view|error? resultStream1 = dbClient->queryRow(query);

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

public function  pharmacy_info(int user_id,mysql:Client dbClient) returns http:Response|Pharmacy_view|error? {
        // Prepare the query
    sql:ParameterizedQuery query = `SELECT * FROM pharmacies WHERE id = ${user_id}`;

        // Execute the query and fetch the results
    Pharmacy_view|error? resultStream1 = dbClient->queryRow(query);

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


public function patient_reg(Patient new_patient,mysql:Client dbClient) returns sql:Error|http:Response {

        // Prepare the query
    sql:ParameterizedQuery query = `update patients set dob=${new_patient.dob}, nic=${new_patient.nic}, doctor_id=${new_patient.doctor_id}, emergency_contact=${new_patient.emergency_contact}, weight=${new_patient.weight}, height=${new_patient.height}, allergies=${new_patient.allergies} where user_id = ${new_patient.user_id};`;
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

public function doctor_reg(Doctor new_doc,mysql:Client dbClient) returns sql:Error|http:Response {
        // Prepare the query
    sql:ParameterizedQuery query = `update doctors set nic = ${new_doc.nic}, doctor_license= ${new_doc.doctor_license}, description=${new_doc.description};`;
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



public function pharmacy_reg(Pharmacy new_phar,mysql:Client dbClient) returns sql:Error|http:Response {
        // Prepare the query
    sql:ParameterizedQuery query = `update pharacies set district= ${new_phar.district}, town= ${new_phar.town},street=${new_phar.street},con_number=${new_phar.con_number}, rating=${new_phar.rating});`;
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









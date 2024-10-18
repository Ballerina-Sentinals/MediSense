import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;

public type appoinment record {|
    readonly int appoinment_id;
    int patient_id;
    int doctor_id;
    int number;
    string date;
    string created_date;
    string status;
|};

public type orders record {|
    int patient_id;
    int pharm_id;

|};

public function createErrorResponse(int statusCode, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setJsonPayload({"error": message});
    return response;
}

public function create_appoinment(appoinment app_1, mysql:Client dbClient) returns http:Response|error {
    sql:ParameterizedQuery counter = `select count(*) where doctor_id=${app_1.doctor_id} and date = ${app_1.date};`;
    int number_ = check dbClient->queryRow(counter);
    sql:ParameterizedQuery query = `Insert into appoinments(patient_id,doctor_id,number,date,status) values (${app_1.patient_id},${app_1.doctor_id},${number_ + 1},${app_1.date},${app_1.status});`;
    sql:ExecutionResult|error result = dbClient->execute(query);
    http:Response response = new;

    if result is sql:Error {
        // Handle SQL error
        io:println("Error occurred while executing the query: ", result.toString());
        return createErrorResponse(500, "Internal server error");
        // Return a successful response with caretaker info

    }
    response.statusCode = 200;
    response.setJsonPayload({status: "Appoinment  Successfully"});
    return response;

}

public function view_all(int user_id, string date, mysql:Client dbClient) returns table<appoinment> key(appoinment_id)|error {
    sql:ParameterizedQuery query1 = `select doctor_id from doctors where user_id = ${user_id};`;
    int doctor_id = check dbClient->queryRow(query1);
    io:println(doctor_id);

    sql:ParameterizedQuery query = `select * from appoinments where doctor_id  = ${doctor_id} and date =${date};`;
    stream<appoinment, sql:Error?> result = dbClient->query(query);

    table<appoinment> key(appoinment_id) appoinments = table [];
    error? e = result.forEach(function(appoinment app) {
        appoinments.put(app);
    });

    if (e is error) {
        return e; // Return the error if something goes wrong.
    }

    return appoinments;

}

public function complete_appo(int appoinment_id, mysql:Client dbClient) returns http:Response|sql:Error {
    sql:ParameterizedQuery query = `update appoinments set status = "Done" where appoinment_id = ${appoinment_id};`;
    sql:ExecutionResult|sql:Error result = dbClient->execute(query);
    http:Response response = new;
    if result is sql:Error {
        // Handle SQL error
        io:println("Error occurred while inserting the user: ", result.toString());
        return createErrorResponse(500, "Internal server error");
    } else {
        // Return success response
        response.statusCode = 201; // 201 Created
        response.setJsonPayload({status: "Apoinment done"});
        return response;
    }

}

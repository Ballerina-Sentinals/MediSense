import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;

public type appointment record {|
    readonly int appointment_id;
    int patient_id;
    int doctor_id;
    int number;
    string date;
    string created_date;
    string status;
|};

public type view_p record {|
    readonly int appointment_id;
    string name;
    int number;
    int doctor_id;
    string date;
    string status;
|};

public type view_appo record {|
    readonly int appointment_id;
    int patient_id;
    int number;
    string doc_name;
    string date;
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

public function create_appointment(appointment app_1, mysql:Client dbClient) returns http:Response|error {
    sql:ParameterizedQuery counter = `select count(*) where doctor_id=${app_1.doctor_id} and date = ${app_1.date};`;
    int number_ = check dbClient->queryRow(counter);
    sql:ParameterizedQuery query = `Insert into appointments(patient_id,doctor_id,number,date,status) values (${app_1.patient_id},${app_1.doctor_id},${number_ + 1},${app_1.date},${app_1.status});`;
    sql:ExecutionResult|error result = dbClient->execute(query);
    http:Response response = new;

    if result is sql:Error {
        // Handle SQL error
        io:println("Error occurred while executing the query: ", result.toString());
        return createErrorResponse(500, "Internal server error");
        // Return a successful response with caretaker info

    }
    response.statusCode = 200;
    response.setJsonPayload({status: "appointment  Successfully"});
    return response;

}

public function view_all(int user_id, string date, mysql:Client dbClient) returns table<view_p> key(appointment_id)|error {
    sql:ParameterizedQuery query1 = `select doctor_id from doctors where user_id = ${user_id};`;
    int doctor_id = check dbClient->queryRow(query1);

    sql:ParameterizedQuery query = `select * from all_p where doctor_id  = ${doctor_id} and date =${date};`;
    stream<view_p, sql:Error?> result = dbClient->query(query);

    table<view_p> key(appointment_id) appoinments = table [];
    error? e = result.forEach(function(view_p app) {
        appoinments.put(app);
    });

    if (e is error) {
        return e; // Return the error if something goes wrong.
    }

    return appoinments;

}

public function complete_appo(int appointment_id, mysql:Client dbClient) returns http:Response|sql:Error {
    sql:ParameterizedQuery query = `update appointments set status = "Done" where appointment_id = ${appointment_id};`;
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

public function view_all_booked(int user_id, string date, mysql:Client dbClient) returns table<view_p> key(appointment_id)|error {
    sql:ParameterizedQuery query1 = `select doctor_id from doctors where user_id = ${user_id};`;
    int doctor_id = check dbClient->queryRow(query1);

    sql:ParameterizedQuery query = `select * from all_p where doctor_id  = ${doctor_id} and date =${date} and status ='booked';`;
    stream<view_p, sql:Error?> result = dbClient->query(query);

    table<view_p> key(appointment_id) appoinments = table [];
    error? e = result.forEach(function(view_p app) {
        appoinments.put(app);
    });

    if (e is error) {
        return e; // Return the error if something goes wrong.
    }

    return appoinments;

}

public function view_patient_appo(int user_id, string date, sql:Client dbClient) returns error|table<view_appo> key(appointment_id) {
    sql:ParameterizedQuery query1 = `select patient_id from patients where user_id = ${user_id};`;
    int patient_id = check dbClient->queryRow(query1);
    io:print(patient_id);
    sql:ParameterizedQuery query = `select * from appointments_p where patient_id = ${patient_id} and date = ${date};`;
    stream<view_appo, sql:Error?> result = dbClient->query(query);

    table<view_appo> key(appointment_id) appoinments = table [];
    error? e = result.forEach(function(view_appo app) {
        appoinments.put(app);
    });

    if (e is error) {
        return e; // Return the error if something goes wrong.
    }

    return appoinments;
}

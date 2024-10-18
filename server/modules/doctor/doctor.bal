import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;

public type form_availibity record {|
    int doctor_id;
    string date;
    string start_time;
    string end_time;
    string availibility;
|};

public function createErrorResponse(int statusCode, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setJsonPayload({"error": message});
    return response;
}

public function set_availibility(form_availibity new_form, mysql:Client dbClient) returns http:Response|error {
    sql:ParameterizedQuery query = `insert into availibility(doctor_id,date,start_time,end_time,availibility) values(${new_form.doctor_id},${new_form.date}.${new_form.start_time},${new_form.end_time},${new_form.availibility});`;
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

public function check_availibility(string date, int doctor_id, mysql:Client dbClient) returns http:Response|error {
    sql:ParameterizedQuery query = `select time from availibility where date = ${date} and doctor_id =${doctor_id};`;
    string result = check dbClient->queryRow(query);
    http:Response response = new;
    response.setJsonPayload({time: result});
    return response;

}

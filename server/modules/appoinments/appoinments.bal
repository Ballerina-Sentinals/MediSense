import ballerina/http;
import ballerina/time;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/io;




public type appoinment record {|
    int? appoinment_id;
    int patient_id;
    int doctor_id;
    int number;
    time:Civil date;
    string status;
|};
public function createErrorResponse(int statusCode, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setJsonPayload({"error": message});
    return response;
}

public function create_appoinment(appoinment app_1,mysql:Client dbClient) returns http:Response|error{
    sql:ParameterizedQuery query = `Insert into appoinments(patient_id,doctor_id,number,date,status) values (${app_1.patient_id},${app_1.doctor_id},${app_1.number},${app_1.date},${app_1.status});`;
    sql:ExecutionResult|error result = dbClient->queryRow(query); 
    http:Response response = new;

    if result is sql:Error {
            // Handle SQL error
        io:println("Error occurred while executing the query: ", result.toString());
        return createErrorResponse(500, "Internal server error");
        // Return a successful response with caretaker info
    
    }
    response.statusCode = 200;
    response.setJsonPayload({status:"Appoinment  Successfully"});
    return response;


}
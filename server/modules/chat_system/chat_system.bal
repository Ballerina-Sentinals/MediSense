import ballerina/sql;
import ballerina/http;
import ballerina/io;


# Description.
#
# + prescript_id - field description  
# + sender_user_id - field description  
# + receiver_user_id - field description  
# + pill_1 - field description  
# + pill_2 - field description  
# + pill_3 - field description  
# + pill_4 - field description  
# + pill_5 - field description
public type Prescript record {|
    int prescript_id;
    int sender_user_id;
    int receiver_user_id;
    string? pill_1;
    string? pill_2;
    string? pill_3;
    string? pill_4;
    string? pill_5;

|};


public function createErrorResponse(int statusCode, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setJsonPayload({"error": message});
    return response;
}

public function prescription_creater(Prescript new_prep,sql:Client dbClient) returns http:Response|sql:Error{
    sql:ParameterizedQuery query = `INSERT INTO prescriptions(sender_user_id,receiver_user_id,pill_1,pill_2,pill_3,pill_4,pill_5) values (${new_prep.sender_user_id},${new_prep.receiver_user_id},${new_prep.pill_1},${new_prep.pill_2},${new_prep.pill_3},${new_prep.pill_4},${new_prep.pill_5});`;
    sql:ExecutionResult|sql:Error resultStream1  = dbClient->execute(query);

    http:Response response = new;
    if resultStream1 is sql:Error {
            // Handle SQL error
        io:println("Error occurred while executing the query: ", resultStream1.toString());
        return createErrorResponse(500, "Internal server error");
        // Return a successful response with caretaker info
    
    }
    response.statusCode = 200;
    response.setJsonPayload({status:"Prescription Created Successfully!"});
    return response;
}


public function prescription_deleter(int prescript_id,sql:Client dbClient) returns http:Response|sql:Error{
    sql:ParameterizedQuery query = `DELETE FROM prescriptions WHERE prescription_id = ${prescript_id};`;
    sql:ExecutionResult|sql:Error resultStream1  = dbClient->execute(query);

    http:Response response = new;
    if resultStream1 is sql:Error {
            // Handle SQL error
        io:println("Error occurred while executing the query: ", resultStream1.toString());
        return createErrorResponse(500, "Internal server error");
        // Return a successful response with caretaker info
    
    }
    response.statusCode = 200;
    response.setJsonPayload({status:"Prescription deleted Successfully!"});
    return response;
}

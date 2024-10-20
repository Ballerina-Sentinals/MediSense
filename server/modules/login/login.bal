import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;

type User record {|
    int user_id;

|};

public type usersignup record {|
    string username;
    string password;
    string email;
    string role;
|};

public function createErrorResponse(int statusCode, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setJsonPayload({"error": message});
    return response;
}

public function login(http:Request req, mysql:Client dbClient) returns http:Response|error {
    // Fetch and validate the JSON payload
    json|error payload = req.getJsonPayload();
    if payload is error {
        return createErrorResponse(400, "Invalid JSON payload");
    }
    io:println(payload);

    string email = (check payload.email).toString();
    string password = (check payload.password).toString();

    sql:ParameterizedQuery query = `SELECT password FROM user WHERE email = ${email}`;

    string|error? resultStream = dbClient->queryRow(query);

    if resultStream is sql:Error {
        // Handle SQL errors if any
        io:println("Error occurred while executing the query: ", resultStream.toString());
        return createErrorResponse(500, "Internal server error");
    } else if resultStream is () {
        // Handle case where no user is found
        return createErrorResponse(404, "Email not found");
    }

    string|error? storedPassword = resultStream;
    if storedPassword != password {
        return createErrorResponse(401, "Invalid credentials");
    }
    sql:ParameterizedQuery query1 = `SELECT user.id FROM user WHERE email = ${email}`;
    sql:ParameterizedQuery query2 = `SELECT user.role FROM user WHERE email = ${email}`;

    int|error? resultStream1 = dbClient->queryRow(query1);
    string|error? resultStream2 = dbClient->queryRow(query2);

    if resultStream1 is sql:Error {
        io:println("Error occurred while fetching user details: ", resultStream1.toString());
        return createErrorResponse(500, "Internal server error");
    }
    if resultStream2 is sql:Error {
        io:println("Error occurred while fetching user details: ", resultStream2.toString());
        return createErrorResponse(500, "Internal server error");
    }

    io:println(resultStream1);
    io:println(resultStream2);
    // Create a successful response
    http:Response response = new;
    response.statusCode = 200;
    response.setJsonPayload({status: "Login successful", user: {userId: check resultStream1, email: email, role: check resultStream2}});
    io:println(response.statusCode);
    io:println(response.getJsonPayload());
    return response;
}

public function signup(usersignup user, mysql:Client dbClient) returns http:Response|error {
    // Prepare the SQL query
    sql:ParameterizedQuery query = `INSERT INTO user (username, password, email, role) 
                                    VALUES (${user.username}, ${user.password}, ${user.email}, ${user.role})`;

    // Execute the query
    sql:ExecutionResult|sql:Error result = dbClient->execute(query);

    // Create the response
    http:Response response = new;
    sql:ParameterizedQuery query1 = `select id from user where username = ${user.username};`;

    int|error id = dbClient->queryRow(query1);

    if result is sql:Error {
        // Handle SQL error
        io:println("Error occurred while inserting the user: ", result.toString());
        return createErrorResponse(500, "Internal server error");
    } else {
        // Return success response
        response.statusCode = 201; // 201 Created
        response.setJsonPayload({status: "Signup successful", user: {id: check id, email: user.email, role: user.role}});
        return response;
    }
}


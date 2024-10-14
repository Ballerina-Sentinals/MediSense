import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerina/io;

// MySQL Database configuration
configurable string dbUser = "root";
configurable string dbPassword = "password";
configurable string dbHost = "localhost";
configurable int dbPort = 3306;
configurable string dbName = "Ballerina";


public function createErrorResponse(int statusCode, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setJsonPayload({"error": message});
    return response;
}

type User record {|
    int user_id;
    
|};

type Patient record {
    int id;
    string name;
    string dob;
    string nic;
    int? doctor_id;
    int? caretaker_id;
};


type Doctor record{
    int id;
    string name;
    string dob;
    string? nic;
    string? doctor_lisence;

};

type care_taker record{
    int id;
    string name;
    string dob;
    string nic;
};

type user_signup record {|
    string username;
    string password;
    string email;
    string role;
|};

// Initialize MySQL client
mysql:Client dbClient = check new (host = dbHost, port = dbPort, user = dbUser, password = dbPassword, database = dbName);

// Define HTTP listener
listener http:Listener loginListener = new (8080);

// Define service
service /user on loginListener {


   resource function post login(http:Request req) returns http:Response|error {
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

        int|error? resultStream1 = dbClient->queryRow(query1);

        if resultStream1 is sql:Error {
            io:println("Error occurred while fetching user details: ", resultStream1.toString());
            return createErrorResponse(500, "Internal server error");
        }
     
        io:println(resultStream1);
        // Create a successful response
        http:Response response = new;
        response.statusCode = 200;
        response.setJsonPayload({status: "Login successful", user: {userId: check resultStream1, email: email}});
        io:println(response.statusCode);
        io:println(response.getJsonPayload());
        return response;
    }


    

    resource function get get_patient_info/[int user_id](http:Request req) returns Patient|http:Response|error? {
        // Prepare the query
        sql:ParameterizedQuery query = `SELECT id, name, dob, nic, doctor_id, caretaker_id FROM patients WHERE id = ${user_id}`;

        // Execute the query and fetch the results
        Patient|error? resultStream = dbClient->queryRow(query);

        // Create the response
        http:Response response = new;

        if resultStream is sql:Error {
            // Handle SQL error
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
        response.statusCode =  200;
        
        return resultStream;
    }


   resource function get get_doctor_info/[int user_id](http:Request req) returns http:Response|Doctor|error? {
    // Prepare the query
        sql:ParameterizedQuery query = `SELECT * FROM doctors WHERE id = ${user_id}`;

    // Execute the query and fetch the results
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

    resource function get get_care_taker_info/[int user_id](http:Request req) returns http:Response|care_taker|error? {
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



   resource function post signup(user_signup user, http:Request req) returns http:Response|error {
    // Prepare the SQL query
    sql:ParameterizedQuery query = `INSERT INTO user (username, password, email, role) 
                                    VALUES (${user.username}, ${user.password}, ${user.email}, ${user.role})`;

    // Execute the query
    sql:ExecutionResult|sql:Error result = dbClient->execute(query);

    // Create the response
    http:Response response = new;

    if result is sql:Error {
        // Handle SQL error
        io:println("Error occurred while inserting the user: ", result.toString());
        return createErrorResponse(500, "Internal server error");
    } else {
        // Return success response
        response.statusCode = 201; // 201 Created
        response.setJsonPayload({status: "User registered successfully"});
        return response;
    }
}
}





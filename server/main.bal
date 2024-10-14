import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;

// MySQL Database configuration
configurable string dbUser = "root";
configurable string dbPassword = "2003";
configurable string dbHost = "localhost";
configurable int dbPort = 3306;
configurable string dbName = "medisense";

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

type Doctor record {
    int id;
    string name;
    string dob;
    string? nic;
    string? doctor_lisence;

};

type care_taker record {
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

// Function to test database connection
function testDbConnection() returns error? {
    mysql:Client dbClient = check new (host = dbHost, port = dbPort, user = dbUser, password = dbPassword, database = dbName);
    check dbClient.close();
    return;
}

// Main function to initialize the service
public function main() {
    error? result = testDbConnection();
    if (result is error) {
        io:println("Failed to connect to the database: ", result.toString());
    } else {
        io:println("Successfully connected to the database.");
    }
}

public function createErrorResponse(int statusCode, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setJsonPayload({"error": message});
    return response;
}

// Define service
service /user on loginListener {
    resource function post login(http:Request req) returns http:Response|error {
        // Fetch and validate the JSON payload
        json|error payload = req.getJsonPayload();

        if payload is error {
            return createErrorResponse(400, "Invalid JSON payload");
        }
        io:println(payload);

        // Extract the username and password from the payload
        string email = (check payload.email).toString();
        string password = (check payload.password).toString();

        // Prepare the query to fetch the stored password for the given username
        sql:ParameterizedQuery query = `SELECT password FROM user WHERE email = ${email}`;

        // Execute the query and fetch the result
        string|error? resultStream = dbClient->queryRow(query);

        if resultStream is sql:Error {
            // Handle SQL errors if any
            io:println("Error occurred while executing the query: ", resultStream.toString());
            return createErrorResponse(500, "Internal server error");
        } else if resultStream is () {
            // Handle case where no user is found
            return createErrorResponse(404, "Email not found");
        }

        // Extract the stored password
        string|error? storedPassword = resultStream;

        // Check if the stored password matches the provided password
        if storedPassword != password {
            return createErrorResponse(401, "Invalid credentials");
        }

        // Prepare the query to fetch user details after successful login
        sql:ParameterizedQuery query1 = `SELECT user.id FROM user WHERE email = ${email}`;
        sql:ParameterizedQuery query2 = `SELECT user.role FROM user WHERE email = ${email}`;
        // Execute the query to fetch user details
        int|error? resultStream1 = dbClient->queryRow(query1);
        string|error? resultStream2 = dbClient->queryRow(query2);

        if resultStream2 is sql:Error {
            io:println("Error occurred while fetching user details: ", resultStream2.toString());
            return createErrorResponse(500, "Internal server error");
        }
        if resultStream1 is sql:Error {
            io:println("Error occurred while fetching user details: ", resultStream1.toString());
            return createErrorResponse(500, "Internal server error");
        }

        // Initialize an array to store the result
        io:println(resultStream1);

        // Create a successful response
        // Create a successful response
        http:Response response = new;
        response.statusCode = 200;
        response.setJsonPayload({status: "Login successful", user: {userId: check resultStream1, email: email, role: check resultStream2}});
        io:println(response.statusCode);
        io:println(response.getJsonPayload());
        return response;
    }

    // Helper function to create an error response

    // resource function post login(http:Request req) returns sql:Error|error|int|error? {
    //     // Fetch and validate the JSON payload
    //     json|error payload = req.getJsonPayload();

    //     if payload is error {
    //         return error("Invalid JSON payload");
    //     }
    //     io:println(payload);

    //     // Extract the username and password from the payload
    //     string email = (check payload.email).toString();
    //     string password = (check payload.password).toString();

    //     // Prepare the query to fetch the stored password for the given username
    //     sql:ParameterizedQuery query = `SELECT password FROM user WHERE email = ${email}`;

    //     // Execute the query and fetch the result
    //     string|error? resultStream = dbClient->queryRow(query);

    //     // Get the first result from the stream

    //     if resultStream is sql:Error {
    //         // Handle SQL errors if any
    //         io:println("Error occurred while executing the query: ", resultStream.toString());
    //         return resultStream;
    //     } else if resultStream is () {
    //         // Handle case where no user is found
    //         return error("email not found");
    //     }

    //     // Extract the stored password
    //     string|error? storedPassword = resultStream;

    //     // Check if the stored password matches the provided password
    //     if storedPassword != password {
    //         return error("Invalid credentials");
    //     }

    //     // Prepare the query to fetch user details after successful login
    //     sql:ParameterizedQuery query1 = `SELECT user.id FROM user WHERE email = ${email}`;

    //     // Execute the query to fetch user details
    //     int|error? resultStream1 = dbClient->queryRow(query1);

    //     // Initialize an array to store the result
    //     io:println(resultStream1);
    //     // Return the array of users
    //     return resultStream1;
    // }
    resource function get get_patient_info/[int user_id](http:Request req) returns Patient|sql:Error|error {

        // Prepare the query
        sql:ParameterizedQuery query = `SELECT id, name, dob, nic, doctor_id, caretaker_id FROM patients WHERE id = ${user_id}`;

        // Execute the query and fetch the results
        Patient|sql:Error|error resultStream = dbClient->queryRow(query);

        return resultStream; // Return the array of patients
    }

    resource function get get_doctor_info/[int user_id](http:Request req) returns Doctor|sql:Error {

        // Prepare the query
        sql:ParameterizedQuery query = `SELECT id, name, dob, nic, doctor_lisence FROM doctors WHERE id = ${user_id}`;

        // Execute the query and fetch the results
        Doctor|sql:Error resultStream1 = dbClient->queryRow(query);

        return resultStream1; // Return the array of patients

    }

    resource function get get_care_taker_info/[int user_id](http:Request req) returns care_taker|sql:Error {

        // Prepare the query
        sql:ParameterizedQuery query = `SELECT id, name, dob, nic FROM caretakers WHERE id = ${user_id}`;

        // Execute the query and fetch the results
        care_taker|sql:Error resultStream1 = dbClient->queryRow(query);

        return resultStream1; // Return the array of patients

    }

    resource function post signup(user_signup user, http:Request req) returns sql:ExecutionResult|sql:Error {
        sql:ParameterizedQuery query = `INSERT INTO user (username,password,email,role) values (${user.username},${user.password},${user.email},${user.role})`;
        sql:ExecutionResult|sql:Error result = dbClient->execute(query);
        return result;
    }

}


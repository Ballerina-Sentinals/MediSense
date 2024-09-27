import ballerina/http;
import ballerina/log;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/io;
import ballerinax/java.jdbc;


type UserLogin record {
    string username;
    string password;
};

type LoginResponse record {
    string username;
};





// Define MySQL database configurations
mysql:Client dbClient = check new (user = "bill", password = "passpass", database = "Ballerina", host = "localhost", port = 3306);
function init() {
    // Print a success message when the connection is established
    io:println("Successfully connected to the database.");
}
service / on new http:Listener(8080) {
    
    resource function get testConnection() returns string {
        return "Database connection is active!";
    }
    
// Define the response type
    
    resource function post loginUser(UserLogin user) returns LoginResponse|error {
    // Correct SQL query to fetch username and password
    sql:ParameterizedQuery sqlQuery = `SELECT username, password FROM users WHERE username = ${user.username}`;

    // Execute the query and get the result stream
    table<record {| string username; string password; |}> key(username) result = table[dbClient->query(sqlQuery)];
    io:println(result.toArray());

    // Initialize a variable to hold the fetched user data
    UserLogin dbUser = { username: "", password: "" };

    // Fetch the first row from the result stream using next()
    var rowResult = result.next();
    io:println(rowResult);

    if rowResult is () {
        // No user was found
        log:printWarn("Login failed: No record found for username " + user.username);
        return error("Invalid credentials");
    } else if rowResult is sql:Error {
        // Handle SQL error
        log:printError("Error querying database", 'error = rowResult);
        return error("Database error");
    } else {
        // Assign the fetched values to dbUser
        dbUser.username = rowResult.value.username;
        dbUser.password = rowResult.value.password;
    }

    // Close the result stream after processing
    check result.close();

    // Verify the password
    if dbUser.password != user.password {
        log:printWarn("Login failed: Incorrect password for username " + user.username);
        return error("Invalid credentials");
    }

    // Log and return success response
    log:printInfo("User " + user.username + " logged in successfully");
    return { username: dbUser.username };
}

}

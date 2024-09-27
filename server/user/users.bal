import ballerina/http;
import ballerina/log;
import ballerinax/mysql;
import ballerina/sql;

type UserLogin record {
    string username;
    string password;
};

type LoginResponse record {
    string username;
};

// Define MySQL database configurations
mysql:Client dbClient = check new (user = "bill", password = "passpass", database = "Ballerina", host = "localhost", port = 3306);

service / on new http:Listener(8080) {

    resource function post loginUser(UserLogin user) returns LoginResponse|error {
        // Query the database to find the user
        string query = "SELECT username, password FROM users WHERE username = ?";

        // Execute the query with the provided username
        stream<sql:Row, error>? result = dbClient->query(query, user.username);

        // Check if the query returned a result
        if result is () {
            log:printWarn("Login failed: User not found for username " + user.username);
            return error("Invalid credentials");
        }

        // Fetch the result from the stream
        UserLogin dbUser = {};
        error? e = result.forEach(function(sql:Row row) {
            dbUser.username = check row.getString("username");
            dbUser.password = check row.getString("password");
        });

        // Close the stream
        result.close();

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

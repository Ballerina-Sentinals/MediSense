import ballerina/http;
import ballerina/log;

type UserLogin record {
    string username;
    string password;
};

type LoginResponse record {
    string username;
};

final map<UserLogin> users = {
    "john": {username: "john", password: "password123"},
    "jane": {username: "jane", password: "mypassword"}
};

service / on new http:Listener(8080) {

    resource function post loginUser(UserLogin user) returns LoginResponse|error {
        // Fetch the user record from the hardcoded JSON
        UserLogin? dbUser = users[user.username];

        // Check if the user exists and verify the password
        if dbUser is () || dbUser.password != user.password {
            log:printWarn("Login failed for username " + user.username);
            return error("Invalid credentials");
        }


        log:printInfo("User " + user.username + " logged in successfully on " );

        // Return response with username
        return {
            username: dbUser.username
        };
    }
}

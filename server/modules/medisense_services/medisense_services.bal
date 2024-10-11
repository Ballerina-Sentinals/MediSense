import ballerinax/mysql.driver as _;
import ballerina/http;
// import ballerina/io;
// import ballerina/sql;
import ballerinax/mysql;

mysql:Client dbClient = check new (host = "localhost", user = "root", password = "root", database = "medisense", port = 3306, options = {
});

service /v1 on new http:Listener(8080) {

    // Authentication API
    resource function post login(http:Caller caller, http:Request req) returns error? {
        json|error payload = req.getJsonPayload();
        if payload is error {
            json errorResponse = {status: "Error", message: "Invalid JSON payload"};
            check caller->respond(errorResponse);
            return;
        }

        json loginData = <json>payload;

        // Safely access username and password
        json|error usernameValue = loginData.username;
        json|error passwordValue = loginData.password;

        if usernameValue is json && passwordValue is json {
            string? username = usernameValue.toString();
            string? password = passwordValue.toString();

            if username is string && password is string {
                // Authenticate user (implement your authentication logic here)
                json response = {status: "Success", message: "Login Successful"};
                check caller->respond(response);
            } else {
                json errorResponse = {status: "Error", message: "Invalid username or password format"};
                check caller->respond(errorResponse);
            }
        } else {
            json errorResponse = {status: "Error", message: "Missing username or password"};
            check caller->respond(errorResponse);
        }
    }

    // Medication Schedule API
    resource function post schedule(http:Caller caller, http:Request req) returns error? {
        json|error payload = req.getJsonPayload();
        if payload is error {
            json errorResponse = {status: "Error", message: "Invalid JSON payload"};
            check caller->respond(errorResponse);
            return;
        }

        json scheduleData = <json>payload;
        // Process schedule and store in DB (implement your logic here)
        json response = {status: "Success", message: "Schedule Added"};
        check caller->respond(response);
    }

    // Store Schedule API
    // resource function post storeSchedule(http:Caller caller, http:Request req) returns error? {
    //     json scheduleData = check req.getJsonPayload();

    //     // Construct the SQL query using parameterized queries to avoid SQL injection
    //     string insertQuery = "INSERT INTO schedules (user_id, medication, dose, time) VALUES (?, ?, ?, ?)";
    //     sql:ParameterizedQuery pq = {
    //         query: insertQuery,
    //         args: [
    //             scheduleData.user_id.toString(),
    //             scheduleData.medication.toString(),
    //             scheduleData.dose.toString(),
    //             scheduleData.time.toString()
    //         ]
    //     };

    //     // Execute the query
    //     _ = check dbClient->execute(pq);

    //     // Send the response
    //     json response = {status: "Success", message: "Schedule Added"};
    //     check caller->respond(response);
    // }
}

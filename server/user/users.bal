import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;

// MySQL Database configuration
configurable string dbUser = "root";
configurable string dbPassword = "2003";
configurable string dbHost = "localhost";
configurable int dbPort = 3306;
configurable string dbName = "medisense";

// Initialize MySQL client
mysql:Client dbClient = check new (host = dbHost, port = dbPort, user = dbUser, password = dbPassword, database = dbName);

// Define HTTP listener
listener http:Listener loginListener = new (8080);

// Define service
service /user on loginListener {

    resource function post login(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        string username = (check payload.username).toString();
        string password = (check payload.password).toString();

        // Prepare the query with parameter
        sql:ParameterizedQuery query = `SELECT password FROM users WHERE username = ${username}`;

        // Execute the query
        stream<record {|string password;|}, sql:Error?> resultStream = dbClient->query(query);
        record {|record {|string password;|} value;|}|sql:Error? result = resultStream.next();

        if result is sql:Error {
            check caller->respond("Error occurred while querying the database");
        } else if result is () {
            check caller->respond("Invalid username or password");
        } else {
            string storedPassword = result.value.password;

            if storedPassword == password {
                check caller->respond("Login successful");
            } else {
                check caller->respond("Invalid username or password");
            }
        }
    }
}

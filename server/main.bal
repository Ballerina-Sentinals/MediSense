import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;

// MySQL Database configuration
configurable string dbUser = "root";
configurable string dbPassword = "password";
configurable string dbHost = "localhost";
configurable int dbPort = 3306;
configurable string dbName = "Ballerina";



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

// Initialize MySQL client
mysql:Client dbClient = check new (host = dbHost, port = dbPort, user = dbUser, password = dbPassword, database = dbName);

// Define HTTP listener
listener http:Listener loginListener = new (8080);

// Define service
service /user on loginListener {


   resource function post login(http:Request req) returns sql:Error|error|int|error? {
    // Fetch and validate the JSON payload
    json|error payload = req.getJsonPayload();
    
    if payload is error {
        return error("Invalid JSON payload");
    }

    // Extract the username and password from the payload
    string email = (check payload.email).toString();
    string password = (check payload.password).toString();

    // Prepare the query to fetch the stored password for the given username
    sql:ParameterizedQuery query = `SELECT password FROM user WHERE email = ${email}`;

    // Execute the query and fetch the result
    string|error? resultStream = dbClient->queryRow(query);

    // Get the first result from the stream
    

    if resultStream is sql:Error {
        // Handle SQL errors if any
        return resultStream;
    } else if resultStream is () {
        // Handle case where no user is found
        return error("email not found");
    }

    // Extract the stored password
    string|error? storedPassword = resultStream;

    // Check if the stored password matches the provided password
    if storedPassword != password {
        return error("Invalid credentials");
    }

    // Prepare the query to fetch user details after successful login
    sql:ParameterizedQuery query1 = `SELECT user.id FROM user WHERE email = ${email}`;

    // Execute the query to fetch user details
    int|error? resultStream1 = dbClient->queryRow(query1);

    // Initialize an array to store the result

    // Return the array of users
    return resultStream1;
}


    

    resource function get get_patient_info/[int user_id](http:Request req) returns Patient|sql:Error|error {

    // Prepare the query
        sql:ParameterizedQuery query = `SELECT id, name, dob, nic, doctor_id, caretaker_id FROM patients WHERE id = ${user_id}`;

    // Execute the query and fetch the results
        Patient|sql:Error|error resultStream = dbClient->queryRow(query);

        return resultStream; // Return the array of patients
    }


    resource function get  get_doctor_info/[int user_id](http:Request req) returns Doctor|sql:Error{

    // Prepare the query
        sql:ParameterizedQuery query = `SELECT id, name, dob, nic, doctor_lisence FROM doctors WHERE id = ${user_id}`;

    // Execute the query and fetch the results
        Doctor|sql:Error resultStream1 = dbClient->queryRow(query);

        return resultStream1; // Return the array of patients
        
    }

}





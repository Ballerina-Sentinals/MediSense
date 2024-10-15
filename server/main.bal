import ballerina/http;
import server.login;
import server.user;
import ballerinax/mysql;

// MySQL Database configuration
configurable string dbUser = "root";
configurable string dbPassword = "2003";
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

// Initialize MySQL client
mysql:Client dbClient = check new (host = dbHost, port = dbPort, user = dbUser, password = dbPassword, database = dbName);

// Define HTTP listener
listener http:Listener loginListener = new (8080);
listener http:Listener reminderListener = new (8081); // Added for reminder service

// Define User record type
type User record {| 
    int user_id; 
|};

// Define Reminder record type
type Reminder record {| 
    int user_id; 
    string reminder_id; 
    string date; 
    string time; 
    string med_ids; 
    string status; 
|};

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


    

    resource function get getAllPatients(http:Request req) returns Patient[]|sql:Error|error {
    // Fetch and validate the JSON payload
        json|error payload = req.getJsonPayload();

        if payload is error {
        // Handle the error properly, return or log
            io:println("Error fetching JSON payload: ", payload.message());
            return error("Invalid JSON payload");
        }

    // Extract the user_id field safely
        json|error userIdJson = payload.user_id;
        if userIdJson is () {
            return error("user_id field is missing");
        }

        string|error? user_id = (check userIdJson).toString();

    // Prepare the query
        sql:ParameterizedQuery query = `SELECT id, name, dob, nic, doctor_id, caretaker_id FROM patients WHERE id = ${check user_id}`;

    // Execute the query and fetch the results
        stream<Patient, sql:Error?> resultStream = dbClient->query(query);

    // Initialize an empty array to hold the patients
        Patient[] patients = [];

    // Iterate over the result stream and populate the array
        error? e = resultStream.forEach(function(Patient patient) {
            patients.push(patient);
        });

        if e is sql:Error {
            return e; // Return error if any occurred during iteration

        }

        return patients; // Return the array of patients
    }

    // resource function get getAllPatients() returns sql:Error|Patient[] {
    //     string query = "SELECT id, name, dob, nic, doctor_id, caretaker_id FROM patients";

    //     // Execute the query and fetch the results
    //     stream<Patient, sql:Error?> resultStream = dbClient->query(query);

    //     // Initialize an empty array to hold the patients
    //     Patient[] patients = [];

    //     // Iterate over the result stream and populate the array
    //     error? e = resultStream.forEach(function(Patient patient) {
    //         patients.push(patient);
    //     });

    //     if e is sql:Error {
    //         return e; // Return error if any
    //     }

    //     return patients; // Return the array of patients
    // }

}






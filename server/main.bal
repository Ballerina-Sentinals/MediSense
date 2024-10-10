
import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;


// MySQL Database configuration
configurable string dbUser = "bill";
configurable string dbPassword = "passpass";
configurable string dbHost = "localhost";
configurable int dbPort = 3306;
configurable string dbName = "Ballerina";


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
listener http:Listener loginListener = new(8080);

// Define service
service /user on loginListener {

    resource function post login(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        string username = (check payload.username).toString();
        string password = (check payload.password).toString();

        // Prepare the query with parameter
        sql:ParameterizedQuery query = `SELECT password FROM user WHERE username = ${username}`;

        // Execute the query
        stream<record {| string password; |}, sql:Error?> resultStream = dbClient->query(query);
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


    resource function  get getAllPatients() returns sql:Error|Patient[] {
        string query = "SELECT id, name, dob, nic, doctor_id, caretaker_id FROM patients";
    
    // Execute the query and fetch the results
        stream<Patient, sql:Error?> resultStream = dbClient->query(query);

    // Initialize an empty array to hold the patients
        Patient[] patients = [];
    
    // Iterate over the result stream and populate the array
        error? e = resultStream.forEach(function(Patient patient) {
            patients.push(patient);
        });

        if e is sql:Error {
            return e; // Return error if any
        }

        return patients; // Return the array of patients
    }



}

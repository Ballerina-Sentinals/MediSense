import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerina/log;
import ballerina/time;

// MySQL Database configuration
configurable string dbUser = "root";
configurable string dbPassword = "Pafs&SQL@123";
configurable string dbHost = "localhost";
configurable int dbPort = 3306;
configurable string dbName = "Ballerina";


// Initialize MySQL client
mysql:Client dbClient = check new (host = dbHost, port = dbPort, user = dbUser, password = dbPassword, database = dbName);

// Define HTTP listeners
listener http:Listener loginListener = new (8080);

listener http:Listener reminderListener = new(8080);

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

service /reminders on reminderListener {
    resource function post createReminder(Reminder newReminder) returns ReminderCreated |error? {
        // Extract the reminder details from the request payload
        Reminder reminder = {
            ...newReminder
        };

        var userId = reminder.user_id;
        var date = reminder.date;
        var time = reminder.time;
        var recordId = reminder.record_id;

        // Prepare the query to insert the reminder
        sql:ParameterizedQuery query = `INSERT INTO Reminders (user_id, date, time, med_ids)
                                        VALUES (${userId}, ${date}, ${time}, ${recordId})`;

        // Execute the query to insert the reminder
        int|error? resultStream1 = dbClient->queryRow(query);

        if resultStream1 is sql:Error {
        // Handle SQL errors if any
        return resultStream1;
        }
        // Schedule the reminder based on the time
        _ = start scheduleReminder(userId, date, time, medIds);

        // Return the created reminder
        return{
            body: reminder
        };
        
    }


    // Define the GET resource to fetch reminders due for today
    resource function get today(http:Caller caller, http:Request req) returns error? {
        // Get the current date in "YYYY-MM-DD" format
        time:Date currentDate = time:currentDate();
        string todayDate = check currentDate.toString("yyyy-MM-dd");

        // Prepare the query to fetch reminders due for today
        sql:ParameterizedQuery query = `SELECT user_id, reminder_id, reminder_date, reminder_time, med_ids, status 
                                        FROM reminders 
                                        WHERE reminder_date = ${todayDate}`;

        // Execute the query and fetch the results
        stream<Reminder, sql:Error> resultStream = dbClient->query(query);

        // Initialize an array to store the reminders for today
        Reminder[] reminders = [];

        // Iterate through the result stream
        error? e = resultStream.forEach(function(Reminder reminder) {
            reminders.push(reminder);
        });

        // Close the stream after use
        check resultStream.close();

        // Send the reminders to the frontend as JSON
        check caller->respond(reminders);
    }

    
}









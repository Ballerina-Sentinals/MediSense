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
        
        if resultStream is sql:Error {
            return resultStream;
        } else if resultStream is () {
            return error("email not found");
        }

        // Extract the stored password
        string|error? storedPassword = resultStream;

        // Check if the stored password matches the provided password
        if storedPassword != password {
            return error("Invalid credentials");
        }

        // Prepare the query to fetch user details after successful login
        sql:ParameterizedQuery query1 = `SELECT user_id FROM user WHERE email = ${email}`;
        
        // Execute the query to fetch user details
        int|error? resultStream1 = dbClient->queryRow(query1);

        // Return the user ID
        return resultStream1;
    }
}

// Reminder service
service /reminders on reminderListener {
    resource function post createReminder(Reminder newReminder) returns Reminder|error? {
        // Extract the reminder details from the request payload
        Reminder reminder = {
            ...newReminder
        };

        var userId = reminder.user_id;
        var date = reminder.date;
        var time = reminder.time;
        var recordId = reminder.reminder_id;

        // Prepare the query to insert the reminder
        sql:ParameterizedQuery query = `INSERT INTO Reminders (user_id, date, time, med_ids)
                                        VALUES (${userId}, ${date}, ${time}, ${recordId})`;

        // Execute the query to insert the reminder
        int|error? resultStream1 = dbClient->queryRow(query);

        if resultStream1 is sql:Error {
            return resultStream1;
        }

        // Return the created reminder
        return reminder;
    }

    // Define the GET resource to fetch reminders due for today
    resource function get today(http:Caller caller, http:Request req) returns error? {
        // Get the current date in "YYYY-MM-DD" format
        time:Civil currentDateTime = time:currentTime().toCivil();
        string todayDate = string `${currentDateTime.year}-${currentDateTime.month}-${currentDateTime.day}`;

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

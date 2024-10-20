import ballerina/http;
import ballerina/sql;

public type Time record {|
    int hour;
    int minute;
    string am_pm;

|};

public type Reminder record {|
    int user_id;
    string time;
    string date;
    string description;
|};

public type View_Reminder record {|
    int reminder_id;
    string time;
    string date;
    string description;
|};

public function createErrorResponse(int statusCode, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setJsonPayload({"error": message});
    return response;
}

public function create_reminder(Reminder new_reminder, sql:Client dbClient) returns http:Response|error? {
    sql:ParameterizedQuery query = `INSERT INTO reminders (user_id, time, date, record) VALUES (${new_reminder.user_id},${new_reminder.time},${new_reminder.date}, ${new_reminder.description});`;
    sql:ExecutionResult|error result = check dbClient->execute(query);
    if result is sql:Error {
        return createErrorResponse(500, "Internal server error");
    }
    http:Response response = new;
    response.statusCode = 201;
    response.setJsonPayload({"message": "Reminder created successfully"});
    return response;
}

public function view_reminders(string date, int user_id, sql:Client dbClient) returns error|View_Reminder[] {
    sql:ParameterizedQuery query = `SELECT reminder_id, date, time, record as description FROM reminders WHERE date = ${date} AND user_id = ${user_id};`;
    stream<View_Reminder, sql:Error?> resultStream = dbClient->query(query);
    View_Reminder[] reminders = [];

    error? e = resultStream.forEach(function(View_Reminder reminder) {
        reminders.push(reminder);
    });

    if (e is error) {
        return e; // Return the error if something goes wrong.
    }
    return reminders;

}

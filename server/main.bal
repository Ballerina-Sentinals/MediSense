import server.login;
import server.user;

import ballerina/http;
//import ballerina/sql;
import ballerinax/mysql;

// MySQL Database configuration
configurable string dbUser = "root";
configurable string dbPassword = "2003";
configurable string dbHost = "localhost";
configurable int dbPort = 3306;

configurable string dbName = "medisense";

mysql:Client dbClient1 = check new (host = dbHost, port = dbPort, user = dbUser, password = dbPassword, database = dbName);
listener http:Listener loginListener = new (8080);

service /user on loginListener {
    resource function post login(http:Request req) returns http:Response|error {
        // Fetch and validate the JSON payload
        return login:login(req, dbClient1);
    }

    resource function post login_(http:Request req) returns http:Response|error
    {
        return login:login(req, dbClient1);
    }

    resource function post signup_(usersignup user) returns http:Response|error {
        return login:signup(user, dbClient1);
    }

    resource function get patient_profile/[int user_id_](http:Request req) returns user:Patient|error?|http:Response {
        return user:patient_info(req, user_id_, dbClient1);

    }

    resource function get doctor_profile/[int user_id_](http:Request req) returns http:Response|user:Doctor|error? {
        return user:doctor_info(req, user_id_, dbClient1);

    }

    resource function get pharmacy_profile/[int user_id_](http:Request req) returns http:Response|user:Pharmacy|error? {
        return user:pharmacy_info(req, user_id_, dbClient1);

    }
}


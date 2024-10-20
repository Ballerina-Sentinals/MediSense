import server.appointments;
import server.chat_system;
import server.locator;
import server.login;
import server.reminders;
import server.user;

import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;

// MySQL Database configuration
configurable string dbUser = "root";
configurable string dbPassword = "2003";
configurable string dbHost = "localhost";
configurable int dbPort = 3306;

configurable string dbName = "medisense";

mysql:Client dbClient1 = check new (host = dbHost, port = dbPort, user = dbUser, password = dbPassword, database = dbName);
listener http:Listener loginListener = new (8080);

service / on loginListener {

    resource function post login_(http:Request req) returns http:Response|error
    {
        return login:login(req, dbClient1);
    }

    resource function post signup_(usersignup user) returns http:Response|error {
        return login:signup(user, dbClient1);
    }

    resource function get patient_profile/[int user_id_]() returns user:Patient_view|error?|http:Response {
        return user:patient_info(user_id_, dbClient1);

    }

    resource function get doctor_profile/[int user_id_]() returns http:Response|Doctor_view|error? {
        return user:doctor_info(user_id_, dbClient1);

    }

    resource function get pharmacy_profile/[int user_id_]() returns http:Response|Pharmacy_view|error? {
        return user:pharmacy_info(user_id_, dbClient1);

    }

    resource function put patient_registation/[int user_id](Patient new_p) returns sql:Error|http:Response {
        return user:patient_reg(new_p, user_id, dbClient1);

    }

    resource function put doctor_registation/[int user_id](Doctor new_doc) returns http:Response|sql:Error {
        return user:doctor_reg(new_doc, user_id, dbClient1);
    }

    resource function put pharmacy_registation/[int user_id](Pharmacy new_phar) returns http:Response|sql:Error {
        return user:pharmacy_reg(new_phar, user_id, dbClient1);

    }

    resource function delete delete_prescription/[int prescript_id]() returns http:Response|sql:Error {
        return chat_system:prescription_deleter(prescript_id, dbClient1);

    }

    resource function post locator_doctor(locator doc_location) returns locator:Doctor[]|error {
        return locator:doctor_locator(doc_location, dbClient1);
    }

    resource function post locator_pharmacy(locator phar_location) returns Pharmacy[]|error {
        return locator:pharmacy_locator(phar_location, dbClient1);

    }

    resource function post new_appoinment(appointment new_app) returns http:Response|error {
        return appointments:create_appointment(new_app, dbClient1);

    }

    resource function get doc_appoinment/[int user_id]/[string date]() returns table<view_p> key(appointment_id)|error {
        return appointments:view_all(user_id, date, dbClient1);

    }

    resource function put appoinment_done/[int appoinment_id]() returns http:Response|sql:Error {
        return appointments:complete_appo(appoinment_id, dbClient1);

    }

    resource function get doc_appoinment_booked/[int user_id]/[string date]() returns table<appointments:view_p> key(appointment_id)|error {
        return appointments:view_all_booked(user_id, date, dbClient1);

    }

    resource function post add_reminder(Reminder new_reminder) returns http:Response|error? {
        return reminders:create_reminder(new_reminder, dbClient1);

    }

    resource function get view_reminder/[int user_id]/[string date]() returns error|reminders:View_Reminder[] {
        return reminders:view_reminders(date, user_id, dbClient1);

    }

    resource function get view_appointments/[int user_id]/[string date]() returns error|table<appointments:view_appo> key(appointment_id) {
        return appointments:view_patient_appo(user_id, date, dbClient1);

    }

}

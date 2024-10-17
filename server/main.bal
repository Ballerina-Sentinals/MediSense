import ballerina/http;
import server.login;
import server.user;
import ballerinax/mysql;
import ballerina/sql;
import server.chat_system;
import server.locator;
import server.appoinments;
// MySQL Database configuration
configurable string dbUser = "root";
configurable string dbPassword = "password";
configurable string dbHost = "localhost";
configurable int dbPort = 3306;
configurable string dbName = "Ballerina";

mysql:Client dbClient1 = check new (host = dbHost, port = dbPort, user = dbUser, password = dbPassword, database = dbName);
listener http:Listener loginListener = new (8080);

service / on loginListener {

   resource function post login_(http:Request req)  returns http:Response|error
   {
        return login:login(req,dbClient1);
   }

   resource function post signup_(usersignup user) returns http:Response|error {
        return login:signup(user,dbClient1);
   }


    resource function get patient_profile/[int user_id_]()returns user:Patient_view|error?|http:Response {
        return user:patient_info(user_id_,dbClient1);
        
    }

    resource function get  doctor_profile/[int user_id_]()returns http:Response|Doctor_view|error? {
        return user:doctor_info(user_id_,dbClient1);
        
    }

    resource function get  pharmacy_profile/[int user_id_]()returns http:Response|Pharmacy_view|error? {
        return user:pharmacy_info(user_id_,dbClient1);
        
    }

    resource function put  patient_registation/[int user_id](Patient new_p) returns http:Response|sql:Error {
        return user:patient_reg(new_p,user_id,dbClient1);
        
    }

    resource function put doctor_registation/[int user_id](Doctor new_doc) returns http:Response|sql:Error {
        return user:doctor_reg(new_doc,user_id,dbClient1);
    }

    resource function put pharmacy_registation/[int user_id](Pharmacy new_phar) returns http:Response|sql:Error {
        return user:pharmacy_reg(new_phar,user_id,dbClient1);
        
    }

    resource function post prescription_builder(Prescript new_prescription) returns http:Response|sql:Error{
        return chat_system:prescription_creater(new_prescription,dbClient1);
        
    }

    resource function delete delete_prescription/[int prescript_id]() returns http:Response|sql:Error{
        return chat_system:prescription_deleter(prescript_id,dbClient1);
        
    }
    resource function post locator_doctor(locator doc_location)returns locator:Doctor[]|error {
        return locator:doctor_locator(doc_location,dbClient1);
    }   
    resource function post locator_pharmacy(locator phar_location)returns Pharmacy[]|error {
        return locator:pharmacy_locator(phar_location,dbClient1);
        
    }

    resource function post new_appoinment(appoinment new_app) returns http:Response|error {
        return appoinments:create_appoinment(new_app,dbClient1);
        
    }
    resource function get doc_appoinment/[int user_id](string date)returns table<appoinment> key(appoinment_id)|error {
        return appoinments:view_all(user_id,date,dbClient1);
        
    } 
    resource function put  appoinment_done/[int appoinment_id]() returns http:Response|sql:Error {
        return appoinments:complete_appo(appoinment_id,dbClient1);
        
    }
    
}
import server.community;
import server.chat_system;
import server.locator;
import server.login;
import server.user;
import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;

// MySQL Database configuration
configurable string dbUser = "root";
configurable string dbPassword = "Pafs&SQL@123";
configurable string dbHost = "localhost";
configurable int dbPort = 3306;
configurable string dbName = "Ballerina";

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

    
    resource function put patient_registation/[int user_id](Patient new_p) returns http:Response|sql:Error {
        return user:patient_reg(new_p, user_id, dbClient1);

    }

    resource function put doctor_registation/[int user_id](Doctor new_doc) returns http:Response|sql:Error {
        return user:doctor_reg(new_doc, user_id, dbClient1);
    }

    resource function put pharmacy_registation/[int user_id](Pharmacy new_phar) returns http:Response|sql:Error {
        return user:pharmacy_reg(new_phar, user_id, dbClient1);

    }

    resource function post prescription_builder(Prescript new_prescription) returns http:Response|sql:Error {
        return chat_system:prescription_creater(new_prescription, dbClient1);

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

    resource function get getPosts(string? category) returns Post[]|error{
        if category is string {
            return community:get_posts(category, dbClient1);
        }
        return community:get_posts((),dbClient1);
    }

    resource function get getPostByIndex (int index) returns Post|http:NotFound{
        return community:get_post_byindex(index, dbClient1);
    }
    
    resource function post createPost(NewPost post) returns PostCreated|http:BadRequest|error {
        return community:create_post(post, dbClient1);
    }

    resource function delete deletePost(int index) returns http:NoContent|error {
        return community:delete_post(index, dbClient1);
        
    }

    resource function post createComment(NewComment comment) returns CommentCreated|http:BadRequest|error {
        return community:add_comment(comment, dbClient1);
    }

    resource function get getComments(int PostIndex) returns Comment[]|http:NotFound|error {
        return community:get_comments(PostIndex, dbClient1);
    }

    resource function get postWithComments(int index) returns PostWithComments|http:NotFound|error {
        return community:get_post_with_comments(index, dbClient1);
    }

    resource function delete deleteComment(int index) returns http:NoContent|error {
        return community:delete_comment(index, dbClient1);
    }

}   
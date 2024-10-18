import ballerina/time;
import ballerina/http;
import ballerina/sql;


public type usersignup record {|
    string username;
    string password;
    string email;
    string role;
|};

public type Patient record {
    string gender;
    string dob;
    string nic;
    string emergency_contact;
    decimal weight;
    decimal height;
    string allergies;
};

public type Doctor record {
    string nic;
    string doctor_license;
    string description;
};

public type Pharmacy record {
    string district;
    string town;
    string street;
    string con_number;
    decimal rating;
};

public type Prescript record {|
    int prescript_id;
    int sender_user_id;
    int receiver_user_id;
    string? pill_1;
    string? pill_2;
    string? pill_3;
    string? pill_4;
    string? pill_5;

|};



public type locator record {|
    string district;
    string town;

|};



type User record {|
    int user_id;
    
|};

type Reminder record {|
    int user_id;
    Record recordInfo;
    string date;
    string time;
|};

type Record record {|
    string record_data;
|};

type ReminderCreated record {|
    *http:Created;
     Reminder body;
|};

public type Appointment record {|
    readonly int appointment_id;
    int patient_id;
    int doctor_id;
    int number;
    string date;
    string created_date;
    string status;
|};

public type PatientView record {|
    int patient_id;
    int user_id;
    string name;
    time:Civil dob;
    string nic;
    int doctor_id;
    int emergency_contact;
    decimal weight;
    decimal height;
    string allergies;
|};

public type DoctorView record {|
    int doctor_id;
    int user_id;
    string name;
    string nic;
    string doctor_license;
    string description;
|};

public type PharmacyView record {|
    int pharm_id;
    int user_id;
    string name;
    string district;
    string town;
    string street;
    string con_number;
    decimal rating;
|};

type Post record {|
    @sql:Column {name: "id"}
    readonly int id;
    @sql:Column {name: "user_id"}
    int userId;
    @sql:Column {name: "content"}
    string description;
    @sql:Column {name: "tags"}
    string tags;
    @sql:Column {name: "category"}
    string category;
|};

type Comment record {|
    @sql:Column {name: "id"}
    readonly int id;
    @sql:Column {name: "post_id"}
    int postId;
    @sql:Column {name: "user_id"}
    int userId;
    @sql:Column {name: "content"}
    string description;
    |};

public type NewPost record {|
    int user_Id;
    string description;
    string tags;
    string category;
|};

public type PostCreated record {|
    *http:Created;
    Post body;
    |};

type CommentCreated record {|
    *http:Created;
     Comment body;
    |};

type NewComment record {|
    int postId;
    int userId;
    string description;
    |};

type PostWithMeta record {|
    int id;
    int userId;
    string description;
    Meta meta;
|};

type Meta record {|
    string[] tags;
    string category;
|};

type PostWithComments record {|
    Post post;
    Comment[] comments;
|};

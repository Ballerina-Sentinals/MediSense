import ballerina/time;

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
    int user_id;
    string name;
    string nic;
    string doctor_license;
    string description;
};

public type Pharmacy record {
    int user_id;
    string name;
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

public type Patient_view record {
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
};

public type locator record {|
    string district;
    string town;

|};

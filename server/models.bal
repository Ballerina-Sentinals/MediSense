

public type usersignup record {|
    string username;
    string password;
    string email;
    string role;
|};


public type Patient record {
    int id;
    string name;
    string dob;
    string nic;
    int? doctor_id;
    int? caretaker_id;
};

 public type Doctor record {
    int id;
    string name;
    string dob;
    string? nic;
    string? doctor_lisence;

};

public type care_taker record {
    int id;
    string name;
    string dob;
    string nic;
};


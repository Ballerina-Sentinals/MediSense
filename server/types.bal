import ballerina/http;

type User record {|
    int user_id;
    
|};

type Patient record {
    int id;
    string name;
    string dob;
    string nic;
    int? doctor_id;
    int? caretaker_id;
};

type Reminder record {|
    int user_id;
    string record_id;
    string date;
    string time;
    
|};

type Dosage record {|
    int med_id;
    int dosage;
|};

type ReminderCreated record {|
    *http:Created;
     Reminder body;
|};


// type MedDiaryEntry record {|

//     readonly int med_diary_entry_id;
//     int user_id;
//     string date;
//     string time;
//     string med_ids;
//     string med_dose;
//     string med_notes;

// |};
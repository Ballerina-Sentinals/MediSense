import ballerina/sql;


public type locator record {|
    string district;
    string town;

|};
public type Doctor record {
    int user_id;
    string name;
    string nic;
    string doctor_license ;
    string description;
    int doctor_id;
    string town;
    string district;
};

public type Pharmacy record {
    int user_id ;
    string name ;
    string district ;
    string town ;
    string street ;
    string con_number ;
    decimal rating ;
};

public function doctor_locator(locator location,sql:Client dbClient) returns Doctor[]|error {
    
    // Create a MySQL database configuration.
    
    // Define the query to select JavaScript files.
    sql:ParameterizedQuery selectQuery = `SELECT * from doctors where district = ${location.district} and town = ${location.town};`;
    
    // Execute the query and map the result.
    stream<Doctor, sql:Error?> resultStream = dbClient->query(selectQuery);
    
    // Create a list to hold the retrieved files.
    Doctor[] jsFiles = [];
    
    // Iterate over the result stream and add to the list.
    error? e = resultStream.forEach(function(Doctor doctor) {
        jsFiles.push(doctor);
    });
    
    if (e is error) {
        return e;  // Return the error if something goes wrong.
    }
    
    // Close the database connection.
    
    // Return the list of JavaScript files.
    return jsFiles;
}


public function pharmacy_locator(locator location,sql:Client dbClient) returns Pharmacy[]|error {
    
    // Create a MySQL database configuration.
    
    // Define the query to select JavaScript files.
    sql:ParameterizedQuery selectQuery = `SELECT * from pharmacies where district = ${location.district} and town = ${location.town};`;
    
    // Execute the query and map the result.
    stream<Pharmacy, sql:Error?> resultStream = dbClient->query(selectQuery);
    
    // Create a list to hold the retrieved files.
    Pharmacy[] jsFiles = [];
    
    // Iterate over the result stream and add to the list.
    error? e = resultStream.forEach(function(Pharmacy pharmacy) {
        jsFiles.push(pharmacy);
    });
    
    if (e is error) {
        return e;  // Return the error if something goes wrong.
    }
    
    // Close the database connection.
    check dbClient.close();
    
    // Return the list of JavaScript files.
    return jsFiles;
}




import ballerina/io;
import ballerina/test;

// Before Suite Function
public function hello(string? name) returns string {
    if name !is () {
        return string `Hello, ${name}`;
    }
    return "Hello, World!";
}
@test:BeforeSuite
function beforeSuiteFunc() {
    io:println("I'm the before suite function!");
}

// Test function

@test:Config {}
function testFunction() {
    string name = "John";
    string welcomeMsg = hello(name);
    test:assertEquals(welcomeMsg, "Hello, John");
}

// Negative Test function

@test:Config {}
function negativeTestFunction() {
    string welcomeMsg = hello(());
    test:assertEquals(welcomeMsg, "Hello, World!");
}

// After Suite Function

@test:AfterSuite
function afterSuiteFunc() {
    io:println("I'm the after suite function!");
}

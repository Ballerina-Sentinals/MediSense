import ballerina/io;
import ballerina/test;

// Before Suite Function

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

function hello(string name) returns string {
    return "";
}

// Negative Test function

@test:Config {}
function negativeTestFunction() {
    string welcomeMsg = hello(("123"));
    test:assertEquals(welcomeMsg, "Hello, World!");
}

// After Suite Function

@test:AfterSuite
function afterSuiteFunc() {
    io:println("I'm the after suite function!");
}

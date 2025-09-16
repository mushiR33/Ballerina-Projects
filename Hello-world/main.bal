import ballerina/http;

service / on new http:Listener(8080) {
    
    resource function get .() returns string {
        return "Hello, World!";
    }
}
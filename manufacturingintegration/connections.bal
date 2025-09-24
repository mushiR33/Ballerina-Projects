import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/http;

// MySQL database client - made public for access from functions.bal
public final mysql:Client dbClient = check new(
    host = dbHost,
    user = dbUser, 
    password = dbPassword,
    database = dbName,
    port = dbPort
);

// HTTP client for inventory service communication
public final http:Client inventoryServiceClient = check new(inventoryServiceUrl);

// HTTP client for API service communication
public final http:Client apiServiceClient = check new(apiServiceUrl);
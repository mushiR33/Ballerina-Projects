import ballerina/http;
import ballerinax/ai;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

// MySQL database client - made public for access from functions.bal
public final mysql:Client dbClient = check new (
    host = dbHost,
    user = dbUser,
    password = dbPassword,
    database = dbName,
    port = dbPort
);

// HTTP client for inventory service communication
public final http:Client inventoryServiceClient = check new (inventoryServiceUrl);

// HTTP client for API service communication
public final http:Client apiServiceClient = check new (apiServiceUrl);
final ai:OpenAiProvider _OrderAgentModel = check new ("", "chatgpt-4o-latest");
final ai:OpenAiProvider aiOpenaiprovider = check new (openAIAPIKey, "gpt-4.1");
final ai:OpenAiProvider aiOpenaiproviderResult = check new (openAIAPIKey, "gpt-4.1");
final ai:OpenAiProvider aiOpenaiproviderOut = check new (openAIAPIKey, "gpt-4.1");

import ballerina/http;
import ballerina/log;

// HTTP client for the /api service
public class ApiClient {
    private final http:Client httpClient;
    
    // Initialize the API client
    public function init(string serviceUrl = "http://localhost:8080") returns error? {
        self.httpClient = check new(serviceUrl);
    }
    
    // Place a new order
    public function placeOrder(OrderRequest orderRequest) returns OrderResponse|ErrorResponse|error {
        OrderResponse|http:ClientError response = self.httpClient->post("/api/orders", orderRequest);
        
        if response is http:ClientError {
            log:printError("Failed to place order: " + response.message());
            return error("Failed to place order: " + response.message());
        }
        
        return response;
    }
    
    // Get order details by order ID
    public function getOrder(string orderId) returns OrderWithItems|ErrorResponse|error {
        string resourcePath = "/api/orders/" + orderId;
        OrderWithItems|http:ClientError response = self.httpClient->get(resourcePath);
        
        if response is http:ClientError {
            log:printError("Failed to get order: " + response.message());
            return error("Failed to get order: " + response.message());
        }
        
        return response;
    }
    
    // Get order items by order ID
    public function getOrderItems(string orderId) returns OrderItemDetail[]|ErrorResponse|error {
        string resourcePath = "/api/orders/" + orderId + "/items";
        OrderItemDetail[]|http:ClientError response = self.httpClient->get(resourcePath);
        
        if response is http:ClientError {
            log:printError("Failed to get order items: " + response.message());
            return error("Failed to get order items: " + response.message());
        }
        
        return response;
    }
    
    // Check inventory for a specific product
    public function checkInventory(string productId) returns InventoryItem|ErrorResponse|error {
        string resourcePath = "/api/inventory/" + productId;
        InventoryItem|http:ClientError response = self.httpClient->get(resourcePath);
        
        if response is http:ClientError {
            log:printError("Failed to check inventory: " + response.message());
            return error("Failed to check inventory: " + response.message());
        }
        
        return response;
    }
    
    // Health check
    public function healthCheck() returns map<string>|error {
        map<string>|http:ClientError response = self.httpClient->get("/api/health");
        
        if response is http:ClientError {
            log:printError("Failed to perform health check: " + response.message());
            return error("Failed to perform health check: " + response.message());
        }
        
        return response;
    }
    
    // Close the HTTP client
    public function close() returns error? {
        // HTTP client doesn't require explicit closing in Ballerina
        // This method is provided for consistency
    }
}

// Convenience function to create an API client instance
public function createApiClient(string serviceUrl = "http://localhost:8080") returns ApiClient|error {
    ApiClient apiClient = check new(serviceUrl);
    return apiClient;
}
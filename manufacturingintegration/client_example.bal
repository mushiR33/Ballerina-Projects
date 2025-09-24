import ballerina/log;
import ballerina/io;

// Example usage of the API client
public function main() returns error? {
    // Create API client instance
    ApiClient apiClient = check createApiClient(apiServiceUrl);
    
    // Example 1: Health check
    map<string>|error healthResult = apiClient.healthCheck();
    if healthResult is map<string> {
        io:println("Health check result: ", healthResult);
    } else {
        log:printError("Health check failed: " + healthResult.message());
    }
    
    // Example 2: Check inventory
    InventoryItem|ErrorResponse|error inventoryResult = apiClient.checkInventory("PG001");
    if inventoryResult is InventoryItem {
        io:println("Inventory for PG001: ", inventoryResult);
    } else if inventoryResult is ErrorResponse {
        log:printError("Inventory check error: " + inventoryResult.message);
    } else {
        log:printError("Inventory check failed: " + inventoryResult.message());
    }
    
    // Example 3: Place an order
    OrderItemRequest[] items = [
        {
            productId: "PG001",
            productName: "Tide Laundry Detergent 64oz",
            quantity: 2,
            unitPrice: 12.99d
        },
        {
            productId: "PG002",
            productName: "Pampers Baby Dry Diapers Size 4",
            quantity: 1,
            unitPrice: 24.99d
        }
    ];
    
    OrderRequest orderRequest = {
        customerId: "CUST001",
        customerName: "John Doe",
        items: items
    };
    
    OrderResponse|ErrorResponse|error orderResult = apiClient.placeOrder(orderRequest);
    if orderResult is OrderResponse {
        io:println("Order placed successfully: ", orderResult);
        
        // Example 4: Get order details
        string orderId = orderResult.orderId;
        OrderWithItems|ErrorResponse|error orderDetails = apiClient.getOrder(orderId);
        if orderDetails is OrderWithItems {
            io:println("Order details: ", orderDetails);
            
            // Example 5: Get order items
            OrderItemDetail[]|ErrorResponse|error orderItems = apiClient.getOrderItems(orderId);
            if orderItems is OrderItemDetail[] {
                io:println("Order items: ", orderItems);
            } else if orderItems is ErrorResponse {
                log:printError("Get order items error: " + orderItems.message);
            } else {
                log:printError("Get order items failed: " + orderItems.message());
            }
        } else if orderDetails is ErrorResponse {
            log:printError("Get order error: " + orderDetails.message);
        } else {
            log:printError("Get order failed: " + orderDetails.message());
        }
    } else if orderResult is ErrorResponse {
        log:printError("Order placement error: " + orderResult.message);
    } else {
        log:printError("Order placement failed: " + orderResult.message());
    }
}
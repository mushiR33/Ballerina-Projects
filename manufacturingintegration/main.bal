import ballerina/ai;
import ballerina/http;

// Order placement service with inventory verification
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: false,
        allowHeaders: ["*"],
        allowMethods: ["GET", "POST", "OPTIONS"]
    }
}
service /api on new http:Listener(8080) {

    // Place a new order with inventory verification
    resource function post orders(OrderRequest orderRequest) returns OrderResponse|ErrorResponse|http:InternalServerError {

    OrderResponse|ErrorResponse|error result = processOrderPlacement(orderRequest);
    
    if result is error {
        http:InternalServerError internalError = {
            body: {
                message: result.message(),
                errorCode: "PROCESSING_ERROR"
            }
        };
        return internalError;
    }
    
    return result;
    }

    // Get order details by order ID
    resource function get orders/[string orderId]() returns OrderWithItems|ErrorResponse|http:InternalServerError {
        OrderWithItems|error orderResult = getOrderById(orderId);

        if orderResult is error {
            string orderMessage = orderResult.message();
            ErrorResponse errorResponse = {
                message: orderMessage,
                errorCode: "ORDER_NOT_FOUND"
            };
            return errorResponse;
        }

        return orderResult;
    }

    // Get order items by order ID
    resource function get orders/[string orderId]/items() returns OrderItemDetail[]|ErrorResponse|http:InternalServerError {
        OrderItemDetail[]|error itemsResult = getOrderItems(orderId);

        if itemsResult is error {
            string itemsMessage = itemsResult.message();
            http:InternalServerError internalError = {
                body: {
                    message: "Failed to retrieve order items: " + itemsMessage,
                    errorCode: "DATABASE_ERROR"
                }
            };
            return internalError;
        }

        return itemsResult;
    }

    // Check inventory for a specific product (proxy to inventory service)
    resource function get inventory/[string productId]() returns InventoryItem|ErrorResponse|http:InternalServerError {
        InventoryItem|error inventoryResult = checkProductInventory(productId);

        if inventoryResult is error {
            string inventoryMessage = inventoryResult.message();
            ErrorResponse errorResponse = {
                message: inventoryMessage,
                errorCode: "PRODUCT_NOT_FOUND"
            };
            return errorResponse;
        }

        return inventoryResult;
    }

    // Health check endpoint
    resource function get health() returns map<string> {
        string currentTime = getCurrentTimestamp();
        return {
            "status": "UP",
            "service": "Order Placement API with Inventory Verification",
            "timestamp": currentTime
        };
    }
}

listener ai:Listener OrderProcessingAgentListener = new (listenOn = check http:getDefaultListener());

service /OrderProcessingAgent on OrderProcessingAgentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check _OrderProcessingAgentAgent.run(request.message, request.sessionId);
        return {message: stringResult};
    }
}

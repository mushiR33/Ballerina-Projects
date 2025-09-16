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

        // Validate the order request
        error? validationResult = validateOrderRequest(orderRequest);
        if validationResult is error {
            string validationMessage = validationResult.message();
            ErrorResponse errorResponse = {
                message: validationMessage,
                errorCode: "VALIDATION_ERROR"
            };
            return errorResponse;
        }

        // Convert request items to order items with calculated total prices
        OrderItemRequest[] requestItems = orderRequest.items;
        OrderItem[] orderItems = convertToOrderItems(requestItems);

        // Verify stock availability for all items
        StockVerificationResult|error stockVerification = verifyStockAvailability(orderItems);

        if stockVerification is error {
            string stockMessage = stockVerification.message();
            ErrorResponse errorResponse = {
                message: "Stock verification failed: " + stockMessage,
                errorCode: "INVENTORY_CHECK_ERROR"
            };
            return errorResponse;
        }

        StockVerificationResult stockResult = stockVerification;
        boolean allItemsAvailable = stockResult.allItemsAvailable;

        if !allItemsAvailable {
            string[] unavailableItems = stockResult.unavailableItems;
            string unavailableMessage = "Insufficient stock for items: " + unavailableItems.toString();
            ErrorResponse errorResponse = {
                message: unavailableMessage,
                errorCode: "INSUFFICIENT_STOCK"
            };
            return errorResponse;
        }

        // Generate unique order ID and timestamp
        string orderId = generateOrderId();
        string orderDate = getCurrentTimestamp();

        // Calculate total amount from converted order items
        decimal totalAmount = calculateTotalAmount(orderItems);

        // Create order record
        string customerId = orderRequest.customerId;
        string customerName = orderRequest.customerName;
        Order newOrder = {
            orderId: orderId,
            customerId: customerId,
            customerName: customerName,
            items: orderItems,
            totalAmount: totalAmount,
            orderDate: orderDate,
            status: "PENDING"
        };

        // Insert order into database
        string|error insertResult = insertOrder(newOrder);

        if insertResult is error {
            string insertMessage = insertResult.message();
            http:InternalServerError internalError = {
                body: {
                    message: "Failed to place order: " + insertMessage,
                    errorCode: "DATABASE_ERROR"
                }
            };
            return internalError;
        }

        // Call inventory service to update inventory after successful order placement
        error? inventoryUpdateResult = callInventoryUpdateService(orderId, orderItems);

        if inventoryUpdateResult is error {
            string inventoryMessage = inventoryUpdateResult.message();
            http:InternalServerError internalError = {
                body: {
                    message: "Order placed but inventory update failed: " + inventoryMessage,
                    errorCode: "INVENTORY_SERVICE_ERROR"
                }
            };
            return internalError;
        }

        // Return success response
        OrderResponse response = {
            orderId: orderId,
            message: "Order placed successfully with inventory updated via service",
            status: "PENDING",
            totalAmount: totalAmount
        };

        return response;
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
            "inventoryService": inventoryServiceUrl,
            "timestamp": currentTime
        };
    }
}
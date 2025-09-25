import ballerina/http;
import ballerina/log;
import ballerina/sql;
import ballerina/uuid;

// Generate unique order ID using UUID Type 1 with ORD- prefix
public isolated function generateOrderId() returns string {
    string uuidString = uuid:createType1AsString();
    return "ORD-" + uuidString;
}

// Calculate total price for a single item
public isolated function calculateItemTotalPrice(int quantity, decimal unitPrice) returns decimal {
    decimal quantityDecimal = <decimal>quantity;
    return quantityDecimal * unitPrice;
}

// Convert OrderItemRequest to OrderItem with calculated total price
public isolated function convertToOrderItem(OrderItemRequest requestItem) returns OrderItem {
    string productId = requestItem.productId;
    string productName = requestItem.productName;
    int quantity = requestItem.quantity;
    decimal unitPrice = requestItem.unitPrice;
    decimal totalPrice = calculateItemTotalPrice(quantity, unitPrice);

    OrderItem orderItem = {
        productId: productId,
        productName: productName,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice
    };

    return orderItem;
}

// Convert array of OrderItemRequest to OrderItem array
public isolated function convertToOrderItems(OrderItemRequest[] requestItems) returns OrderItem[] {
    OrderItem[] orderItems = [];

    foreach OrderItemRequest requestItem in requestItems {
        OrderItem orderItem = convertToOrderItem(requestItem);
        orderItems.push(orderItem);
    }

    return orderItems;
}

// Calculate total amount for order
public isolated function calculateTotalAmount(OrderItem[] items) returns decimal {
    decimal total = 0.0d;
    foreach OrderItem item in items {
        decimal itemTotal = item.totalPrice;
        total += itemTotal;
    }
    return total;
}

// Get current timestamp as string (simplified approach)
public isolated function getCurrentTimestamp() returns string {
    return "2024-01-01T00:00:00Z";
}

// Check inventory for a specific product
public isolated function checkProductInventory(string productId) returns InventoryItem|error {
    sql:ParameterizedQuery inventoryQuery = `
        SELECT product_id, product_name, available_quantity, reserved_quantity, unit_price, last_updated
        FROM inventory 
        WHERE product_id = ${productId}
    `;

    stream<InventoryItem, sql:Error?> inventoryStream = dbClient->query(inventoryQuery);

    record {|InventoryItem value;|}? inventoryRecord = check inventoryStream.next();
    check inventoryStream.close();

    if inventoryRecord is () {
        return error("Product not found in inventory: " + productId);
    }

    InventoryItem inventoryValue = inventoryRecord.value;
    return inventoryValue;
}

// Get order details by order ID
public isolated function getOrderById(string orderId) returns OrderWithItems|error {
    sql:ParameterizedQuery orderQuery = `
        SELECT order_id, customer_id, customer_name, total_amount, order_date, status, created_at, updated_at
        FROM orders 
        WHERE order_id = ${orderId}
    `;

    stream<OrderWithItems, sql:Error?> orderStream = dbClient->query(orderQuery);

    record {|OrderWithItems value;|}? orderRecord = check orderStream.next();
    check orderStream.close();

    if orderRecord is () {
        return error("Order not found: " + orderId);
    }

    OrderWithItems orderValue = orderRecord.value;
    return orderValue;
}

// Get order items by order ID
public isolated function getOrderItems(string orderId) returns OrderItemDetail[]|error {
    sql:ParameterizedQuery itemsQuery = `
        SELECT id, order_id, product_id, product_name, quantity, unit_price, total_price, created_at
        FROM order_items 
        WHERE order_id = ${orderId}
    `;

    stream<OrderItemDetail, sql:Error?> itemsStream = dbClient->query(itemsQuery);

    OrderItemDetail[] orderItems = [];

    record {|OrderItemDetail value;|}? itemRecord = check itemsStream.next();
    while itemRecord is record {|OrderItemDetail value;|} {
        OrderItemDetail itemValue = itemRecord.value;
        orderItems.push(itemValue);
        itemRecord = check itemsStream.next();
    }

    check itemsStream.close();
    return orderItems;
}

// Verify stock availability for all order items
public isolated function verifyStockAvailability(OrderItem[] orderItems) returns StockVerificationResult|error {
    InventoryCheckResult[] itemResults = [];
    string[] unavailableItems = [];
    boolean allItemsAvailable = true;

    foreach OrderItem orderItem in orderItems {
        string productId = orderItem.productId;
        string productName = orderItem.productName;
        int requestedQuantity = orderItem.quantity;

        InventoryItem|error inventoryResult = checkProductInventory(productId);

        if inventoryResult is error {
            string inventoryMessage = inventoryResult.message();
            InventoryCheckResult checkResult = {
                isAvailable: false,
                productId: productId,
                productName: productName,
                requestedQuantity: requestedQuantity,
                availableQuantity: 0,
                message: inventoryMessage
            };
            itemResults.push(checkResult);
            unavailableItems.push(productId + " - " + inventoryMessage);
            allItemsAvailable = false;
            continue;
        }

        InventoryItem inventory = inventoryResult;
        int availableQuantity = inventory.availableQuantity;

        if availableQuantity < requestedQuantity {
            InventoryCheckResult checkResult = {
                isAvailable: false,
                productId: productId,
                productName: productName,
                requestedQuantity: requestedQuantity,
                availableQuantity: availableQuantity,
                message: "Insufficient stock. Available: " + availableQuantity.toString() + ", Requested: " + requestedQuantity.toString()
            };
            itemResults.push(checkResult);
            unavailableItems.push(productId + " - Insufficient stock");
            allItemsAvailable = false;
        } else {
            InventoryCheckResult checkResult = {
                isAvailable: true,
                productId: productId,
                productName: productName,
                requestedQuantity: requestedQuantity,
                availableQuantity: availableQuantity,
                message: "Stock available"
            };
            itemResults.push(checkResult);
        }
    }

    StockVerificationResult verificationResult = {
        allItemsAvailable: allItemsAvailable,
        itemResults: itemResults,
        unavailableItems: unavailableItems
    };

    return verificationResult;
}

// Call inventory service to update inventory after order placement
public isolated function callInventoryUpdateService(string orderId, OrderItem[] orderItems) returns error? {
    InventoryUpdateRequest updateRequest = {
        orderId: orderId,
        items: orderItems
    };

    InventoryUpdateResponse|http:ClientError response = inventoryServiceClient->post("/update", updateRequest);
    log:printInfo("Inventory service url: " + inventoryServiceUrl);
    if response is http:ClientError {
        string responseMessage = response.message();
        return error("Failed to call inventory service: " + responseMessage);
    }

    InventoryUpdateResponse updateResponse = response;
    string responseStatus = updateResponse.status;

    if responseStatus != "SUCCESS" {
        string responseMessage = updateResponse.message;
        return error("Inventory update failed: " + responseMessage);
    }
}

// Update inventory after successful order placement (moved to inventory service)
public function updateInventoryAfterOrder(OrderItem[] orderItems) returns error? {
    foreach OrderItem orderItem in orderItems {
        string productId = orderItem.productId;
        int orderedQuantity = orderItem.quantity;
        string currentTimestamp = getCurrentTimestamp();

        sql:ParameterizedQuery updateQuery = `
            UPDATE inventory 
            SET available_quantity = available_quantity - ${orderedQuantity},
                reserved_quantity = reserved_quantity + ${orderedQuantity},
                last_updated = ${currentTimestamp}
            WHERE product_id = ${productId}
        `;

        sql:ExecutionResult|sql:Error updateResult = dbClient->execute(updateQuery);

        if updateResult is sql:Error {
            string updateMessage = updateResult.message();
            return error("Failed to update inventory for product " + productId + ": " + updateMessage);
        }
    }
}

// Insert order into database
public isolated function insertOrder(Order orderData) returns string|error {
    string orderId = orderData.orderId;
    string customerId = orderData.customerId;
    string customerName = orderData.customerName;
    decimal totalAmount = orderData.totalAmount;
    string orderDate = orderData.orderDate;
    string status = orderData.status;

    sql:ParameterizedQuery insertOrderQuery = `
        INSERT INTO orders (order_id, customer_id, customer_name, total_amount, order_date, status)
        VALUES (${orderId}, ${customerId}, ${customerName}, 
                ${totalAmount}, ${orderDate}, ${status})
    `;

    sql:ExecutionResult|sql:Error result = dbClient->execute(insertOrderQuery);

    if result is sql:Error {
        string resultMessage = result.message();
        return error("Failed to insert order: " + resultMessage);
    }

    // Insert order items
    OrderItem[] items = orderData.items;
    foreach OrderItem item in items {
        string productId = item.productId;
        string productName = item.productName;
        int quantity = item.quantity;
        decimal unitPrice = item.unitPrice;
        decimal itemTotalPrice = item.totalPrice;

        sql:ParameterizedQuery insertItemQuery = `
            INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, total_price)
            VALUES (${orderId}, ${productId}, ${productName}, 
                    ${quantity}, ${unitPrice}, ${itemTotalPrice})
        `;

        sql:ExecutionResult|sql:Error itemResult = dbClient->execute(insertItemQuery);

        if itemResult is sql:Error {
            string itemMessage = itemResult.message();
            return error("Failed to insert order item: " + itemMessage);
        }
    }

    return orderId;
}

// Validate order request (updated to remove total price validation)
public isolated function validateOrderRequest(OrderRequest request) returns error? {
    string customerId = request.customerId;
    if customerId.trim().length() == 0 {
        return error("Customer ID is required");
    }

    string customerName = request.customerName;
    if customerName.trim().length() == 0 {
        return error("Customer name is required");
    }

    OrderItemRequest[] items = request.items;
    if items.length() == 0 {
        return error("At least one order item is required");
    }

    foreach OrderItemRequest item in items {
        string productId = item.productId;
        if productId.trim().length() == 0 {
            return error("Product ID is required for all items");
        }

        int quantity = item.quantity;
        if quantity <= 0 {
            return error("Quantity must be greater than 0");
        }

        decimal unitPrice = item.unitPrice;
        if unitPrice <= 0.0d {
            return error("Unit price must be greater than 0");
        }
    }
}

// Public function containing the POST orders resource content
public isolated function processOrderPlacement(OrderRequest orderRequest) returns OrderResponse|ErrorResponse|error {
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
        log:printError("Failed to insert order: " + insertResult.message());
        string insertMessage = insertResult.message();
        return error("Failed to place order: " + insertMessage);
    }

    // Call inventory service to update inventory after successful order placement
    error? inventoryUpdateResult = callInventoryUpdateService(orderId, orderItems);

    if inventoryUpdateResult is error {
        string inventoryMessage = inventoryUpdateResult.message();
        return error("Order placed but inventory update failed: " + inventoryMessage);
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

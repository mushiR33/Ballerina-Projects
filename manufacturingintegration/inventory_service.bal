// import ballerina/http;
 
// // Inventory management service
// @http:ServiceConfig {
//     cors: {
//         allowOrigins: ["*"],
//         allowCredentials: false,
//         allowHeaders: ["*"],
//         allowMethods: ["GET", "POST", "PUT", "OPTIONS"]
//     }
// }
// service /inventory on new http:Listener(inventoryServicePort) {

//     // Update inventory after order placement
//     resource function post update(InventoryUpdateRequest updateRequest) returns InventoryUpdateResponse|ErrorResponse|http:InternalServerError {
        
//         string orderId = updateRequest.orderId;
//         OrderItem[] orderItems = updateRequest.items;
        
//         // Update inventory for each order item
//         error? updateResult = updateInventoryAfterOrder(orderItems);
        
//         if updateResult is error {
//             string updateMessage = updateResult.message();
//             http:InternalServerError internalError = {
//                 body: {
//                     message: "Failed to update inventory: " + updateMessage,
//                     errorCode: "INVENTORY_UPDATE_ERROR"
//                 }
//             };
//             return internalError;
//         }
        
//         // Return success response
//         string currentTimestamp = getCurrentTimestamp();
//         InventoryUpdateResponse response = {
//             orderId: orderId,
//             message: "Inventory updated successfully for order " + orderId,
//             status: "SUCCESS",
//             timestamp: currentTimestamp
//         };
        
//         return response;
//     }
    
//     // Get inventory for a specific product
//     resource function get products/[string productId]() returns InventoryItem|ErrorResponse|http:InternalServerError {
//         InventoryItem|error inventoryResult = checkProductInventory(productId);

//         if inventoryResult is error {
//             string inventoryMessage = inventoryResult.message();
//             ErrorResponse errorResponse = {
//                 message: inventoryMessage,
//                 errorCode: "PRODUCT_NOT_FOUND"
//             };
//             return errorResponse;
//         }

//         return inventoryResult;
//     }
    
//     // Health check endpoint for inventory service
//     resource function get health() returns map<string> {
//         string currentTime = getCurrentTimestamp();
//         return {
//             "status": "UP",
//             "service": "Inventory Management Service",
//             "port": inventoryServicePort.toString(),
//             "timestamp": currentTime
//         };
//     }
// }
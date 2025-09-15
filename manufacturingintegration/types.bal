import ballerina/sql;

// Order item request for API input (no total price field)
public type OrderItemRequest record {|
    string productId;
    string productName;
    int quantity;
    decimal unitPrice;
|};

// Order item details with SQL column mapping for order_items table
public type OrderItem record {|
    @sql:Column {name: "product_id"}
    string productId;
    
    @sql:Column {name: "product_name"}
    string productName;
    
    @sql:Column {name: "quantity"}
    int quantity;
    
    @sql:Column {name: "unit_price"}
    decimal unitPrice;
    
    @sql:Column {name: "total_price"}
    decimal totalPrice;
|};

// Main order record with SQL column mapping for orders table
public type Order record {|
    @sql:Column {name: "order_id"}
    string orderId;
    
    @sql:Column {name: "customer_id"}
    string customerId;
    
    @sql:Column {name: "customer_name"}
    string customerName;
    
    OrderItem[] items;
    
    @sql:Column {name: "total_amount"}
    decimal totalAmount;
    
    @sql:Column {name: "order_date"}
    string orderDate;
    
    @sql:Column {name: "status"}
    string status;
|};

// Order placement request (API only - no SQL mapping needed)
public type OrderRequest record {|
    string customerId;
    string customerName;
    OrderItemRequest[] items;
|};

// Order response (API only - no SQL mapping needed)
public type OrderResponse record {|
    string orderId;
    string message;
    string status;
    decimal totalAmount;
|};

// Error response (API only - no SQL mapping needed)
public type ErrorResponse record {|
    string message;
    string errorCode;
|};

// Inventory update request for service communication
public type InventoryUpdateRequest record {|
    string orderId;
    OrderItem[] items;
|};

// Inventory update response for service communication
public type InventoryUpdateResponse record {|
    string orderId;
    string message;
    string status;
    string timestamp;
|};

// Inventory record for stock checking with proper SQL column mapping
public type InventoryItem record {|
    @sql:Column {name: "product_id"}
    string productId;
    
    @sql:Column {name: "product_name"}
    string productName;
    
    @sql:Column {name: "available_quantity"}
    int availableQuantity;
    
    @sql:Column {name: "reserved_quantity"}
    int reservedQuantity;
    
    @sql:Column {name: "unit_price"}
    decimal unitPrice;
    
    @sql:Column {name: "last_updated"}
    string lastUpdated;
|};

// Inventory check result (internal processing - no SQL mapping needed)
public type InventoryCheckResult record {|
    boolean isAvailable;
    string productId;
    string productName;
    int requestedQuantity;
    int availableQuantity;
    string message;
|};

// Stock verification response (internal processing - no SQL mapping needed)
public type StockVerificationResult record {|
    boolean allItemsAvailable;
    InventoryCheckResult[] itemResults;
    string[] unavailableItems;
|};

// Database record for retrieving order details with items
public type OrderWithItems record {|
    @sql:Column {name: "order_id"}
    string orderId;
    
    @sql:Column {name: "customer_id"}
    string customerId;
    
    @sql:Column {name: "customer_name"}
    string customerName;
    
    @sql:Column {name: "total_amount"}
    decimal totalAmount;
    
    @sql:Column {name: "order_date"}
    string orderDate;
    
    @sql:Column {name: "status"}
    string status;
    
    @sql:Column {name: "created_at"}
    string createdAt;
    
    @sql:Column {name: "updated_at"}
    string updatedAt;
|};

// Database record for retrieving individual order items
public type OrderItemDetail record {|
    @sql:Column {name: "id"}
    int id;
    
    @sql:Column {name: "order_id"}
    string orderId;
    
    @sql:Column {name: "product_id"}
    string productId;
    
    @sql:Column {name: "product_name"}
    string productName;
    
    @sql:Column {name: "quantity"}
    int quantity;
    
    @sql:Column {name: "unit_price"}
    decimal unitPrice;
    
    @sql:Column {name: "total_price"}
    decimal totalPrice;
    
    @sql:Column {name: "created_at"}
    string createdAt;
|};
CREATE DATABASE `order_management` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `order_management`;

-- order_management.inventory definition

CREATE TABLE `inventory` (
  `product_id` varchar(50) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `available_quantity` int NOT NULL DEFAULT '0',
  `reserved_quantity` int NOT NULL DEFAULT '0',
  `unit_price` decimal(10,2) NOT NULL,
  `last_updated` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`),
  KEY `idx_inventory_available_qty` (`available_quantity`),
  CONSTRAINT `chk_available_quantity` CHECK ((`available_quantity` >= 0)),
  CONSTRAINT `chk_reserved_quantity` CHECK ((`reserved_quantity` >= 0)),
  CONSTRAINT `chk_unit_price` CHECK ((`unit_price` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- order_management.orders definition

CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) NOT NULL,
  `customer_id` varchar(50) NOT NULL,
  `customer_name` varchar(255) NOT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `order_date` varchar(50) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_id` (`order_id`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_order_date` (`order_date`),
  KEY `idx_status` (`status`),
  KEY `idx_orders_customer_status` (`customer_id`,`status`),
  CONSTRAINT `chk_status` CHECK ((`status` in (_utf8mb4'PENDING',_utf8mb4'CONFIRMED',_utf8mb4'PROCESSING',_utf8mb4'SHIPPED',_utf8mb4'DELIVERED',_utf8mb4'CANCELLED'))),
  CONSTRAINT `chk_total_amount` CHECK ((`total_amount` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- order_management.order_items definition

CREATE TABLE `order_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) NOT NULL,
  `product_id` varchar(50) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `total_price` decimal(12,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_order_items_composite` (`order_id`,`product_id`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `inventory` (`product_id`) ON DELETE RESTRICT,
  CONSTRAINT `chk_quantity` CHECK ((`quantity` > 0)),
  CONSTRAINT `chk_total_price` CHECK ((`total_price` >= 0)),
  CONSTRAINT `chk_unit_price_items` CHECK ((`unit_price` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;




INSERT INTO order_management.inventory (product_id,product_name,available_quantity,reserved_quantity,unit_price,last_updated,created_at,updated_at) VALUES
	 ('PG001','Tide Laundry Detergent 64oz',60,115,12.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-12 16:43:16'),
	 ('PG002','Pampers Baby Dry Diapers Size 4',200,30,24.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG003','Gillette Fusion5 Razor',60,55,18.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-12 17:06:30'),
	 ('PG004','Crest 3D White Toothpaste',300,40,4.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG005','Head & Shoulders Shampoo',155,45,7.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-12 17:06:30'),
	 ('PG006','Olay Regenerist Moisturizer',120,18,29.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG007','Charmin Ultra Soft Toilet Paper',250,35,19.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG008','Bounty Paper Towels',180,25,14.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG009','Febreze Air Freshener',160,22,3.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG010','Dawn Dish Soap',220,28,2.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27');
INSERT INTO order_management.inventory (product_id,product_name,available_quantity,reserved_quantity,unit_price,last_updated,created_at,updated_at) VALUES
	 ('PG011','Pantene Pro-V Shampoo',140,20,6.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG012','Oral-B Electric Toothbrush',80,12,89.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG013','Always Ultra Thin Pads',190,25,8.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG014','Vicks VapoRub',100,15,5.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG015','Mr. Clean Magic Eraser',200,30,4.49,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG016','Tide Pods Laundry Detergent',175,20,16.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG017','Pampers Wipes Sensitive',250,35,12.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG018','Gillette Venus Razor Women',90,10,15.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG019','Crest Pro-Health Mouthwash',130,18,6.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27'),
	 ('PG020','Head & Shoulders 2-in-1',160,22,8.99,'2024-01-01T00:00:00Z','2025-09-11 16:53:27','2025-09-11 16:53:27');
INSERT INTO order_management.order_items (order_id,product_id,product_name,quantity,unit_price,total_price,created_at) VALUES
	 ('ORD-1001','PG001','Tide Laundry Detergent 64oz',50,12.99,649.50,'2025-09-12 12:21:22'),
	 ('ORD-01f09018-3ddd-1186-87ee-e325d9db2480','PG001','Tide Laundry Detergent 64oz',20,12.99,259.80,'2025-09-12 16:37:04'),
	 ('ORD-01f09019-1b97-1ca6-864c-413d697afb1c','PG001','Tide Laundry Detergent 64oz',20,12.99,259.80,'2025-09-12 16:43:16'),
	 ('ORD-01f09019-1b97-1ca6-864c-413d697afb1c','PG003','Gillette Fusion5 Razor',15,18.99,284.85,'2025-09-12 16:43:16'),
	 ('ORD-01f09019-1b97-1ca6-864c-413d697afb1c','PG005','Head & Shoulders Shampoo',10,7.99,79.90,'2025-09-12 16:43:16'),
	 ('ORD-01f0901c-361f-1728-8077-e95378db1e67','PG003','Gillette Fusion5 Razor',15,18.99,284.85,'2025-09-12 17:05:29'),
	 ('ORD-01f0901c-361f-1728-8077-e95378db1e67','PG005','Head & Shoulders Shampoo',10,7.99,79.90,'2025-09-12 17:05:29'),
	 ('ORD-01f0901c-5a7b-14f6-9d09-8ce8e966f890','PG003','Gillette Fusion5 Razor',10,18.99,189.90,'2025-09-12 17:06:30'),
	 ('ORD-01f0901c-5a7b-14f6-9d09-8ce8e966f890','PG005','Head & Shoulders Shampoo',5,7.99,39.95,'2025-09-12 17:06:30');
INSERT INTO order_management.orders (order_id,customer_id,customer_name,total_amount,order_date,status,created_at,updated_at) VALUES
	 ('ORD-1001','C00001','Mushthaq Rumy',649.50,'2024-01-01T00:00:00Z','PENDING','2025-09-12 12:21:22','2025-09-12 12:21:22'),
	 ('ORD-01f09018-3ddd-1186-87ee-e325d9db2480','C00001','Mushthaq Rumy',259.80,'2024-01-01T00:00:00Z','PENDING','2025-09-12 16:37:04','2025-09-12 16:37:04'),
	 ('ORD-01f09019-1b97-1ca6-864c-413d697afb1c','C00001','Mushthaq Rumy',624.55,'2024-01-01T00:00:00Z','PENDING','2025-09-12 16:43:16','2025-09-12 16:43:16'),
	 ('ORD-01f0901c-361f-1728-8077-e95378db1e67','C00002','Jason Matt',364.75,'2024-01-01T00:00:00Z','PENDING','2025-09-12 17:05:29','2025-09-12 17:05:29'),
	 ('ORD-01f0901c-5a7b-14f6-9d09-8ce8e966f890','C00002','Jason Matt',229.85,'2024-01-01T00:00:00Z','PENDING','2025-09-12 17:06:30','2025-09-12 17:06:30');


-- order_management.inventory_summary source

CREATE OR REPLACE
ALGORITHM = UNDEFINED VIEW `order_management`.`inventory_summary` AS
select
    `order_management`.`inventory`.`product_id` AS `product_id`,
    `order_management`.`inventory`.`product_name` AS `product_name`,
    `order_management`.`inventory`.`available_quantity` AS `available_quantity`,
    `order_management`.`inventory`.`reserved_quantity` AS `reserved_quantity`,
    (`order_management`.`inventory`.`available_quantity` + `order_management`.`inventory`.`reserved_quantity`) AS `total_quantity`,
    `order_management`.`inventory`.`unit_price` AS `unit_price`,
    (`order_management`.`inventory`.`available_quantity` * `order_management`.`inventory`.`unit_price`) AS `available_value`,
    `order_management`.`inventory`.`last_updated` AS `last_updated`
from
    `order_management`.`inventory`;


-- order_management.order_summary source

CREATE OR REPLACE
ALGORITHM = UNDEFINED VIEW `order_management`.`order_summary` AS
select
    `o`.`order_id` AS `order_id`,
    `o`.`customer_id` AS `customer_id`,
    `o`.`customer_name` AS `customer_name`,
    `o`.`total_amount` AS `total_amount`,
    `o`.`order_date` AS `order_date`,
    `o`.`status` AS `status`,
    count(`oi`.`id`) AS `item_count`,
    sum(`oi`.`quantity`) AS `total_items`
from
    (`order_management`.`orders` `o`
left join `order_management`.`order_items` `oi` on
    ((`o`.`order_id` = `oi`.`order_id`)))
group by
    `o`.`order_id`,
    `o`.`customer_id`,
    `o`.`customer_name`,
    `o`.`total_amount`,
    `o`.`order_date`,
    `o`.`status`;



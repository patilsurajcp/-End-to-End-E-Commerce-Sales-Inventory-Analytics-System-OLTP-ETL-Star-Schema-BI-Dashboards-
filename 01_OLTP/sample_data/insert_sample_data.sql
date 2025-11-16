-- =============================================
-- Sample Data Generation Script
-- Inserts realistic sample data for testing
-- =============================================

USE ecommerce_oltp;

-- Clear existing data (in reverse order of dependencies)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE shipments;
TRUNCATE TABLE payments;
TRUNCATE TABLE inventory_transactions;
TRUNCATE TABLE inventory;
TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE products;
TRUNCATE TABLE customers;
TRUNCATE TABLE categories;
TRUNCATE TABLE suppliers;
SET FOREIGN_KEY_CHECKS = 1;

-- Insert Categories
INSERT INTO categories (category_name, description, parent_category_id) VALUES
('Electronics', 'Electronic devices and accessories', NULL),
('Computers & Laptops', 'Computers, laptops, and related accessories', NULL),
('Mobile Phones', 'Smartphones and mobile accessories', NULL),
('Home & Kitchen', 'Home appliances and kitchen items', NULL),
('Fashion', 'Clothing and fashion accessories', NULL),
('Books', 'Physical and digital books', NULL),
('Sports & Outdoors', 'Sports equipment and outdoor gear', NULL);

-- Insert Suppliers
INSERT INTO suppliers (supplier_name, contact_person, email, phone, address, city, state, country, postal_code) VALUES
('TechSupply Co.', 'John Smith', 'john@techsupply.com', '+1-555-0101', '123 Tech Street', 'San Francisco', 'CA', 'USA', '94102'),
('Global Electronics Ltd.', 'Sarah Johnson', 'sarah@globalelec.com', '+1-555-0102', '456 Commerce Ave', 'New York', 'NY', 'USA', '10001'),
('Fashion Forward Inc.', 'Michael Brown', 'michael@fashionfw.com', '+1-555-0103', '789 Fashion Blvd', 'Los Angeles', 'CA', 'USA', '90001'),
('Home Essentials Corp.', 'Emily Davis', 'emily@homeess.com', '+1-555-0104', '321 Home Lane', 'Chicago', 'IL', 'USA', '60601'),
('BookWorld Publishers', 'David Wilson', 'david@bookworld.com', '+1-555-0105', '654 Book Street', 'Boston', 'MA', 'USA', '02101');

-- Insert Products
INSERT INTO products (product_name, product_code, description, category_id, supplier_id, unit_price, cost_price, weight_kg, dimensions, status) VALUES
-- Electronics
('Wireless Bluetooth Headphones', 'ELEC-001', 'Premium noise-cancelling headphones', 1, 1, 199.99, 120.00, 0.3, '20x18x8 cm', 'Active'),
('Smart Watch Pro', 'ELEC-002', 'Fitness tracking smartwatch', 1, 1, 299.99, 180.00, 0.05, '4x4x1 cm', 'Active'),
('USB-C Charging Cable', 'ELEC-003', 'Fast charging cable 2m', 1, 2, 19.99, 8.00, 0.1, '200 cm', 'Active'),
-- Computers
('Gaming Laptop 15"', 'COMP-001', 'High-performance gaming laptop', 2, 1, 1299.99, 900.00, 2.5, '36x25x2.5 cm', 'Active'),
('Wireless Mouse', 'COMP-002', 'Ergonomic wireless mouse', 2, 1, 29.99, 12.00, 0.1, '12x6x4 cm', 'Active'),
('Mechanical Keyboard', 'COMP-003', 'RGB backlit mechanical keyboard', 2, 2, 89.99, 45.00, 1.2, '44x13x4 cm', 'Active'),
-- Mobile Phones
('Smartphone Pro Max', 'MOB-001', 'Latest flagship smartphone', 3, 2, 999.99, 650.00, 0.2, '16x8x0.8 cm', 'Active'),
('Phone Case Clear', 'MOB-002', 'Transparent protective case', 3, 2, 14.99, 5.00, 0.05, '16x8x0.3 cm', 'Active'),
('Screen Protector', 'MOB-003', 'Tempered glass screen protector', 3, 2, 9.99, 3.00, 0.02, '16x8 cm', 'Active'),
-- Home & Kitchen
('Coffee Maker Deluxe', 'HOME-001', 'Programmable coffee maker', 4, 4, 79.99, 40.00, 2.0, '25x20x30 cm', 'Active'),
('Air Fryer 5L', 'HOME-002', 'Digital air fryer with timer', 4, 4, 89.99, 50.00, 3.5, '30x30x35 cm', 'Active'),
('Stand Mixer', 'HOME-003', 'Professional stand mixer', 4, 4, 249.99, 150.00, 8.0, '35x25x40 cm', 'Active'),
-- Fashion
('Cotton T-Shirt', 'FASH-001', '100% cotton comfortable t-shirt', 5, 3, 19.99, 8.00, 0.2, 'M', 'Active'),
('Denim Jeans', 'FASH-002', 'Classic fit denim jeans', 5, 3, 49.99, 25.00, 0.5, '32x32', 'Active'),
('Running Shoes', 'FASH-003', 'Lightweight running shoes', 5, 3, 79.99, 40.00, 0.8, '42', 'Active'),
-- Books
('Data Science Handbook', 'BOOK-001', 'Comprehensive guide to data science', 6, 5, 39.99, 15.00, 0.8, '23x15x3 cm', 'Active'),
('Python Programming', 'BOOK-002', 'Learn Python from scratch', 6, 5, 29.99, 12.00, 0.6, '23x15x2 cm', 'Active'),
('SQL Mastery', 'BOOK-003', 'Advanced SQL techniques', 6, 5, 34.99, 14.00, 0.7, '23x15x2.5 cm', 'Active'),
-- Sports
('Yoga Mat Premium', 'SPORT-001', 'Non-slip yoga mat', 7, 4, 24.99, 12.00, 1.2, '183x61x0.6 cm', 'Active'),
('Dumbbell Set 10kg', 'SPORT-002', 'Adjustable dumbbell set', 7, 4, 59.99, 30.00, 10.0, '30x15x15 cm', 'Active'),
('Basketball Official', 'SPORT-003', 'Official size basketball', 7, 4, 29.99, 15.00, 0.6, '24 cm diameter', 'Active');

-- Insert Inventory
INSERT INTO inventory (product_id, quantity_on_hand, reorder_level, reorder_quantity, last_restocked_date, warehouse_location) VALUES
(1, 150, 20, 100, '2024-01-15', 'Warehouse A'),
(2, 80, 15, 50, '2024-01-20', 'Warehouse A'),
(3, 500, 50, 200, '2024-01-10', 'Warehouse B'),
(4, 25, 5, 20, '2024-01-25', 'Warehouse A'),
(5, 300, 30, 150, '2024-01-12', 'Warehouse B'),
(6, 120, 20, 80, '2024-01-18', 'Warehouse A'),
(7, 60, 10, 30, '2024-01-22', 'Warehouse A'),
(8, 800, 100, 400, '2024-01-08', 'Warehouse B'),
(9, 1000, 200, 500, '2024-01-05', 'Warehouse B'),
(10, 45, 10, 30, '2024-01-16', 'Warehouse C'),
(11, 35, 8, 25, '2024-01-19', 'Warehouse C'),
(12, 18, 5, 15, '2024-01-21', 'Warehouse C'),
(13, 400, 50, 200, '2024-01-11', 'Warehouse D'),
(14, 250, 30, 150, '2024-01-14', 'Warehouse D'),
(15, 90, 15, 60, '2024-01-17', 'Warehouse D'),
(16, 200, 25, 100, '2024-01-13', 'Warehouse E'),
(17, 300, 40, 150, '2024-01-09', 'Warehouse E'),
(18, 180, 20, 100, '2024-01-15', 'Warehouse E'),
(19, 150, 20, 100, '2024-01-16', 'Warehouse F'),
(20, 40, 8, 30, '2024-01-23', 'Warehouse F'),
(21, 120, 15, 80, '2024-01-20', 'Warehouse F');

-- Insert Customers
INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, address, city, state, country, postal_code, registration_date, status) VALUES
('Alice', 'Johnson', 'alice.johnson@email.com', '+1-555-1001', '1990-05-15', 'Female', '123 Main St', 'New York', 'NY', 'USA', '10001', '2023-01-10 10:00:00', 'Active'),
('Bob', 'Smith', 'bob.smith@email.com', '+1-555-1002', '1985-08-22', 'Male', '456 Oak Ave', 'Los Angeles', 'CA', 'USA', '90001', '2023-02-15 14:30:00', 'Active'),
('Carol', 'Williams', 'carol.williams@email.com', '+1-555-1003', '1992-11-30', 'Female', '789 Pine Rd', 'Chicago', 'IL', 'USA', '60601', '2023-03-20 09:15:00', 'Active'),
('David', 'Brown', 'david.brown@email.com', '+1-555-1004', '1988-03-18', 'Male', '321 Elm St', 'Houston', 'TX', 'USA', '77001', '2023-04-05 16:45:00', 'Active'),
('Emma', 'Davis', 'emma.davis@email.com', '+1-555-1005', '1995-07-25', 'Female', '654 Maple Dr', 'Phoenix', 'AZ', 'USA', '85001', '2023-05-12 11:20:00', 'Active'),
('Frank', 'Miller', 'frank.miller@email.com', '+1-555-1006', '1987-12-08', 'Male', '987 Cedar Ln', 'Philadelphia', 'PA', 'USA', '19101', '2023-06-18 13:00:00', 'Active'),
('Grace', 'Wilson', 'grace.wilson@email.com', '+1-555-1007', '1993-04-14', 'Female', '147 Birch Way', 'San Antonio', 'TX', 'USA', '78201', '2023-07-22 10:30:00', 'Active'),
('Henry', 'Moore', 'henry.moore@email.com', '+1-555-1008', '1989-09-03', 'Male', '258 Spruce Ct', 'San Diego', 'CA', 'USA', '92101', '2023-08-30 15:00:00', 'Active'),
('Ivy', 'Taylor', 'ivy.taylor@email.com', '+1-555-1009', '1991-01-20', 'Female', '369 Willow St', 'Dallas', 'TX', 'USA', '75201', '2023-09-10 12:00:00', 'Active'),
('Jack', 'Anderson', 'jack.anderson@email.com', '+1-555-1010', '1986-06-12', 'Male', '741 Ash Blvd', 'San Jose', 'CA', 'USA', '95101', '2023-10-15 14:00:00', 'Active');

-- Insert Orders (last 6 months of data)
INSERT INTO orders (customer_id, order_date, order_status, shipping_address, shipping_city, shipping_state, shipping_country, shipping_postal_code, total_amount, discount_amount, tax_amount, shipping_cost, payment_status, payment_method, notes) VALUES
(1, '2024-01-05 10:30:00', 'Delivered', '123 Main St', 'New York', 'NY', 'USA', '10001', 219.98, 0.00, 17.60, 5.99, 'Paid', 'Credit Card', NULL),
(2, '2024-01-08 14:20:00', 'Delivered', '456 Oak Ave', 'Los Angeles', 'CA', 'USA', '90001', 1299.99, 50.00, 100.00, 0.00, 'Paid', 'PayPal', 'Student discount applied'),
(3, '2024-01-10 09:15:00', 'Shipped', '789 Pine Rd', 'Chicago', 'IL', 'USA', '60601', 89.99, 0.00, 7.20, 4.99, 'Paid', 'Credit Card', NULL),
(4, '2024-01-12 16:45:00', 'Delivered', '321 Elm St', 'Houston', 'TX', 'USA', '77001', 999.99, 0.00, 80.00, 0.00, 'Paid', 'Credit Card', NULL),
(5, '2024-01-15 11:20:00', 'Delivered', '654 Maple Dr', 'Phoenix', 'AZ', 'USA', '85001', 79.99, 0.00, 6.40, 5.99, 'Paid', 'Debit Card', NULL),
(1, '2024-01-18 10:00:00', 'Delivered', '123 Main St', 'New York', 'NY', 'USA', '10001', 29.99, 0.00, 2.40, 4.99, 'Paid', 'Credit Card', NULL),
(6, '2024-01-20 13:00:00', 'Processing', '987 Cedar Ln', 'Philadelphia', 'PA', 'USA', '19101', 249.99, 25.00, 18.00, 7.99, 'Paid', 'Credit Card', 'VIP customer'),
(2, '2024-01-22 14:30:00', 'Shipped', '456 Oak Ave', 'Los Angeles', 'CA', 'USA', '90001', 199.99, 0.00, 16.00, 5.99, 'Paid', 'PayPal', NULL),
(7, '2024-01-25 10:30:00', 'Delivered', '147 Birch Way', 'San Antonio', 'TX', 'USA', '78201', 49.99, 0.00, 4.00, 4.99, 'Paid', 'Credit Card', NULL),
(8, '2024-01-28 15:00:00', 'Delivered', '258 Spruce Ct', 'San Diego', 'CA', 'USA', '92101', 299.99, 0.00, 24.00, 0.00, 'Paid', 'Credit Card', 'Free shipping'),
(3, '2024-02-01 09:00:00', 'Delivered', '789 Pine Rd', 'Chicago', 'IL', 'USA', '60601', 39.99, 0.00, 3.20, 4.99, 'Paid', 'Credit Card', NULL),
(4, '2024-02-03 16:00:00', 'Delivered', '321 Elm St', 'Houston', 'TX', 'USA', '77001', 19.99, 0.00, 1.60, 4.99, 'Paid', 'Credit Card', NULL),
(9, '2024-02-05 12:00:00', 'Shipped', '369 Willow St', 'Dallas', 'TX', 'USA', '75201', 79.99, 0.00, 6.40, 5.99, 'Paid', 'Credit Card', NULL),
(5, '2024-02-08 11:00:00', 'Delivered', '654 Maple Dr', 'Phoenix', 'AZ', 'USA', '85001', 89.99, 0.00, 7.20, 4.99, 'Paid', 'Debit Card', NULL),
(10, '2024-02-10 14:00:00', 'Processing', '741 Ash Blvd', 'San Jose', 'CA', 'USA', '95101', 24.99, 0.00, 2.00, 4.99, 'Paid', 'Credit Card', NULL),
(1, '2024-02-12 10:30:00', 'Delivered', '123 Main St', 'New York', 'NY', 'USA', '10001', 199.99, 20.00, 14.40, 5.99, 'Paid', 'Credit Card', 'Loyalty discount'),
(6, '2024-02-15 13:00:00', 'Delivered', '987 Cedar Ln', 'Philadelphia', 'PA', 'USA', '19101', 29.99, 0.00, 2.40, 4.99, 'Paid', 'Credit Card', NULL),
(2, '2024-02-18 14:20:00', 'Delivered', '456 Oak Ave', 'Los Angeles', 'CA', 'USA', '90001', 14.99, 0.00, 1.20, 4.99, 'Paid', 'PayPal', NULL),
(7, '2024-02-20 10:30:00', 'Shipped', '147 Birch Way', 'San Antonio', 'TX', 'USA', '78201', 34.99, 0.00, 2.80, 4.99, 'Paid', 'Credit Card', NULL),
(8, '2024-02-22 15:00:00', 'Delivered', '258 Spruce Ct', 'San Diego', 'CA', 'USA', '92101', 59.99, 0.00, 4.80, 5.99, 'Paid', 'Credit Card', NULL);

-- Insert Order Items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_percent, line_total) VALUES
(1, 1, 1, 199.99, 0, 199.99),
(1, 3, 1, 19.99, 0, 19.99),
(2, 4, 1, 1299.99, 3.85, 1250.00),
(3, 6, 1, 89.99, 0, 89.99),
(4, 7, 1, 999.99, 0, 999.99),
(5, 10, 1, 79.99, 0, 79.99),
(6, 5, 1, 29.99, 0, 29.99),
(7, 12, 1, 249.99, 10, 224.99),
(8, 1, 1, 199.99, 0, 199.99),
(9, 14, 1, 49.99, 0, 49.99),
(10, 2, 1, 299.99, 0, 299.99),
(11, 16, 1, 39.99, 0, 39.99),
(12, 13, 1, 19.99, 0, 19.99),
(13, 15, 1, 79.99, 0, 79.99),
(14, 11, 1, 89.99, 0, 89.99),
(15, 19, 1, 24.99, 0, 24.99),
(16, 1, 1, 199.99, 10, 179.99),
(17, 9, 1, 9.99, 0, 9.99),
(17, 8, 1, 14.99, 0, 14.99),
(17, 3, 1, 19.99, 0, 19.99),
(18, 8, 1, 14.99, 0, 14.99),
(19, 18, 1, 34.99, 0, 34.99),
(20, 20, 1, 59.99, 0, 59.99);

-- Insert Inventory Transactions
INSERT INTO inventory_transactions (product_id, transaction_type, quantity_change, quantity_after, reference_order_id, notes) VALUES
(1, 'Sale', -1, 149, 1, 'Order #1'),
(3, 'Sale', -1, 499, 1, 'Order #1'),
(4, 'Sale', -1, 24, 2, 'Order #2'),
(6, 'Sale', -1, 119, 3, 'Order #3'),
(7, 'Sale', -1, 59, 4, 'Order #4'),
(10, 'Sale', -1, 44, 5, 'Order #5'),
(5, 'Sale', -1, 299, 6, 'Order #6'),
(12, 'Sale', -1, 17, 7, 'Order #7'),
(1, 'Sale', -1, 148, 8, 'Order #8'),
(14, 'Sale', -1, 249, 9, 'Order #9'),
(2, 'Sale', -1, 79, 10, 'Order #10'),
(16, 'Sale', -1, 199, 11, 'Order #11'),
(13, 'Sale', -1, 399, 12, 'Order #12'),
(15, 'Sale', -1, 89, 13, 'Order #13'),
(11, 'Sale', -1, 34, 14, 'Order #14'),
(19, 'Sale', -1, 149, 15, 'Order #15'),
(1, 'Sale', -1, 147, 16, 'Order #16'),
(9, 'Sale', -1, 999, 17, 'Order #17'),
(8, 'Sale', -1, 799, 17, 'Order #17'),
(3, 'Sale', -1, 498, 17, 'Order #17'),
(8, 'Sale', -1, 798, 18, 'Order #18'),
(18, 'Sale', -1, 179, 19, 'Order #19'),
(20, 'Sale', -1, 39, 20, 'Order #20');

-- Insert Payments
INSERT INTO payments (order_id, payment_date, payment_method, payment_amount, payment_status, transaction_id) VALUES
(1, '2024-01-05 10:31:00', 'Credit Card', 243.57, 'Completed', 'TXN-001'),
(2, '2024-01-08 14:21:00', 'PayPal', 1350.00, 'Completed', 'TXN-002'),
(3, '2024-01-10 09:16:00', 'Credit Card', 102.18, 'Completed', 'TXN-003'),
(4, '2024-01-12 16:46:00', 'Credit Card', 1079.99, 'Completed', 'TXN-004'),
(5, '2024-01-15 11:21:00', 'Debit Card', 92.38, 'Completed', 'TXN-005'),
(6, '2024-01-18 10:01:00', 'Credit Card', 37.38, 'Completed', 'TXN-006'),
(7, '2024-01-20 13:01:00', 'Credit Card', 258.98, 'Completed', 'TXN-007'),
(8, '2024-01-22 14:31:00', 'PayPal', 221.98, 'Completed', 'TXN-008'),
(9, '2024-01-25 10:31:00', 'Credit Card', 58.99, 'Completed', 'TXN-009'),
(10, '2024-01-28 15:01:00', 'Credit Card', 323.99, 'Completed', 'TXN-010'),
(11, '2024-02-01 09:01:00', 'Credit Card', 48.18, 'Completed', 'TXN-011'),
(12, '2024-02-03 16:01:00', 'Credit Card', 26.58, 'Completed', 'TXN-012'),
(13, '2024-02-05 12:01:00', 'Credit Card', 92.38, 'Completed', 'TXN-013'),
(14, '2024-02-08 11:01:00', 'Debit Card', 102.18, 'Completed', 'TXN-014'),
(15, '2024-02-10 14:01:00', 'Credit Card', 31.98, 'Completed', 'TXN-015'),
(16, '2024-02-12 10:31:00', 'Credit Card', 219.78, 'Completed', 'TXN-016'),
(17, '2024-02-15 13:01:00', 'Credit Card', 37.38, 'Completed', 'TXN-017'),
(18, '2024-02-18 14:21:00', 'PayPal', 21.18, 'Completed', 'TXN-018'),
(19, '2024-02-20 10:31:00', 'Credit Card', 42.78, 'Completed', 'TXN-019'),
(20, '2024-02-22 15:01:00', 'Credit Card', 70.78, 'Completed', 'TXN-020');

-- Insert Shipments
INSERT INTO shipments (order_id, carrier_name, tracking_number, shipment_date, estimated_delivery_date, actual_delivery_date, shipment_status, shipping_cost) VALUES
(1, 'FedEx', 'FX123456789', '2024-01-06 08:00:00', '2024-01-08', '2024-01-08', 'Delivered', 5.99),
(2, 'UPS', 'UPS987654321', '2024-01-09 10:00:00', '2024-01-12', '2024-01-11', 'Delivered', 0.00),
(3, 'USPS', 'USPS456789123', '2024-01-11 09:00:00', '2024-01-15', NULL, 'In Transit', 4.99),
(4, 'FedEx', 'FX234567890', '2024-01-13 08:00:00', '2024-01-16', '2024-01-15', 'Delivered', 0.00),
(5, 'USPS', 'USPS567890234', '2024-01-16 09:00:00', '2024-01-19', '2024-01-18', 'Delivered', 5.99),
(6, 'UPS', 'UPS123456789', '2024-01-19 10:00:00', '2024-01-22', '2024-01-21', 'Delivered', 4.99),
(7, 'FedEx', 'FX345678901', '2024-01-21 08:00:00', '2024-01-24', NULL, 'In Transit', 7.99),
(8, 'USPS', 'USPS678901345', '2024-01-23 09:00:00', '2024-01-26', NULL, 'In Transit', 5.99),
(9, 'UPS', 'UPS234567890', '2024-01-26 10:00:00', '2024-01-29', '2024-01-28', 'Delivered', 4.99),
(10, 'FedEx', 'FX456789012', '2024-01-29 08:00:00', '2024-02-01', '2024-01-31', 'Delivered', 0.00),
(11, 'USPS', 'USPS789012456', '2024-02-02 09:00:00', '2024-02-05', '2024-02-04', 'Delivered', 4.99),
(12, 'UPS', 'UPS345678901', '2024-02-04 10:00:00', '2024-02-07', '2024-02-06', 'Delivered', 4.99),
(13, 'FedEx', 'FX567890123', '2024-02-06 08:00:00', '2024-02-09', NULL, 'In Transit', 5.99),
(14, 'USPS', 'USPS890123567', '2024-02-09 09:00:00', '2024-02-12', '2024-02-11', 'Delivered', 4.99),
(15, 'UPS', 'UPS456789012', '2024-02-11 10:00:00', '2024-02-14', NULL, 'In Transit', 4.99),
(16, 'FedEx', 'FX678901234', '2024-02-13 08:00:00', '2024-02-16', '2024-02-15', 'Delivered', 5.99),
(17, 'USPS', 'USPS901234678', '2024-02-16 09:00:00', '2024-02-19', '2024-02-18', 'Delivered', 4.99),
(18, 'UPS', 'UPS567890123', '2024-02-19 10:00:00', '2024-02-22', '2024-02-21', 'Delivered', 4.99),
(19, 'FedEx', 'FX789012345', '2024-02-21 08:00:00', '2024-02-24', NULL, 'In Transit', 4.99),
(20, 'USPS', 'USPS012345789', '2024-02-23 09:00:00', '2024-02-26', '2024-02-25', 'Delivered', 5.99);


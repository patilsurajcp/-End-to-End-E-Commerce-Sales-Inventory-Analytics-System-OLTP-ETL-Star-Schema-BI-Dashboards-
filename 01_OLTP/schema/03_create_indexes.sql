-- =============================================
-- Additional Indexes for Performance Optimization
-- =============================================

USE ecommerce_oltp;

-- Composite indexes for common query patterns

-- Orders: Customer and Date range queries
CREATE INDEX idx_customer_order_date ON orders(customer_id, order_date DESC);

-- Orders: Status and Date queries
CREATE INDEX idx_status_order_date ON orders(order_status, order_date DESC);

-- Order Items: Product sales analysis
CREATE INDEX idx_product_order_date ON order_items(product_id, order_id);

-- Inventory: Low stock alerts
CREATE INDEX idx_low_stock ON inventory(quantity_on_hand, reorder_level);

-- Inventory Transactions: Product history
CREATE INDEX idx_product_transaction_date ON inventory_transactions(product_id, transaction_date DESC);

-- Customers: Geographic queries
CREATE INDEX idx_customer_location ON customers(country, state, city);

-- Products: Category and status queries
CREATE INDEX idx_category_status ON products(category_id, status);


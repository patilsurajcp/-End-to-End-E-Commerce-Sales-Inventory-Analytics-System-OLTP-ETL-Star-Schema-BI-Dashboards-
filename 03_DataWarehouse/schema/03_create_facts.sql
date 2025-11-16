-- =============================================
-- Fact Tables Creation Script
-- Star Schema Facts
-- =============================================

USE ecommerce_dw;

-- =============================================
-- Fact_Sales - Sales Transaction Fact Table
-- =============================================
CREATE TABLE IF NOT EXISTS fact_sales (
    sales_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    -- Foreign Keys to Dimensions
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    supplier_key INT NOT NULL,
    location_key INT NOT NULL,
    -- Source System References
    order_id INT NOT NULL,
    order_item_id INT NOT NULL,
    -- Measures
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    discount_percent DECIMAL(5, 2) DEFAULT 0,
    line_total DECIMAL(10, 2) NOT NULL,
    cost_amount DECIMAL(10, 2) NOT NULL, -- quantity * cost_price
    profit_amount DECIMAL(10, 2) NOT NULL, -- line_total - cost_amount
    profit_margin_percent DECIMAL(5, 2), -- (profit_amount / line_total) * 100
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_cost DECIMAL(10, 2) DEFAULT 0,
    order_total DECIMAL(10, 2) NOT NULL,
    -- Attributes
    order_status VARCHAR(20),
    payment_status VARCHAR(20),
    payment_method VARCHAR(50),
    order_date TIMESTAMP NOT NULL,
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- Foreign Key Constraints
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (supplier_key) REFERENCES dim_supplier(supplier_key),
    FOREIGN KEY (location_key) REFERENCES dim_location(location_key),
    -- Indexes
    INDEX idx_date (date_key),
    INDEX idx_customer (customer_key),
    INDEX idx_product (product_key),
    INDEX idx_order (order_id),
    INDEX idx_order_date (order_date),
    INDEX idx_status (order_status, payment_status)
) ENGINE=InnoDB;

-- =============================================
-- Fact_Inventory - Inventory Snapshot Fact Table
-- =============================================
CREATE TABLE IF NOT EXISTS fact_inventory (
    inventory_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    -- Foreign Keys to Dimensions
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    supplier_key INT NOT NULL,
    location_key INT NOT NULL,
    -- Source System References
    product_id INT NOT NULL,
    -- Measures
    quantity_on_hand INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL,
    reorder_quantity INT NOT NULL,
    quantity_available INT NOT NULL, -- quantity_on_hand - reserved
    days_of_supply INT, -- Calculated based on average daily sales
    stock_value DECIMAL(12, 2) NOT NULL, -- quantity_on_hand * cost_price
    -- Status Flags
    is_low_stock BOOLEAN NOT NULL, -- quantity_on_hand <= reorder_level
    is_out_of_stock BOOLEAN NOT NULL, -- quantity_on_hand = 0
    is_overstocked BOOLEAN NOT NULL, -- quantity_on_hand > (reorder_level * 3)
    -- Attributes
    warehouse_location VARCHAR(100),
    last_restocked_date DATE,
    snapshot_date DATE NOT NULL,
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Foreign Key Constraints
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (supplier_key) REFERENCES dim_supplier(supplier_key),
    FOREIGN KEY (location_key) REFERENCES dim_location(location_key),
    -- Indexes
    INDEX idx_date (date_key),
    INDEX idx_product (product_key),
    INDEX idx_snapshot_date (snapshot_date),
    INDEX idx_low_stock (is_low_stock, snapshot_date),
    INDEX idx_out_of_stock (is_out_of_stock, snapshot_date)
) ENGINE=InnoDB;

-- =============================================
-- Fact_Inventory_Transactions - Inventory Movement Fact
-- =============================================
CREATE TABLE IF NOT EXISTS fact_inventory_transactions (
    transaction_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    -- Foreign Keys to Dimensions
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    supplier_key INT NOT NULL,
    location_key INT NOT NULL,
    -- Source System References
    transaction_id INT NOT NULL,
    reference_order_id INT NULL,
    -- Measures
    quantity_change INT NOT NULL, -- Positive for additions, negative for deductions
    quantity_before INT NOT NULL,
    quantity_after INT NOT NULL,
    transaction_value DECIMAL(10, 2), -- quantity_change * cost_price
    -- Attributes
    transaction_type VARCHAR(20) NOT NULL, -- 'Purchase', 'Sale', 'Return', 'Adjustment', 'Damage', 'Transfer'
    notes TEXT,
    transaction_date TIMESTAMP NOT NULL,
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Foreign Key Constraints
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (supplier_key) REFERENCES dim_supplier(supplier_key),
    FOREIGN KEY (location_key) REFERENCES dim_location(location_key),
    -- Indexes
    INDEX idx_date (date_key),
    INDEX idx_product (product_key),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_order (reference_order_id)
) ENGINE=InnoDB;


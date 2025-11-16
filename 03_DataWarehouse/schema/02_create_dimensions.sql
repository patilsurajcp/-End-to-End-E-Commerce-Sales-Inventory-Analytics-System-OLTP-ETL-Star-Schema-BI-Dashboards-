-- =============================================
-- Dimension Tables Creation Script
-- Star Schema Dimensions
-- =============================================

USE ecommerce_dw;

-- =============================================
-- Dim_Date - Time Dimension
-- =============================================
CREATE TABLE IF NOT EXISTS dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_of_week TINYINT NOT NULL, -- 1=Sunday, 7=Saturday
    day_name VARCHAR(10) NOT NULL,
    day_of_month TINYINT NOT NULL,
    day_of_year SMALLINT NOT NULL,
    week_of_year TINYINT NOT NULL,
    month_number TINYINT NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    quarter_number TINYINT NOT NULL,
    quarter_name VARCHAR(2) NOT NULL, -- Q1, Q2, Q3, Q4
    year_number SMALLINT NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN DEFAULT FALSE,
    holiday_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_full_date (full_date),
    INDEX idx_year_month (year_number, month_number),
    INDEX idx_year_quarter (year_number, quarter_number)
) ENGINE=InnoDB;

-- =============================================
-- Dim_Customer - Customer Dimension
-- =============================================
CREATE TABLE IF NOT EXISTS dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL, -- Source system ID
    customer_full_name VARCHAR(201) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    date_of_birth DATE,
    age INT,
    age_group VARCHAR(20), -- '18-25', '26-35', '36-45', '46-55', '56+'
    gender VARCHAR(10),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    registration_date DATE,
    customer_status VARCHAR(20),
    years_as_customer DECIMAL(5, 2),
    is_active BOOLEAN,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP NULL,
    is_current BOOLEAN DEFAULT TRUE,
    INDEX idx_customer_id (customer_id),
    INDEX idx_email (email),
    INDEX idx_location (country, state, city)
) ENGINE=InnoDB;

-- =============================================
-- Dim_Product - Product Dimension
-- =============================================
CREATE TABLE IF NOT EXISTS dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL, -- Source system ID
    product_code VARCHAR(50) NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    category_id INT,
    category_name VARCHAR(100),
    parent_category_id INT,
    parent_category_name VARCHAR(100),
    supplier_id INT,
    supplier_name VARCHAR(200),
    unit_price DECIMAL(10, 2),
    cost_price DECIMAL(10, 2),
    profit_margin DECIMAL(10, 2),
    profit_margin_percent DECIMAL(5, 2),
    weight_kg DECIMAL(8, 2),
    dimensions VARCHAR(100),
    product_status VARCHAR(20),
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP NULL,
    is_current BOOLEAN DEFAULT TRUE,
    INDEX idx_product_id (product_id),
    INDEX idx_product_code (product_code),
    INDEX idx_category (category_name),
    INDEX idx_supplier (supplier_name)
) ENGINE=InnoDB;

-- =============================================
-- Dim_Supplier - Supplier Dimension
-- =============================================
CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_key INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL, -- Source system ID
    supplier_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP NULL,
    is_current BOOLEAN DEFAULT TRUE,
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_supplier_name (supplier_name),
    INDEX idx_location (country, state)
) ENGINE=InnoDB;

-- =============================================
-- Dim_Location - Geographic Dimension
-- =============================================
CREATE TABLE IF NOT EXISTS dim_location (
    location_key INT AUTO_INCREMENT PRIMARY KEY,
    country VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50), -- Can be derived (e.g., 'West', 'East', 'Central')
    location_type VARCHAR(20), -- 'Shipping', 'Billing', 'Warehouse'
    UNIQUE KEY uk_location (country, state, city, postal_code, location_type),
    INDEX idx_location (country, state, city),
    INDEX idx_postal_code (postal_code)
) ENGINE=InnoDB;


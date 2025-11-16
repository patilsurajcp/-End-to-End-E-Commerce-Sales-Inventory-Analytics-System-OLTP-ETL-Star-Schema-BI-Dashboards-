-- =============================================
-- Data Warehouse Creation Script
-- Star Schema for Analytics
-- =============================================

-- Create Data Warehouse Database
CREATE DATABASE IF NOT EXISTS ecommerce_dw
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE ecommerce_dw;

-- Set timezone
SET time_zone = '+00:00';


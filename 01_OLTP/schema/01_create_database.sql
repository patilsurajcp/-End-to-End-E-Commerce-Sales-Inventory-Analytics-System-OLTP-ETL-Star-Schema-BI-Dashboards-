-- =============================================
-- OLTP Database Creation Script
-- E-Commerce Operational Database
-- =============================================

-- Create Database
CREATE DATABASE IF NOT EXISTS ecommerce_oltp
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE ecommerce_oltp;

-- Set timezone
SET time_zone = '+00:00';


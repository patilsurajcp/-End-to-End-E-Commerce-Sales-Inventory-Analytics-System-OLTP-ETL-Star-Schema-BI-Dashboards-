-- =============================================
-- Populate Date Dimension Script
-- Run this to populate the date dimension table
-- =============================================

USE ecommerce_dw;

-- Populate Date Dimension from 2020-01-01 to 2025-12-31
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS PopulateDateDimension(
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    DECLARE current_date DATE;
    DECLARE date_key INT;
    DECLARE day_of_week INT;
    DECLARE day_name VARCHAR(10);
    DECLARE day_of_month INT;
    DECLARE day_of_year INT;
    DECLARE week_of_year INT;
    DECLARE month_number INT;
    DECLARE month_name VARCHAR(10);
    DECLARE quarter_number INT;
    DECLARE quarter_name VARCHAR(2);
    DECLARE year_number INT;
    DECLARE is_weekend BOOLEAN;
    
    SET current_date = start_date;
    
    WHILE current_date <= end_date DO
        SET date_key = YEAR(current_date) * 10000 + MONTH(current_date) * 100 + DAY(current_date);
        SET day_of_week = DAYOFWEEK(current_date); -- 1=Sunday, 7=Saturday
        SET day_name = DAYNAME(current_date);
        SET day_of_month = DAY(current_date);
        SET day_of_year = DAYOFYEAR(current_date);
        SET week_of_year = WEEK(current_date, 1);
        SET month_number = MONTH(current_date);
        SET month_name = MONTHNAME(current_date);
        SET quarter_number = QUARTER(current_date);
        SET quarter_name = CONCAT('Q', quarter_number);
        SET year_number = YEAR(current_date);
        SET is_weekend = (day_of_week IN (1, 7)); -- Sunday or Saturday
        
        INSERT INTO dim_date (
            date_key, full_date, day_of_week, day_name, day_of_month, day_of_year,
            week_of_year, month_number, month_name, quarter_number, quarter_name,
            year_number, is_weekend, is_holiday
        ) VALUES (
            date_key, current_date, day_of_week, day_name, day_of_month, day_of_year,
            week_of_year, month_number, month_name, quarter_number, quarter_name,
            year_number, is_weekend, FALSE
        )
        ON DUPLICATE KEY UPDATE full_date = full_date;
        
        SET current_date = DATE_ADD(current_date, INTERVAL 1 DAY);
    END WHILE;
END$$

DELIMITER ;

-- Execute the procedure
CALL PopulateDateDimension('2020-01-01', '2025-12-31');

-- Drop the procedure after use (optional)
-- DROP PROCEDURE IF EXISTS PopulateDateDimension;

SELECT COUNT(*) as total_dates FROM dim_date;
SELECT MIN(full_date) as min_date, MAX(full_date) as max_date FROM dim_date;


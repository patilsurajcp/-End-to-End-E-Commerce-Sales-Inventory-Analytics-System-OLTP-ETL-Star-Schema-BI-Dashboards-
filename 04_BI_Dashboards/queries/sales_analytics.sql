-- =============================================
-- Sales Analytics Queries
-- =============================================

-- 1. Total Sales Revenue by Month
SELECT 
    d.year_number,
    d.month_number,
    d.month_name,
    COUNT(DISTINCT fs.order_id) as total_orders,
    SUM(fs.quantity) as total_quantity_sold,
    SUM(fs.line_total) as total_revenue,
    SUM(fs.profit_amount) as total_profit,
    AVG(fs.profit_margin_percent) as avg_profit_margin
FROM fact_sales fs
INNER JOIN dim_date d ON fs.date_key = d.date_key
GROUP BY d.year_number, d.month_number, d.month_name
ORDER BY d.year_number DESC, d.month_number DESC;

-- 2. Top 10 Products by Revenue
SELECT 
    dp.product_name,
    dp.category_name,
    SUM(fs.quantity) as total_quantity_sold,
    SUM(fs.line_total) as total_revenue,
    SUM(fs.profit_amount) as total_profit,
    AVG(fs.profit_margin_percent) as avg_profit_margin
FROM fact_sales fs
INNER JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY dp.product_key, dp.product_name, dp.category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 3. Sales by Customer Segment (Age Group)
SELECT 
    dc.age_group,
    COUNT(DISTINCT dc.customer_key) as customer_count,
    COUNT(DISTINCT fs.order_id) as total_orders,
    SUM(fs.line_total) as total_revenue,
    AVG(fs.line_total) as avg_order_value
FROM fact_sales fs
INNER JOIN dim_customer dc ON fs.customer_key = dc.customer_key
WHERE dc.age_group IS NOT NULL
GROUP BY dc.age_group
ORDER BY total_revenue DESC;

-- 4. Sales Performance by Region
SELECT 
    dl.region,
    dl.country,
    COUNT(DISTINCT fs.order_id) as total_orders,
    SUM(fs.line_total) as total_revenue,
    SUM(fs.profit_amount) as total_profit,
    AVG(fs.shipping_cost) as avg_shipping_cost
FROM fact_sales fs
INNER JOIN dim_location dl ON fs.location_key = dl.location_key
GROUP BY dl.region, dl.country
ORDER BY total_revenue DESC;

-- 5. Daily Sales Trend (Last 30 Days)
SELECT 
    d.full_date,
    d.day_name,
    COUNT(DISTINCT fs.order_id) as daily_orders,
    SUM(fs.line_total) as daily_revenue,
    SUM(fs.quantity) as daily_quantity_sold
FROM fact_sales fs
INNER JOIN dim_date d ON fs.date_key = d.date_key
WHERE d.full_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY d.full_date, d.day_name
ORDER BY d.full_date DESC;

-- 6. Customer Lifetime Value
SELECT 
    dc.customer_key,
    dc.customer_full_name,
    dc.email,
    COUNT(DISTINCT fs.order_id) as total_orders,
    SUM(fs.line_total) as lifetime_value,
    AVG(fs.line_total) as avg_order_value,
    MAX(d.full_date) as last_order_date,
    MIN(d.full_date) as first_order_date
FROM fact_sales fs
INNER JOIN dim_customer dc ON fs.customer_key = dc.customer_key
INNER JOIN dim_date d ON fs.date_key = d.date_key
GROUP BY dc.customer_key, dc.customer_full_name, dc.email
ORDER BY lifetime_value DESC;

-- 7. Sales by Payment Method
SELECT 
    fs.payment_method,
    COUNT(DISTINCT fs.order_id) as order_count,
    SUM(fs.line_total) as total_revenue,
    AVG(fs.line_total) as avg_order_value
FROM fact_sales fs
WHERE fs.payment_method IS NOT NULL
GROUP BY fs.payment_method
ORDER BY total_revenue DESC;

-- 8. Product Category Performance
SELECT 
    dp.category_name,
    COUNT(DISTINCT dp.product_key) as product_count,
    SUM(fs.quantity) as total_quantity_sold,
    SUM(fs.line_total) as total_revenue,
    SUM(fs.profit_amount) as total_profit,
    AVG(fs.profit_margin_percent) as avg_profit_margin
FROM fact_sales fs
INNER JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY dp.category_name
ORDER BY total_revenue DESC;


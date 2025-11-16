-- =============================================
-- Customer Analytics Queries
-- =============================================

-- 1. Customer Segmentation by Value
SELECT 
    CASE 
        WHEN lifetime_value >= 1000 THEN 'VIP'
        WHEN lifetime_value >= 500 THEN 'High Value'
        WHEN lifetime_value >= 200 THEN 'Medium Value'
        ELSE 'Low Value'
    END as customer_segment,
    COUNT(*) as customer_count,
    AVG(lifetime_value) as avg_lifetime_value,
    AVG(total_orders) as avg_orders_per_customer,
    SUM(lifetime_value) as segment_total_value
FROM (
    SELECT 
        dc.customer_key,
        COUNT(DISTINCT fs.order_id) as total_orders,
        SUM(fs.line_total) as lifetime_value
    FROM fact_sales fs
    INNER JOIN dim_customer dc ON fs.customer_key = dc.customer_key
    GROUP BY dc.customer_key
) customer_metrics
GROUP BY customer_segment
ORDER BY avg_lifetime_value DESC;

-- 2. Customer Demographics Analysis
SELECT 
    dc.gender,
    dc.age_group,
    COUNT(DISTINCT dc.customer_key) as customer_count,
    COUNT(DISTINCT fs.order_id) as total_orders,
    SUM(fs.line_total) as total_revenue,
    AVG(fs.line_total) as avg_order_value
FROM fact_sales fs
INNER JOIN dim_customer dc ON fs.customer_key = dc.customer_key
WHERE dc.gender IS NOT NULL AND dc.age_group IS NOT NULL
GROUP BY dc.gender, dc.age_group
ORDER BY total_revenue DESC;

-- 3. Top Customers by Revenue
SELECT 
    dc.customer_full_name,
    dc.email,
    dc.city,
    dc.state,
    dc.age_group,
    COUNT(DISTINCT fs.order_id) as total_orders,
    SUM(fs.line_total) as lifetime_value,
    AVG(fs.line_total) as avg_order_value,
    MAX(d.full_date) as last_order_date,
    DATEDIFF(CURDATE(), MAX(d.full_date)) as days_since_last_order
FROM fact_sales fs
INNER JOIN dim_customer dc ON fs.customer_key = dc.customer_key
INNER JOIN dim_date d ON fs.date_key = d.date_key
GROUP BY dc.customer_key, dc.customer_full_name, dc.email, dc.city, dc.state, dc.age_group
ORDER BY lifetime_value DESC
LIMIT 20;

-- 4. Customer Retention Analysis
SELECT 
    d.year_number,
    d.quarter_name,
    COUNT(DISTINCT fs.customer_key) as active_customers,
    COUNT(DISTINCT fs.order_id) as total_orders,
    COUNT(DISTINCT fs.customer_key) / NULLIF(
        LAG(COUNT(DISTINCT fs.customer_key)) OVER (ORDER BY d.year_number, d.quarter_number), 0
    ) * 100 as retention_rate_percent
FROM fact_sales fs
INNER JOIN dim_date d ON fs.date_key = d.date_key
GROUP BY d.year_number, d.quarter_number, d.quarter_name
ORDER BY d.year_number DESC, d.quarter_number DESC;

-- 5. Customer Geographic Distribution
SELECT 
    dc.country,
    dc.state,
    COUNT(DISTINCT dc.customer_key) as customer_count,
    COUNT(DISTINCT fs.order_id) as total_orders,
    SUM(fs.line_total) as total_revenue
FROM fact_sales fs
INNER JOIN dim_customer dc ON fs.customer_key = dc.customer_key
GROUP BY dc.country, dc.state
ORDER BY total_revenue DESC;

-- 6. New vs Returning Customers
SELECT 
    d.year_number,
    d.month_name,
    COUNT(DISTINCT CASE 
        WHEN first_order.first_order_date = d.full_date 
        THEN fs.customer_key 
    END) as new_customers,
    COUNT(DISTINCT CASE 
        WHEN first_order.first_order_date < d.full_date 
        THEN fs.customer_key 
    END) as returning_customers,
    COUNT(DISTINCT fs.customer_key) as total_active_customers
FROM fact_sales fs
INNER JOIN dim_date d ON fs.date_key = d.date_key
INNER JOIN (
    SELECT 
        customer_key,
        MIN(full_date) as first_order_date
    FROM fact_sales fs2
    INNER JOIN dim_date d2 ON fs2.date_key = d2.date_key
    GROUP BY customer_key
) first_order ON fs.customer_key = first_order.customer_key
GROUP BY d.year_number, d.month_number, d.month_name
ORDER BY d.year_number DESC, d.month_number DESC;

-- 7. Customer Purchase Frequency
SELECT 
    dc.customer_key,
    dc.customer_full_name,
    dc.email,
    COUNT(DISTINCT fs.order_id) as order_count,
    DATEDIFF(MAX(d.full_date), MIN(d.full_date)) as customer_lifespan_days,
    CASE 
        WHEN DATEDIFF(MAX(d.full_date), MIN(d.full_date)) > 0
        THEN COUNT(DISTINCT fs.order_id) / (DATEDIFF(MAX(d.full_date), MIN(d.full_date)) / 30.0)
        ELSE NULL
    END as orders_per_month
FROM fact_sales fs
INNER JOIN dim_customer dc ON fs.customer_key = dc.customer_key
INNER JOIN dim_date d ON fs.date_key = d.date_key
GROUP BY dc.customer_key, dc.customer_full_name, dc.email
HAVING order_count > 1
ORDER BY orders_per_month DESC;


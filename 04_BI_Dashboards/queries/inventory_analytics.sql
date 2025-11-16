-- =============================================
-- Inventory Analytics Queries
-- =============================================

-- 1. Current Inventory Status
SELECT 
    dp.product_name,
    dp.category_name,
    fi.quantity_on_hand,
    fi.reorder_level,
    fi.quantity_available,
    fi.stock_value,
    fi.is_low_stock,
    fi.is_out_of_stock,
    fi.is_overstocked,
    fi.last_restocked_date
FROM fact_inventory fi
INNER JOIN dim_product dp ON fi.product_key = dp.product_key
WHERE fi.snapshot_date = (SELECT MAX(snapshot_date) FROM fact_inventory)
ORDER BY fi.is_out_of_stock DESC, fi.is_low_stock DESC, fi.stock_value DESC;

-- 2. Low Stock Alert
SELECT 
    dp.product_name,
    dp.product_code,
    dp.category_name,
    ds.supplier_name,
    fi.quantity_on_hand,
    fi.reorder_level,
    fi.reorder_quantity,
    (fi.reorder_level - fi.quantity_on_hand) as units_below_reorder,
    fi.last_restocked_date
FROM fact_inventory fi
INNER JOIN dim_product dp ON fi.product_key = dp.product_key
INNER JOIN dim_supplier ds ON fi.supplier_key = ds.supplier_key
WHERE fi.is_low_stock = TRUE
  AND fi.snapshot_date = (SELECT MAX(snapshot_date) FROM fact_inventory)
ORDER BY units_below_reorder DESC;

-- 3. Out of Stock Products
SELECT 
    dp.product_name,
    dp.product_code,
    dp.category_name,
    ds.supplier_name,
    ds.contact_person,
    ds.email,
    ds.phone,
    fi.reorder_quantity,
    fi.last_restocked_date
FROM fact_inventory fi
INNER JOIN dim_product dp ON fi.product_key = dp.product_key
INNER JOIN dim_supplier ds ON fi.supplier_key = ds.supplier_key
WHERE fi.is_out_of_stock = TRUE
  AND fi.snapshot_date = (SELECT MAX(snapshot_date) FROM fact_inventory)
ORDER BY dp.category_name, dp.product_name;

-- 4. Inventory Value by Category
SELECT 
    dp.category_name,
    COUNT(DISTINCT fi.product_key) as product_count,
    SUM(fi.quantity_on_hand) as total_quantity,
    SUM(fi.stock_value) as total_stock_value,
    AVG(fi.stock_value) as avg_stock_value_per_product
FROM fact_inventory fi
INNER JOIN dim_product dp ON fi.product_key = dp.product_key
WHERE fi.snapshot_date = (SELECT MAX(snapshot_date) FROM fact_inventory)
GROUP BY dp.category_name
ORDER BY total_stock_value DESC;

-- 5. Overstocked Products
SELECT 
    dp.product_name,
    dp.category_name,
    fi.quantity_on_hand,
    fi.reorder_level,
    (fi.quantity_on_hand - (fi.reorder_level * 3)) as excess_quantity,
    fi.stock_value
FROM fact_inventory fi
INNER JOIN dim_product dp ON fi.product_key = dp.product_key
WHERE fi.is_overstocked = TRUE
  AND fi.snapshot_date = (SELECT MAX(snapshot_date) FROM fact_inventory)
ORDER BY excess_quantity DESC;

-- 6. Supplier Performance (Inventory)
SELECT 
    ds.supplier_name,
    COUNT(DISTINCT fi.product_key) as products_supplied,
    SUM(fi.quantity_on_hand) as total_inventory_units,
    SUM(fi.stock_value) as total_inventory_value,
    COUNT(CASE WHEN fi.is_low_stock THEN 1 END) as low_stock_items,
    COUNT(CASE WHEN fi.is_out_of_stock THEN 1 END) as out_of_stock_items
FROM fact_inventory fi
INNER JOIN dim_supplier ds ON fi.supplier_key = ds.supplier_key
WHERE fi.snapshot_date = (SELECT MAX(snapshot_date) FROM fact_inventory)
GROUP BY ds.supplier_name
ORDER BY total_inventory_value DESC;

-- 7. Inventory Turnover Analysis (requires sales data)
SELECT 
    dp.product_name,
    dp.category_name,
    fi.quantity_on_hand as current_stock,
    COALESCE(sales_data.total_sold_30d, 0) as units_sold_30d,
    CASE 
        WHEN COALESCE(sales_data.total_sold_30d, 0) > 0 
        THEN fi.quantity_on_hand / (sales_data.total_sold_30d / 30.0)
        ELSE NULL 
    END as days_of_supply,
    fi.reorder_level
FROM fact_inventory fi
INNER JOIN dim_product dp ON fi.product_key = dp.product_key
LEFT JOIN (
    SELECT 
        product_key,
        SUM(quantity) as total_sold_30d
    FROM fact_sales fs
    INNER JOIN dim_date d ON fs.date_key = d.date_key
    WHERE d.full_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY product_key
) sales_data ON fi.product_key = sales_data.product_key
WHERE fi.snapshot_date = (SELECT MAX(snapshot_date) FROM fact_inventory)
ORDER BY days_of_supply ASC NULLS LAST;


# Setup Guide - E-Commerce Analytics System

This guide will help you set up and run the complete E-Commerce Sales & Inventory Analytics System.

## Prerequisites

1. **Database Server**: MySQL 8.0+ or MariaDB 10.3+
2. **Python**: Python 3.8 or higher
3. **Database Client**: MySQL Workbench, DBeaver, or command-line MySQL client

## Step-by-Step Setup

### Step 1: Install Database Server

If you don't have MySQL installed:

**Windows:**
- Download MySQL Installer from https://dev.mysql.com/downloads/installer/
- Install MySQL Server and MySQL Workbench

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation
```

**macOS:**
```bash
brew install mysql
brew services start mysql
```

### Step 2: Create Database User (Optional but Recommended)

```sql
CREATE USER 'ecommerce_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON ecommerce_oltp.* TO 'ecommerce_user'@'localhost';
GRANT ALL PRIVILEGES ON ecommerce_dw.* TO 'ecommerce_user'@'localhost';
FLUSH PRIVILEGES;
```

### Step 3: Setup OLTP Database

1. Open MySQL client (command line or MySQL Workbench)

2. Run the OLTP schema scripts in order:
   ```bash
   mysql -u root -p < 01_OLTP/schema/01_create_database.sql
   mysql -u root -p < 01_OLTP/schema/02_create_tables.sql
   mysql -u root -p < 01_OLTP/schema/03_create_indexes.sql
   ```

3. Load sample data:
   ```bash
   mysql -u root -p < 01_OLTP/sample_data/insert_sample_data.sql
   ```

4. Verify data:
   ```sql
   USE ecommerce_oltp;
   SELECT COUNT(*) FROM customers;
   SELECT COUNT(*) FROM products;
   SELECT COUNT(*) FROM orders;
   ```

### Step 4: Setup Data Warehouse

1. Run the data warehouse schema scripts:
   ```bash
   mysql -u root -p < 03_DataWarehouse/schema/01_create_warehouse.sql
   mysql -u root -p < 03_DataWarehouse/schema/02_create_dimensions.sql
   mysql -u root -p < 03_DataWarehouse/schema/03_create_facts.sql
   ```

2. Populate Date Dimension:
   ```bash
   mysql -u root -p < 03_DataWarehouse/etl_scripts/populate_date_dimension.sql
   ```

### Step 5: Configure ETL Pipeline

1. Edit `02_ETL/etl_config.json`:
   ```json
   {
     "source_database": {
       "host": "localhost",
       "port": 3306,
       "database": "ecommerce_oltp",
       "user": "root",
       "password": "your_password"
     },
     "target_database": {
       "host": "localhost",
       "port": 3306,
       "database": "ecommerce_dw",
       "user": "root",
       "password": "your_password"
     }
   }
   ```

2. Install Python dependencies:
   ```bash
   pip install mysql-connector-python
   ```

### Step 6: Run ETL Pipeline

```bash
cd 02_ETL
python etl_pipeline.py
```

Expected output:
```
INFO - Starting Full ETL Process
INFO - Connected to source database (OLTP)
INFO - Connected to target database (Data Warehouse)
INFO - Populating Dim_Date dimension...
INFO - Loading Dim_Customer dimension...
INFO - Loading Dim_Product dimension...
INFO - Loading Dim_Supplier dimension...
INFO - Loading Dim_Location dimension...
INFO - Loading Fact_Sales fact table...
INFO - Loading Fact_Inventory fact table...
INFO - ETL Process Completed Successfully
```

### Step 7: Setup BI Dashboard

1. Install Python dependencies:
   ```bash
   cd 04_BI_Dashboards
   pip install -r requirements.txt
   ```

2. Update database configuration in `dashboard.py` (if different from ETL config):
   - The dashboard automatically reads from `../02_ETL/etl_config.json`
   - Or modify the `load_db_config()` function

3. Run the dashboard:
   ```bash
   python dashboard.py
   ```

4. Open your browser and navigate to:
   ```
   http://127.0.0.1:8050
   ```

## Verification Queries

### Verify OLTP Data
```sql
USE ecommerce_oltp;
SELECT 'Customers' as table_name, COUNT(*) as count FROM customers
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Order Items', COUNT(*) FROM order_items;
```

### Verify Data Warehouse
```sql
USE ecommerce_dw;
SELECT 'Dim_Customer' as table_name, COUNT(*) as count FROM dim_customer
UNION ALL
SELECT 'Dim_Product', COUNT(*) FROM dim_product
UNION ALL
SELECT 'Dim_Supplier', COUNT(*) FROM dim_supplier
UNION ALL
SELECT 'Dim_Date', COUNT(*) FROM dim_date
UNION ALL
SELECT 'Fact_Sales', COUNT(*) FROM fact_sales
UNION ALL
SELECT 'Fact_Inventory', COUNT(*) FROM fact_inventory;
```

### Test Analytics Query
```sql
USE ecommerce_dw;
SELECT 
    d.month_name,
    SUM(fs.line_total) as total_revenue,
    COUNT(DISTINCT fs.order_id) as total_orders
FROM fact_sales fs
INNER JOIN dim_date d ON fs.date_key = d.date_key
GROUP BY d.year_number, d.month_number, d.month_name
ORDER BY d.year_number DESC, d.month_number DESC;
```

## Troubleshooting

### Connection Errors
- Verify MySQL service is running: `sudo systemctl status mysql` (Linux) or check Services (Windows)
- Check firewall settings
- Verify username and password in config files

### ETL Errors
- Ensure OLTP database has data
- Check that date dimension is populated
- Verify foreign key relationships

### Dashboard Not Loading
- Check Python dependencies: `pip list | grep dash`
- Verify database connection in dashboard.py
- Check console for error messages

### Data Not Appearing
- Run ETL pipeline again
- Verify data exists in OLTP database
- Check dimension key mappings in ETL logs

## Next Steps

1. **Customize Sample Data**: Modify `01_OLTP/sample_data/insert_sample_data.sql` to add more realistic data
2. **Schedule ETL**: Set up cron job (Linux) or Task Scheduler (Windows) to run ETL periodically
3. **Extend Dashboards**: Add more visualizations in `dashboard.py`
4. **Add More Metrics**: Create additional SQL queries in `04_BI_Dashboards/queries/`

## Production Considerations

1. **Security**:
   - Use strong passwords
   - Limit database user privileges
   - Use SSL for database connections
   - Store credentials securely (environment variables)

2. **Performance**:
   - Add more indexes based on query patterns
   - Partition large fact tables by date
   - Consider materialized views for common queries

3. **Monitoring**:
   - Set up ETL job monitoring
   - Monitor data warehouse size
   - Track ETL execution times

4. **Backup**:
   - Regular backups of both OLTP and Data Warehouse
   - Test restore procedures

## Support

For issues or questions:
1. Check the logs: `02_ETL/etl_logs.log`
2. Review SQL error messages
3. Verify all prerequisites are installed


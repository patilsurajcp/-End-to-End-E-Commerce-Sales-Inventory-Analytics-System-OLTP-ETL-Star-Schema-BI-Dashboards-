# Quick Start Guide - Running the Project

## Prerequisites Check

Before running, ensure you have:
1. ✅ MySQL Server installed and running
2. ✅ Python 3.8+ installed
3. ✅ MySQL root password (or create a user)

## Step 1: Configure Database Connection

Edit `02_ETL/etl_config.json` and update the password fields:

```json
{
  "source_database": {
    "password": "YOUR_MYSQL_PASSWORD"
  },
  "target_database": {
    "password": "YOUR_MYSQL_PASSWORD"
  }
}
```

## Step 2: Setup Databases (First Time Only)

### Option A: Using MySQL Command Line

```bash
# Setup OLTP Database
mysql -u root -p < 01_OLTP/schema/01_create_database.sql
mysql -u root -p < 01_OLTP/schema/02_create_tables.sql
mysql -u root -p < 01_OLTP/schema/03_create_indexes.sql
mysql -u root -p < 01_OLTP/sample_data/insert_sample_data.sql

# Setup Data Warehouse
mysql -u root -p < 03_DataWarehouse/schema/01_create_warehouse.sql
mysql -u root -p < 03_DataWarehouse/schema/02_create_dimensions.sql
mysql -u root -p < 03_DataWarehouse/schema/03_create_facts.sql
mysql -u root -p < 03_DataWarehouse/etl_scripts/populate_date_dimension.sql
```

### Option B: Using MySQL Workbench

1. Open MySQL Workbench
2. Connect to your MySQL server
3. Open each SQL file in order and execute them:
   - `01_OLTP/schema/01_create_database.sql`
   - `01_OLTP/schema/02_create_tables.sql`
   - `01_OLTP/schema/03_create_indexes.sql`
   - `01_OLTP/sample_data/insert_sample_data.sql`
   - `03_DataWarehouse/schema/01_create_warehouse.sql`
   - `03_DataWarehouse/schema/02_create_dimensions.sql`
   - `03_DataWarehouse/schema/03_create_facts.sql`
   - `03_DataWarehouse/etl_scripts/populate_date_dimension.sql`

## Step 3: Install Python Dependencies

```bash
pip install mysql-connector-python dash plotly pandas dash-table
```

Or use the requirements file:
```bash
cd 04_BI_Dashboards
pip install -r requirements.txt
cd ..
```

## Step 4: Run ETL Pipeline

```bash
cd 02_ETL
python etl_pipeline.py
cd ..
```

Expected output:
```
INFO - Starting Full ETL Process
INFO - Connected to source database (OLTP)
INFO - Connected to target database (Data Warehouse)
INFO - Populating Dim_Date dimension...
INFO - Loading Dim_Customer dimension...
...
INFO - ETL Process Completed Successfully
```

## Step 5: Launch Dashboard

```bash
cd 04_BI_Dashboards
python dashboard.py
```

Then open your browser and go to:
```
http://127.0.0.1:8050
```

## Quick Run (Windows)

Use the batch file:
```bash
run_project.bat
```

## Quick Run (Python Script)

```bash
python run_project.py
```

## Troubleshooting

### "Access Denied" MySQL Error
- Check your MySQL password in `etl_config.json`
- Ensure MySQL service is running
- Try: `mysql -u root -p` to test connection

### "Module not found" Error
- Run: `pip install mysql-connector-python dash plotly pandas dash-table`

### "Database doesn't exist" Error
- Run the database setup scripts (Step 2)

### Dashboard shows "No data"
- Run the ETL pipeline first (Step 4)
- Check ETL logs: `02_ETL/etl_logs.log`

## Verify Setup

Run the test script:
```bash
python test_setup.py
```

This will verify:
- Database connections
- Data existence
- ETL data quality
- Analytics queries


# End-to-End E-Commerce Sales & Inventory Analytics System

A comprehensive analytics system featuring OLTP database, ETL pipeline, Star Schema data warehouse, and BI dashboards.

## Project Structure

```
SQL_PROJECT/
├── 01_OLTP/
│   ├── schema/
│   │   ├── 01_create_database.sql
│   │   ├── 02_create_tables.sql
│   │   └── 03_create_indexes.sql
│   └── sample_data/
│       └── insert_sample_data.sql
├── 02_ETL/
│   ├── etl_pipeline.py
│   └── etl_config.json
├── 03_DataWarehouse/
│   ├── schema/
│   │   ├── 01_create_warehouse.sql
│   │   ├── 02_create_dimensions.sql
│   │   └── 03_create_facts.sql
│   └── etl_scripts/
│       └── load_warehouse.sql
├── 04_BI_Dashboards/
│   ├── dashboard.py
│   ├── queries/
│   │   ├── sales_analytics.sql
│   │   ├── inventory_analytics.sql
│   │   └── customer_analytics.sql
│   └── requirements.txt
└── README.md
```

## Architecture Overview

### 1. OLTP (Online Transaction Processing)
- Normalized relational database for day-to-day operations
- Tables: Customers, Products, Orders, OrderItems, Inventory, Suppliers, etc.
- Optimized for transactional operations (INSERT, UPDATE, DELETE)

### 2. ETL Pipeline
- Extracts data from OLTP database
- Transforms and cleanses data
- Loads into Star Schema data warehouse
- Handles incremental updates

### 3. Star Schema Data Warehouse
- Dimensional modeling for analytics
- Fact Tables: Sales Fact, Inventory Fact
- Dimension Tables: Date, Customer, Product, Supplier, Location

### 4. BI Dashboards
- Interactive dashboards using Python (Dash/Plotly)
- Key Metrics: Sales trends, Inventory levels, Customer segmentation, Product performance

## Quick Start

For detailed setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)

### Prerequisites
- Python 3.8+
- MySQL 8.0+ or MariaDB 10.3+
- MySQL client tools

### Quick Setup

1. **Install Python Dependencies**
   ```bash
   pip install mysql-connector-python dash plotly pandas dash-table
   ```

2. **Setup Databases**
   ```bash
   # OLTP Database
   mysql -u root -p < 01_OLTP/schema/01_create_database.sql
   mysql -u root -p < 01_OLTP/schema/02_create_tables.sql
   mysql -u root -p < 01_OLTP/schema/03_create_indexes.sql
   mysql -u root -p < 01_OLTP/sample_data/insert_sample_data.sql
   
   # Data Warehouse
   mysql -u root -p < 03_DataWarehouse/schema/01_create_warehouse.sql
   mysql -u root -p < 03_DataWarehouse/schema/02_create_dimensions.sql
   mysql -u root -p < 03_DataWarehouse/schema/03_create_facts.sql
   mysql -u root -p < 03_DataWarehouse/etl_scripts/populate_date_dimension.sql
   ```

3. **Configure and Run ETL**
   - Edit `02_ETL/etl_config.json` with your database credentials
   ```bash
   cd 02_ETL
   python etl_pipeline.py
   ```

4. **Launch Dashboard**
   ```bash
   cd 04_BI_Dashboards
   python dashboard.py
   # Open http://127.0.0.1:8050 in your browser
   ```

## Key Features

- **Sales Analytics**: Revenue trends, top products, customer lifetime value
- **Inventory Analytics**: Stock levels, reorder points, supplier performance
- **Customer Analytics**: Segmentation, purchase patterns, retention metrics
- **Real-time Dashboards**: Interactive visualizations with drill-down capabilities

## Database Schema

### OLTP Schema (Normalized)
- Customers, Products, Categories, Suppliers
- Orders, OrderItems
- Inventory, InventoryTransactions
- Payments, Shipments

### Star Schema (Dimensional)
- **Fact_Sales**: Sales transactions with foreign keys to dimensions
- **Fact_Inventory**: Inventory snapshots over time
- **Dim_Date**: Time dimension with hierarchies
- **Dim_Customer**: Customer attributes
- **Dim_Product**: Product attributes
- **Dim_Supplier**: Supplier information
- **Dim_Location**: Geographic dimensions


# System Architecture Documentation

## Overview

The E-Commerce Sales & Inventory Analytics System is a comprehensive data analytics solution that follows a traditional data warehouse architecture pattern. It consists of four main components:

1. **OLTP Database** - Operational database for day-to-day transactions
2. **ETL Pipeline** - Data extraction, transformation, and loading process
3. **Data Warehouse (Star Schema)** - Dimensional model for analytics
4. **BI Dashboards** - Business intelligence visualizations

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    OLTP Database (MySQL)                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │Customers │  │ Products │  │  Orders  │  │Inventory │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                 │
│  │Categories│  │Suppliers │  │Payments  │                 │
│  └──────────┘  └──────────┘  └──────────┘                 │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ ETL Pipeline (Python)
                            │ Extract → Transform → Load
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Data Warehouse - Star Schema (MySQL)           │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │              FACT TABLES                            │    │
│  │  ┌──────────────┐      ┌──────────────────┐       │    │
│  │  │ Fact_Sales   │      │ Fact_Inventory   │       │    │
│  │  └──────────────┘      └──────────────────┘       │    │
│  └────────────────────────────────────────────────────┘    │
│                            │                                │
│  ┌────────────────────────────────────────────────────┐    │
│  │            DIMENSION TABLES                         │    │
│  │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐│    │
│  │  │ Date │  │Customer│ │Product│ │Supplier│ │Location││    │
│  │  └──────┘  └──────┘  └──────┘  └──────┘  └──────┘│    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ SQL Queries
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    BI Dashboard (Dash/Plotly)               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Sales Charts │  │ Inventory    │  │ Customer     │     │
│  │              │  │ Analytics    │  │ Analytics    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. OLTP Database (Normalized Schema)

**Purpose**: Store operational data for day-to-day e-commerce transactions

**Design Principles**:
- **Normalization**: 3NF (Third Normal Form) to eliminate redundancy
- **ACID Compliance**: Ensures data integrity for transactions
- **Optimized for**: INSERT, UPDATE, DELETE operations

**Key Tables**:
- `customers`: Customer master data
- `products`: Product catalog
- `orders`: Order headers
- `order_items`: Order line items
- `inventory`: Current stock levels
- `inventory_transactions`: Inventory movement audit trail
- `payments`: Payment records
- `shipments`: Shipping information
- `categories`: Product categories (hierarchical)
- `suppliers`: Supplier information

**Relationships**:
- One-to-Many: Customer → Orders, Product → Order Items
- Many-to-Many: Products ↔ Categories (via category_id)
- Foreign Key Constraints: Ensure referential integrity

### 2. ETL Pipeline

**Purpose**: Extract data from OLTP, transform it, and load into the data warehouse

**Process Flow**:
1. **Extract**: Read data from OLTP database
2. **Transform**:
   - Calculate derived metrics (profit, margins, age groups)
   - Handle data quality issues
   - Map to dimensional model
   - Create surrogate keys
3. **Load**: Insert into data warehouse tables

**Key Features**:
- Incremental loading support (only new/changed data)
- Dimension key lookups
- Error handling and logging
- Configurable via JSON

**ETL Steps**:
1. Populate Date Dimension (if not exists)
2. Load Dimensions (Customer, Product, Supplier, Location)
3. Load Fact Tables (Sales, Inventory)

### 3. Data Warehouse (Star Schema)

**Purpose**: Optimized schema for analytical queries and reporting

**Design Principles**:
- **Dimensional Modeling**: Star schema pattern
- **Denormalization**: Pre-joined data for faster queries
- **Optimized for**: SELECT operations (read-heavy)
- **Slowly Changing Dimensions**: Type 2 SCD support

#### Dimension Tables

**Dim_Date**:
- Time dimension with hierarchies (Year → Quarter → Month → Day)
- Pre-calculated attributes (day of week, is weekend, etc.)
- Supports time-based analysis

**Dim_Customer**:
- Customer attributes and demographics
- Calculated fields (age, age group, years as customer)
- Supports customer segmentation

**Dim_Product**:
- Product attributes and categorization
- Calculated metrics (profit margin, profit margin %)
- Supports product analysis

**Dim_Supplier**:
- Supplier information
- Geographic attributes
- Supports supplier performance analysis

**Dim_Location**:
- Geographic dimensions
- Shipping/billing locations
- Supports regional analysis

#### Fact Tables

**Fact_Sales**:
- Sales transaction facts
- Measures: quantity, revenue, profit, discounts, taxes
- Foreign keys to all dimensions
- Supports sales analytics

**Fact_Inventory**:
- Inventory snapshot facts
- Measures: quantity on hand, stock value, days of supply
- Flags: low stock, out of stock, overstocked
- Supports inventory analytics

**Fact_Inventory_Transactions**:
- Inventory movement history
- Transaction types: Purchase, Sale, Return, Adjustment
- Supports inventory movement analysis

### 4. BI Dashboards

**Purpose**: Interactive visualizations for business users

**Technology Stack**:
- **Dash**: Python web framework for dashboards
- **Plotly**: Interactive charting library
- **Pandas**: Data manipulation
- **MySQL Connector**: Database connectivity

**Dashboard Components**:
1. **Key Metrics**: Total Revenue, Orders, Profit, Avg Order Value
2. **Sales Trend**: Time series of revenue and orders
3. **Top Products**: Bar chart of best-selling products
4. **Category Analysis**: Pie chart of revenue by category
5. **Customer Segmentation**: Customer value distribution
6. **Regional Analysis**: Sales by geographic region
7. **Inventory Status**: Current stock levels and alerts

**Features**:
- Auto-refresh every 5 minutes
- Interactive charts (zoom, filter, hover)
- Responsive design
- Color-coded inventory alerts

## Data Flow

### Initial Load
1. OLTP database populated with sample data
2. ETL pipeline extracts all data
3. Dimensions loaded first (prerequisite for facts)
4. Facts loaded with foreign key references
5. Dashboard queries data warehouse

### Incremental Load
1. New transactions in OLTP
2. ETL identifies new/changed records
3. Only new data extracted and loaded
4. Dashboard reflects updated metrics

## Performance Considerations

### OLTP Optimizations
- Indexes on foreign keys
- Indexes on frequently queried columns (order_date, status)
- Composite indexes for common query patterns

### Data Warehouse Optimizations
- Star schema design for fast aggregations
- Indexes on foreign keys in fact tables
- Indexes on date keys for time-based queries
- Pre-calculated measures (profit, margins)

### Dashboard Optimizations
- Cached queries (5-minute refresh)
- Efficient SQL queries with proper joins
- Pagination for large result sets

## Scalability

### Current Limitations
- Single database instance
- No partitioning
- No distributed processing

### Future Enhancements
- **Horizontal Scaling**: Read replicas for data warehouse
- **Partitioning**: Partition fact tables by date
- **Materialized Views**: Pre-aggregated metrics
- **Data Lake Integration**: Store raw data in data lake
- **Real-time ETL**: Stream processing for near-real-time analytics

## Security

### Database Security
- User authentication and authorization
- Role-based access control (can be implemented)
- Encrypted connections (SSL/TLS)

### Application Security
- Credentials stored in config files (should use environment variables in production)
- SQL injection prevention (parameterized queries)
- Input validation

## Maintenance

### Regular Tasks
1. **ETL Execution**: Daily/hourly depending on business needs
2. **Data Quality Checks**: Verify data completeness
3. **Performance Monitoring**: Query execution times
4. **Backup**: Regular backups of both databases
5. **Index Maintenance**: Rebuild indexes if needed

### Monitoring
- ETL execution logs
- Dashboard access logs
- Database performance metrics
- Error tracking

## Extensibility

### Adding New Dimensions
1. Create dimension table in data warehouse
2. Update ETL to load dimension
3. Add foreign key to fact tables
4. Update dashboard queries

### Adding New Facts
1. Create fact table in data warehouse
2. Add ETL logic to load facts
3. Create dashboard visualizations
4. Add analytics queries

### Adding New Metrics
1. Add calculated columns to fact/dimension tables
2. Update ETL transformation logic
3. Create new dashboard components
4. Add SQL queries for new metrics


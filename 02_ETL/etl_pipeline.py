"""
ETL Pipeline for E-Commerce Analytics System
Extracts data from OLTP database and loads into Star Schema Data Warehouse
"""

import json
import logging
import mysql.connector
from mysql.connector import Error
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('etl_logs.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


class ETLPipeline:
    """Main ETL Pipeline Class"""
    
    def __init__(self, config_path: str = 'etl_config.json'):
        """Initialize ETL Pipeline with configuration"""
        self.config = self.load_config(config_path)
        self.source_conn = None
        self.target_conn = None
        
    def load_config(self, config_path: str) -> Dict:
        """Load ETL configuration from JSON file"""
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)
            logger.info(f"Configuration loaded from {config_path}")
            return config
        except FileNotFoundError:
            logger.error(f"Configuration file {config_path} not found")
            raise
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON in configuration file: {e}")
            raise
    
    def connect_databases(self):
        """Establish connections to source and target databases"""
        try:
            # Source database connection (OLTP)
            source_config = self.config['source_database']
            self.source_conn = mysql.connector.connect(
                host=source_config['host'],
                port=source_config['port'],
                database=source_config['database'],
                user=source_config['user'],
                password=source_config['password']
            )
            logger.info("Connected to source database (OLTP)")
            
            # Target database connection (Data Warehouse)
            target_config = self.config['target_database']
            self.target_conn = mysql.connector.connect(
                host=target_config['host'],
                port=target_config['port'],
                database=target_config['database'],
                user=target_config['user'],
                password=target_config['password']
            )
            logger.info("Connected to target database (Data Warehouse)")
            
        except Error as e:
            logger.error(f"Database connection error: {e}")
            raise
    
    def close_connections(self):
        """Close database connections"""
        if self.source_conn and self.source_conn.is_connected():
            self.source_conn.close()
            logger.info("Source database connection closed")
        if self.target_conn and self.target_conn.is_connected():
            self.target_conn.close()
            logger.info("Target database connection closed")
    
    def populate_dim_date(self, start_date: str = '2020-01-01', end_date: str = '2025-12-31'):
        """Populate Date Dimension table"""
        logger.info("Populating Dim_Date dimension...")
        
        cursor = self.target_conn.cursor()
        
        start = datetime.strptime(start_date, '%Y-%m-%d')
        end = datetime.strptime(end_date, '%Y-%m-%d')
        current_date = start
        
        insert_query = """
        INSERT INTO dim_date (
            date_key, full_date, day_of_week, day_name, day_of_month, day_of_year,
            week_of_year, month_number, month_name, quarter_number, quarter_name,
            year_number, is_weekend, is_holiday
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE full_date = full_date
        """
        
        records = []
        while current_date <= end:
            date_key = int(current_date.strftime('%Y%m%d'))
            day_of_week = current_date.weekday() + 1  # Monday = 1, Sunday = 7
            day_name = current_date.strftime('%A')
            quarter = (current_date.month - 1) // 3 + 1
            
            records.append((
                date_key,
                current_date.date(),
                day_of_week,
                day_name,
                current_date.day,
                current_date.timetuple().tm_yday,
                current_date.isocalendar()[1],
                current_date.month,
                current_date.strftime('%B'),
                quarter,
                f'Q{quarter}',
                current_date.year,
                day_of_week in [6, 7],  # Saturday or Sunday
                False  # Can be enhanced with holiday logic
            ))
            
            current_date += timedelta(days=1)
        
        cursor.executemany(insert_query, records)
        self.target_conn.commit()
        logger.info(f"Inserted {len(records)} records into Dim_Date")
        cursor.close()
    
    def load_dim_customer(self):
        """Load Customer Dimension from OLTP"""
        logger.info("Loading Dim_Customer dimension...")
        
        source_cursor = self.source_conn.cursor(dictionary=True)
        target_cursor = self.target_conn.cursor()
        
        # Fetch customers from source
        source_cursor.execute("""
            SELECT 
                customer_id, first_name, last_name, email, phone, date_of_birth,
                gender, city, state, country, postal_code, registration_date, status
            FROM customers
        """)
        
        customers = source_cursor.fetchall()
        
        insert_query = """
        INSERT INTO dim_customer (
            customer_id, customer_full_name, first_name, last_name, email, phone,
            date_of_birth, age, age_group, gender, city, state, country, postal_code,
            registration_date, customer_status, years_as_customer, is_active
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            customer_full_name = VALUES(customer_full_name),
            email = VALUES(email),
            city = VALUES(city),
            state = VALUES(state),
            country = VALUES(country),
            customer_status = VALUES(customer_status),
            is_active = VALUES(is_active)
        """
        
        records = []
        today = datetime.now().date()
        
        for cust in customers:
            full_name = f"{cust['first_name']} {cust['last_name']}"
            age = None
            age_group = None
            
            if cust['date_of_birth']:
                age = (today - cust['date_of_birth']).days // 365
                if age < 26:
                    age_group = '18-25'
                elif age < 36:
                    age_group = '26-35'
                elif age < 46:
                    age_group = '36-45'
                elif age < 56:
                    age_group = '46-55'
                else:
                    age_group = '56+'
            
            years_as_customer = None
            if cust['registration_date']:
                reg_date = cust['registration_date'].date() if isinstance(cust['registration_date'], datetime) else cust['registration_date']
                years_as_customer = (today - reg_date).days / 365.25
            
            records.append((
                cust['customer_id'],
                full_name,
                cust['first_name'],
                cust['last_name'],
                cust['email'],
                cust['phone'],
                cust['date_of_birth'],
                age,
                age_group,
                cust['gender'],
                cust['city'],
                cust['state'],
                cust['country'],
                cust['postal_code'],
                cust['registration_date'],
                cust['status'],
                years_as_customer,
                cust['status'] == 'Active'
            ))
        
        target_cursor.executemany(insert_query, records)
        self.target_conn.commit()
        logger.info(f"Loaded {len(records)} customers into Dim_Customer")
        
        source_cursor.close()
        target_cursor.close()
    
    def load_dim_product(self):
        """Load Product Dimension from OLTP"""
        logger.info("Loading Dim_Product dimension...")
        
        source_cursor = self.source_conn.cursor(dictionary=True)
        target_cursor = self.target_conn.cursor()
        
        source_cursor.execute("""
            SELECT 
                p.product_id, p.product_code, p.product_name, p.description,
                p.category_id, c.category_name, c.parent_category_id,
                pc.category_name as parent_category_name,
                p.supplier_id, s.supplier_name,
                p.unit_price, p.cost_price, p.weight_kg, p.dimensions, p.status
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.category_id
            LEFT JOIN categories pc ON c.parent_category_id = pc.category_id
            LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
        """)
        
        products = source_cursor.fetchall()
        
        insert_query = """
        INSERT INTO dim_product (
            product_id, product_code, product_name, description, category_id, category_name,
            parent_category_id, parent_category_name, supplier_id, supplier_name,
            unit_price, cost_price, profit_margin, profit_margin_percent,
            weight_kg, dimensions, product_status
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            product_name = VALUES(product_name),
            unit_price = VALUES(unit_price),
            cost_price = VALUES(cost_price),
            profit_margin = VALUES(profit_margin),
            profit_margin_percent = VALUES(profit_margin_percent),
            product_status = VALUES(product_status)
        """
        
        records = []
        for prod in products:
            profit_margin = prod['unit_price'] - prod['cost_price'] if prod['unit_price'] and prod['cost_price'] else 0
            profit_margin_percent = (profit_margin / prod['unit_price'] * 100) if prod['unit_price'] and prod['unit_price'] > 0 else 0
            
            records.append((
                prod['product_id'],
                prod['product_code'],
                prod['product_name'],
                prod['description'],
                prod['category_id'],
                prod['category_name'],
                prod['parent_category_id'],
                prod['parent_category_name'],
                prod['supplier_id'],
                prod['supplier_name'],
                prod['unit_price'],
                prod['cost_price'],
                profit_margin,
                profit_margin_percent,
                prod['weight_kg'],
                prod['dimensions'],
                prod['status']
            ))
        
        target_cursor.executemany(insert_query, records)
        self.target_conn.commit()
        logger.info(f"Loaded {len(records)} products into Dim_Product")
        
        source_cursor.close()
        target_cursor.close()
    
    def load_dim_supplier(self):
        """Load Supplier Dimension from OLTP"""
        logger.info("Loading Dim_Supplier dimension...")
        
        source_cursor = self.source_conn.cursor(dictionary=True)
        target_cursor = self.target_conn.cursor()
        
        source_cursor.execute("""
            SELECT supplier_id, supplier_name, contact_person, email, phone,
                   city, state, country, postal_code
            FROM suppliers
        """)
        
        suppliers = source_cursor.fetchall()
        
        insert_query = """
        INSERT INTO dim_supplier (
            supplier_id, supplier_name, contact_person, email, phone,
            city, state, country, postal_code
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            supplier_name = VALUES(supplier_name),
            contact_person = VALUES(contact_person),
            email = VALUES(email),
            phone = VALUES(phone)
        """
        
        records = [(s['supplier_id'], s['supplier_name'], s['contact_person'],
                   s['email'], s['phone'], s['city'], s['state'],
                   s['country'], s['postal_code']) for s in suppliers]
        
        target_cursor.executemany(insert_query, records)
        self.target_conn.commit()
        logger.info(f"Loaded {len(records)} suppliers into Dim_Supplier")
        
        source_cursor.close()
        target_cursor.close()
    
    def load_dim_location(self):
        """Load Location Dimension from OLTP"""
        logger.info("Loading Dim_Location dimension...")
        
        source_cursor = self.source_conn.cursor(dictionary=True)
        target_cursor = self.target_conn.cursor()
        
        # Get unique locations from orders (shipping addresses)
        source_cursor.execute("""
            SELECT DISTINCT
                shipping_country as country,
                shipping_state as state,
                shipping_city as city,
                shipping_postal_code as postal_code,
                'Shipping' as location_type
            FROM orders
            WHERE shipping_country IS NOT NULL
        """)
        
        locations = source_cursor.fetchall()
        
        insert_query = """
        INSERT INTO dim_location (
            country, state, city, postal_code, location_type, region
        ) VALUES (%s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE country = country
        """
        
        # Simple region mapping (can be enhanced)
        region_map = {
            'CA': 'West', 'OR': 'West', 'WA': 'West',
            'NY': 'East', 'MA': 'East', 'PA': 'East',
            'TX': 'South', 'FL': 'South', 'GA': 'South',
            'IL': 'Central', 'OH': 'Central', 'MI': 'Central'
        }
        
        records = []
        for loc in locations:
            region = region_map.get(loc['state'], 'Other')
            records.append((
                loc['country'],
                loc['state'],
                loc['city'],
                loc['postal_code'],
                loc['location_type'],
                region
            ))
        
        target_cursor.executemany(insert_query, records)
        self.target_conn.commit()
        logger.info(f"Loaded {len(records)} locations into Dim_Location")
        
        source_cursor.close()
        target_cursor.close()
    
    def load_fact_sales(self, incremental: bool = True):
        """Load Sales Fact Table from OLTP"""
        logger.info("Loading Fact_Sales fact table...")
        
        source_cursor = self.source_conn.cursor(dictionary=True)
        target_cursor = self.target_conn.cursor()
        
        # Get last loaded order date if incremental
        last_date = None
        if incremental:
            target_cursor.execute("SELECT MAX(order_date) as last_date FROM fact_sales")
            result = target_cursor.fetchone()
            if result and result[0]:
                last_date = result[0]
                logger.info(f"Incremental load: Loading orders after {last_date}")
        
        # Build query
        date_filter = f"AND o.order_date > '{last_date}'" if last_date else ""
        
        source_cursor.execute(f"""
            SELECT 
                o.order_id, oi.order_item_id, o.order_date, o.order_status,
                o.payment_status, o.payment_method, o.total_amount, o.tax_amount, o.shipping_cost,
                oi.product_id, oi.quantity, oi.unit_price, oi.discount_percent, oi.line_total,
                o.customer_id,
                o.shipping_country, o.shipping_state, o.shipping_city, o.shipping_postal_code,
                p.cost_price, p.supplier_id
            FROM orders o
            INNER JOIN order_items oi ON o.order_id = oi.order_id
            INNER JOIN products p ON oi.product_id = p.product_id
            WHERE 1=1 {date_filter}
            ORDER BY o.order_date
        """)
        
        sales = source_cursor.fetchall()
        
        # Get dimension key mappings
        dim_maps = self.get_dimension_mappings()
        
        insert_query = """
        INSERT INTO fact_sales (
            date_key, customer_key, product_key, supplier_key, location_key,
            order_id, order_item_id, quantity, unit_price, discount_amount, discount_percent,
            line_total, cost_amount, profit_amount, profit_margin_percent,
            tax_amount, shipping_cost, order_total, order_status, payment_status,
            payment_method, order_date
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        records = []
        for sale in sales:
            order_date = sale['order_date']
            date_key = int(order_date.strftime('%Y%m%d'))
            
            # Get dimension keys
            customer_key = dim_maps['customer'].get(sale['customer_id'])
            product_key = dim_maps['product'].get(sale['product_id'])
            supplier_key = dim_maps['supplier'].get(sale['supplier_id'])
            
            # Get location key
            location_key = self.get_location_key(
                sale['shipping_country'],
                sale['shipping_state'],
                sale['shipping_city'],
                sale['shipping_postal_code']
            )
            
            # Calculate measures
            cost_amount = sale['quantity'] * sale['cost_price']
            discount_amount = sale['line_total'] * (sale['discount_percent'] / 100)
            profit_amount = sale['line_total'] - cost_amount
            profit_margin_percent = (profit_amount / sale['line_total'] * 100) if sale['line_total'] > 0 else 0
            
            records.append((
                date_key, customer_key, product_key, supplier_key, location_key,
                sale['order_id'], sale['order_item_id'], sale['quantity'],
                sale['unit_price'], discount_amount, sale['discount_percent'],
                sale['line_total'], cost_amount, profit_amount, profit_margin_percent,
                sale['tax_amount'], sale['shipping_cost'], sale['total_amount'],
                sale['order_status'], sale['payment_status'], sale['payment_method'],
                order_date
            ))
        
        target_cursor.executemany(insert_query, records)
        self.target_conn.commit()
        logger.info(f"Loaded {len(records)} sales records into Fact_Sales")
        
        source_cursor.close()
        target_cursor.close()
    
    def load_fact_inventory(self):
        """Load Inventory Fact Table from OLTP"""
        logger.info("Loading Fact_Inventory fact table...")
        
        source_cursor = self.source_conn.cursor(dictionary=True)
        target_cursor = self.target_conn.cursor()
        
        # Get current inventory snapshot
        source_cursor.execute("""
            SELECT 
                i.product_id, i.quantity_on_hand, i.reorder_level, i.reorder_quantity,
                i.last_restocked_date, i.warehouse_location,
                p.supplier_id, p.cost_price,
                p.category_id, c.category_name
            FROM inventory i
            INNER JOIN products p ON i.product_id = p.product_id
            LEFT JOIN categories c ON p.category_id = c.category_id
        """)
        
        inventory = source_cursor.fetchall()
        
        dim_maps = self.get_dimension_mappings()
        today = datetime.now().date()
        date_key = int(today.strftime('%Y%m%d'))
        
        insert_query = """
        INSERT INTO fact_inventory (
            date_key, product_key, supplier_key, location_key,
            product_id, quantity_on_hand, reorder_level, reorder_quantity,
            quantity_available, stock_value, is_low_stock, is_out_of_stock,
            is_overstocked, warehouse_location, last_restocked_date, snapshot_date
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            quantity_on_hand = VALUES(quantity_on_hand),
            quantity_available = VALUES(quantity_available),
            stock_value = VALUES(stock_value),
            is_low_stock = VALUES(is_low_stock),
            is_out_of_stock = VALUES(is_out_of_stock),
            is_overstocked = VALUES(is_overstocked)
        """
        
        records = []
        for inv in inventory:
            product_key = dim_maps['product'].get(inv['product_id'])
            supplier_key = dim_maps['supplier'].get(inv['supplier_id'])
            location_key = 1  # Default warehouse location key
            
            quantity_available = inv['quantity_on_hand']  # Can subtract reserved quantity
            stock_value = inv['quantity_on_hand'] * inv['cost_price']
            is_low_stock = inv['quantity_on_hand'] <= inv['reorder_level']
            is_out_of_stock = inv['quantity_on_hand'] == 0
            is_overstocked = inv['quantity_on_hand'] > (inv['reorder_level'] * 3)
            
            records.append((
                date_key, product_key, supplier_key, location_key,
                inv['product_id'], inv['quantity_on_hand'], inv['reorder_level'],
                inv['reorder_quantity'], quantity_available, stock_value,
                is_low_stock, is_out_of_stock, is_overstocked,
                inv['warehouse_location'], inv['last_restocked_date'], today
            ))
        
        target_cursor.executemany(insert_query, records)
        self.target_conn.commit()
        logger.info(f"Loaded {len(records)} inventory records into Fact_Inventory")
        
        source_cursor.close()
        target_cursor.close()
    
    def get_dimension_mappings(self) -> Dict:
        """Get dimension key mappings for lookups"""
        cursor = self.target_conn.cursor()
        mappings = {}
        
        # Customer mapping
        cursor.execute("SELECT customer_key, customer_id FROM dim_customer WHERE is_current = TRUE")
        mappings['customer'] = {row[1]: row[0] for row in cursor.fetchall()}
        
        # Product mapping
        cursor.execute("SELECT product_key, product_id FROM dim_product WHERE is_current = TRUE")
        mappings['product'] = {row[1]: row[0] for row in cursor.fetchall()}
        
        # Supplier mapping
        cursor.execute("SELECT supplier_key, supplier_id FROM dim_supplier WHERE is_current = TRUE")
        mappings['supplier'] = {row[1]: row[0] for row in cursor.fetchall()}
        
        cursor.close()
        return mappings
    
    def get_location_key(self, country: str, state: str, city: str, postal_code: str) -> int:
        """Get location key or create if not exists"""
        cursor = self.target_conn.cursor()
        
        cursor.execute("""
            SELECT location_key FROM dim_location
            WHERE country = %s AND state = %s AND city = %s AND postal_code = %s
            LIMIT 1
        """, (country, state, city, postal_code))
        
        result = cursor.fetchone()
        if result:
            return result[0]
        
        # Create new location
        region_map = {'CA': 'West', 'NY': 'East', 'TX': 'South', 'IL': 'Central'}
        region = region_map.get(state, 'Other')
        
        cursor.execute("""
            INSERT INTO dim_location (country, state, city, postal_code, location_type, region)
            VALUES (%s, %s, %s, %s, 'Shipping', %s)
        """, (country, state, city, postal_code, region))
        
        self.target_conn.commit()
        return cursor.lastrowid
    
    def run_full_etl(self):
        """Execute full ETL process"""
        try:
            logger.info("=" * 60)
            logger.info("Starting Full ETL Process")
            logger.info("=" * 60)
            
            self.connect_databases()
            
            # Step 1: Populate Date Dimension
            self.populate_dim_date()
            
            # Step 2: Load Dimensions
            self.load_dim_customer()
            self.load_dim_product()
            self.load_dim_supplier()
            self.load_dim_location()
            
            # Step 3: Load Facts
            self.load_fact_sales(incremental=False)
            self.load_fact_inventory()
            
            logger.info("=" * 60)
            logger.info("ETL Process Completed Successfully")
            logger.info("=" * 60)
            
        except Exception as e:
            logger.error(f"ETL Process Failed: {e}", exc_info=True)
            raise
        finally:
            self.close_connections()


if __name__ == "__main__":
    pipeline = ETLPipeline()
    pipeline.run_full_etl()


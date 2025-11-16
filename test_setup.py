"""
Test script to verify the E-Commerce Analytics System setup
Run this after completing the setup to verify everything is working
"""

import mysql.connector
from mysql.connector import Error
import json
import sys

def test_oltp_connection():
    """Test connection to OLTP database"""
    print("Testing OLTP Database Connection...")
    try:
        with open('02_ETL/etl_config.json', 'r') as f:
            config = json.load(f)
        
        conn = mysql.connector.connect(
            host=config['source_database']['host'],
            port=config['source_database']['port'],
            database=config['source_database']['database'],
            user=config['source_database']['user'],
            password=config['source_database']['password']
        )
        
        cursor = conn.cursor()
        
        # Test queries
        tables = ['customers', 'products', 'orders', 'order_items', 'inventory']
        results = {}
        
        for table in tables:
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            results[table] = count
            print(f"  ✓ {table}: {count} records")
        
        cursor.close()
        conn.close()
        
        print("  ✓ OLTP Database: PASSED\n")
        return True, results
        
    except Error as e:
        print(f"  ✗ OLTP Database: FAILED - {e}\n")
        return False, None

def test_dw_connection():
    """Test connection to Data Warehouse"""
    print("Testing Data Warehouse Connection...")
    try:
        with open('02_ETL/etl_config.json', 'r') as f:
            config = json.load(f)
        
        conn = mysql.connector.connect(
            host=config['target_database']['host'],
            port=config['target_database']['port'],
            database=config['target_database']['database'],
            user=config['target_database']['user'],
            password=config['target_database']['password']
        )
        
        cursor = conn.cursor()
        
        # Test dimension tables
        dimensions = ['dim_date', 'dim_customer', 'dim_product', 'dim_supplier', 'dim_location']
        facts = ['fact_sales', 'fact_inventory']
        
        print("  Dimensions:")
        for dim in dimensions:
            cursor.execute(f"SELECT COUNT(*) FROM {dim}")
            count = cursor.fetchone()[0]
            print(f"    ✓ {dim}: {count} records")
        
        print("  Fact Tables:")
        for fact in facts:
            cursor.execute(f"SELECT COUNT(*) FROM {fact}")
            count = cursor.fetchone()[0]
            print(f"    ✓ {fact}: {count} records")
        
        cursor.close()
        conn.close()
        
        print("  ✓ Data Warehouse: PASSED\n")
        return True
        
    except Error as e:
        print(f"  ✗ Data Warehouse: FAILED - {e}\n")
        return False

def test_etl_data_quality():
    """Test data quality in data warehouse"""
    print("Testing Data Quality...")
    try:
        with open('02_ETL/etl_config.json', 'r') as f:
            config = json.load(f)
        
        conn = mysql.connector.connect(
            host=config['target_database']['host'],
            port=config['target_database']['port'],
            database=config['target_database']['database'],
            user=config['target_database']['user'],
            password=config['target_database']['password']
        )
        
        cursor = conn.cursor(dictionary=True)
        
        # Test 1: Check for orphaned fact records
        cursor.execute("""
            SELECT COUNT(*) as count
            FROM fact_sales fs
            LEFT JOIN dim_customer dc ON fs.customer_key = dc.customer_key
            WHERE dc.customer_key IS NULL
        """)
        orphaned = cursor.fetchone()['count']
        if orphaned == 0:
            print("  ✓ No orphaned sales records")
        else:
            print(f"  ⚠ Found {orphaned} orphaned sales records")
        
        # Test 2: Check date coverage
        cursor.execute("""
            SELECT MIN(full_date) as min_date, MAX(full_date) as max_date, COUNT(*) as count
            FROM dim_date
        """)
        date_info = cursor.fetchone()
        print(f"  ✓ Date dimension: {date_info['count']} dates from {date_info['min_date']} to {date_info['max_date']}")
        
        # Test 3: Check sales data exists
        cursor.execute("SELECT COUNT(*) as count, SUM(line_total) as total_revenue FROM fact_sales")
        sales_info = cursor.fetchone()
        if sales_info['count'] > 0:
            print(f"  ✓ Sales data: {sales_info['count']} transactions, ${sales_info['total_revenue']:,.2f} total revenue")
        else:
            print("  ⚠ No sales data found - run ETL pipeline")
        
        # Test 4: Check inventory data
        cursor.execute("SELECT COUNT(*) as count FROM fact_inventory")
        inv_count = cursor.fetchone()['count']
        if inv_count > 0:
            print(f"  ✓ Inventory data: {inv_count} products")
        else:
            print("  ⚠ No inventory data found - run ETL pipeline")
        
        cursor.close()
        conn.close()
        
        print("  ✓ Data Quality: PASSED\n")
        return True
        
    except Error as e:
        print(f"  ✗ Data Quality: FAILED - {e}\n")
        return False

def test_analytics_queries():
    """Test sample analytics queries"""
    print("Testing Analytics Queries...")
    try:
        with open('02_ETL/etl_config.json', 'r') as f:
            config = json.load(f)
        
        conn = mysql.connector.connect(
            host=config['target_database']['host'],
            port=config['target_database']['port'],
            database=config['target_database']['database'],
            user=config['target_database']['user'],
            password=config['target_database']['password']
        )
        
        cursor = conn.cursor(dictionary=True)
        
        # Test query 1: Monthly sales
        cursor.execute("""
            SELECT 
                d.month_name,
                COUNT(DISTINCT fs.order_id) as orders,
                SUM(fs.line_total) as revenue
            FROM fact_sales fs
            INNER JOIN dim_date d ON fs.date_key = d.date_key
            GROUP BY d.year_number, d.month_number, d.month_name
            ORDER BY d.year_number DESC, d.month_number DESC
            LIMIT 3
        """)
        monthly_sales = cursor.fetchall()
        if monthly_sales:
            print(f"  ✓ Monthly sales query: {len(monthly_sales)} months returned")
        else:
            print("  ⚠ Monthly sales query: No data")
        
        # Test query 2: Top products
        cursor.execute("""
            SELECT 
                dp.product_name,
                SUM(fs.line_total) as revenue
            FROM fact_sales fs
            INNER JOIN dim_product dp ON fs.product_key = dp.product_key
            GROUP BY dp.product_key, dp.product_name
            ORDER BY revenue DESC
            LIMIT 5
        """)
        top_products = cursor.fetchall()
        if top_products:
            print(f"  ✓ Top products query: {len(top_products)} products returned")
        else:
            print("  ⚠ Top products query: No data")
        
        cursor.close()
        conn.close()
        
        print("  ✓ Analytics Queries: PASSED\n")
        return True
        
    except Error as e:
        print(f"  ✗ Analytics Queries: FAILED - {e}\n")
        return False

def main():
    """Run all tests"""
    print("=" * 60)
    print("E-Commerce Analytics System - Setup Verification")
    print("=" * 60)
    print()
    
    results = []
    
    # Run tests
    oltp_ok, oltp_data = test_oltp_connection()
    results.append(("OLTP Database", oltp_ok))
    
    dw_ok = test_dw_connection()
    results.append(("Data Warehouse", dw_ok))
    
    if dw_ok:
        dq_ok = test_etl_data_quality()
        results.append(("Data Quality", dq_ok))
        
        aq_ok = test_analytics_queries()
        results.append(("Analytics Queries", aq_ok))
    
    # Summary
    print("=" * 60)
    print("Test Summary")
    print("=" * 60)
    
    passed = sum(1 for _, ok in results if ok)
    total = len(results)
    
    for test_name, ok in results:
        status = "✓ PASSED" if ok else "✗ FAILED"
        print(f"{test_name}: {status}")
    
    print()
    print(f"Total: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 All tests passed! System is ready to use.")
        print("\nNext steps:")
        print("1. Launch the dashboard: cd 04_BI_Dashboards && python dashboard.py")
        print("2. Open http://127.0.0.1:8050 in your browser")
        return 0
    else:
        print("\n⚠ Some tests failed. Please review the errors above.")
        print("Refer to SETUP_GUIDE.md for troubleshooting.")
        return 1

if __name__ == "__main__":
    sys.exit(main())


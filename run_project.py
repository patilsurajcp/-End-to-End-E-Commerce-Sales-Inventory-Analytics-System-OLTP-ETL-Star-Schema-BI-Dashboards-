"""
Project Runner Script
Automates the setup and execution of the E-Commerce Analytics System
"""

import os
import sys
import subprocess
import json
from pathlib import Path

def print_header(text):
    """Print formatted header"""
    print("\n" + "=" * 60)
    print(text)
    print("=" * 60)

def check_python_dependencies():
    """Check if required Python packages are installed"""
    print_header("Checking Python Dependencies")
    
    required_packages = {
        'mysql-connector-python': 'mysql.connector',
        'dash': 'dash',
        'plotly': 'plotly',
        'pandas': 'pandas'
    }
    
    missing = []
    for package, module in required_packages.items():
        try:
            __import__(module)
            print(f"  ✓ {package} is installed")
        except ImportError:
            print(f"  ✗ {package} is missing")
            missing.append(package)
    
    if missing:
        print(f"\n  Installing missing packages: {', '.join(missing)}")
        try:
            subprocess.check_call([sys.executable, '-m', 'pip', 'install'] + missing)
            print("  ✓ Dependencies installed successfully")
        except subprocess.CalledProcessError:
            print("  ✗ Failed to install dependencies")
            print(f"  Please run: pip install {' '.join(missing)}")
            return False
    
    return True

def check_mysql_connection():
    """Check if MySQL is accessible"""
    print_header("Checking MySQL Connection")
    
    try:
        import mysql.connector
        from mysql.connector import Error
        
        # Try to connect with default settings
        config_path = Path('02_ETL/etl_config.json')
        if config_path.exists():
            with open(config_path, 'r') as f:
                config = json.load(f)
            
            try:
                conn = mysql.connector.connect(
                    host=config['source_database']['host'],
                    port=config['source_database']['port'],
                    user=config['source_database']['user'],
                    password=config['source_database']['password']
                )
                conn.close()
                print("  ✓ MySQL connection successful")
                return True
            except Error as e:
                print(f"  ✗ MySQL connection failed: {e}")
                print("\n  Please update 02_ETL/etl_config.json with your MySQL credentials")
                return False
        else:
            print("  ⚠ ETL config file not found")
            return False
            
    except ImportError:
        print("  ✗ mysql-connector-python not installed")
        return False

def setup_databases():
    """Setup OLTP and Data Warehouse databases"""
    print_header("Setting Up Databases")
    
    config_path = Path('02_ETL/etl_config.json')
    if not config_path.exists():
        print("  ✗ ETL config file not found")
        return False
    
    with open(config_path, 'r') as f:
        config = json.load(f)
    
    try:
        import mysql.connector
        from mysql.connector import Error
        
        # Connect to MySQL
        conn = mysql.connector.connect(
            host=config['source_database']['host'],
            port=config['source_database']['port'],
            user=config['source_database']['user'],
            password=config['source_database']['password']
        )
        
        cursor = conn.cursor()
        
        # Check if databases exist
        cursor.execute("SHOW DATABASES LIKE 'ecommerce_oltp'")
        oltp_exists = cursor.fetchone() is not None
        
        cursor.execute("SHOW DATABASES LIKE 'ecommerce_dw'")
        dw_exists = cursor.fetchone() is not None
        
        if oltp_exists and dw_exists:
            print("  ✓ Databases already exist")
            cursor.close()
            conn.close()
            return True
        
        print("  ⚠ Databases need to be created")
        print("  Please run the SQL scripts manually:")
        print("    1. 01_OLTP/schema/*.sql")
        print("    2. 01_OLTP/sample_data/insert_sample_data.sql")
        print("    3. 03_DataWarehouse/schema/*.sql")
        print("    4. 03_DataWarehouse/etl_scripts/populate_date_dimension.sql")
        
        cursor.close()
        conn.close()
        return False
        
    except Error as e:
        print(f"  ✗ Database setup error: {e}")
        return False

def run_etl():
    """Run the ETL pipeline"""
    print_header("Running ETL Pipeline")
    
    etl_script = Path('02_ETL/etl_pipeline.py')
    if not etl_script.exists():
        print("  ✗ ETL script not found")
        return False
    
    try:
        os.chdir('02_ETL')
        result = subprocess.run([sys.executable, 'etl_pipeline.py'], 
                              capture_output=True, text=True)
        os.chdir('..')
        
        if result.returncode == 0:
            print("  ✓ ETL pipeline completed successfully")
            if result.stdout:
                print(result.stdout)
            return True
        else:
            print("  ✗ ETL pipeline failed")
            if result.stderr:
                print(result.stderr)
            return False
            
    except Exception as e:
        print(f"  ✗ Error running ETL: {e}")
        os.chdir('..')
        return False

def launch_dashboard():
    """Launch the BI Dashboard"""
    print_header("Launching BI Dashboard")
    
    dashboard_script = Path('04_BI_Dashboards/dashboard.py')
    if not dashboard_script.exists():
        print("  ✗ Dashboard script not found")
        return False
    
    print("  Starting dashboard server...")
    print("  Dashboard will be available at: http://127.0.0.1:8050")
    print("  Press Ctrl+C to stop the dashboard")
    print()
    
    try:
        os.chdir('04_BI_Dashboards')
        subprocess.run([sys.executable, 'dashboard.py'])
    except KeyboardInterrupt:
        print("\n  Dashboard stopped by user")
        os.chdir('..')
        return True
    except Exception as e:
        print(f"  ✗ Error launching dashboard: {e}")
        os.chdir('..')
        return False

def main():
    """Main execution flow"""
    print_header("E-Commerce Analytics System - Project Runner")
    
    # Step 1: Check dependencies
    if not check_python_dependencies():
        print("\n✗ Please install missing dependencies and try again")
        return 1
    
    # Step 2: Check MySQL connection
    if not check_mysql_connection():
        print("\n✗ Please configure MySQL connection in 02_ETL/etl_config.json")
        print("  Update the 'password' fields with your MySQL root password")
        return 1
    
    # Step 3: Check database setup
    if not setup_databases():
        print("\n⚠ Databases may need to be set up manually")
        response = input("\nDo you want to continue anyway? (y/n): ")
        if response.lower() != 'y':
            return 1
    
    # Step 4: Run ETL
    print("\n" + "=" * 60)
    response = input("Do you want to run the ETL pipeline? (y/n): ")
    if response.lower() == 'y':
        if not run_etl():
            print("\n⚠ ETL pipeline failed. You can still launch the dashboard.")
            response = input("Continue to dashboard? (y/n): ")
            if response.lower() != 'y':
                return 1
    
    # Step 5: Launch Dashboard
    print("\n" + "=" * 60)
    response = input("Do you want to launch the BI Dashboard? (y/n): ")
    if response.lower() == 'y':
        launch_dashboard()
    
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n\nProject runner stopped by user")
        sys.exit(0)


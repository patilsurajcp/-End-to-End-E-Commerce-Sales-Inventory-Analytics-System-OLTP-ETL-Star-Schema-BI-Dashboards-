@echo off
echo ============================================================
echo E-Commerce Analytics System - Project Runner
echo ============================================================
echo.

echo Step 1: Installing Python Dependencies...
pip install mysql-connector-python dash plotly pandas dash-table
echo.

echo Step 2: Checking ETL Configuration...
echo Please ensure 02_ETL\etl_config.json has your MySQL password configured
echo.

echo Step 3: Running ETL Pipeline...
cd 02_ETL
python etl_pipeline.py
cd ..
echo.

echo Step 4: Launching BI Dashboard...
echo Dashboard will be available at http://127.0.0.1:8050
echo Press Ctrl+C to stop the dashboard
echo.
cd 04_BI_Dashboards
python dashboard.py
cd ..

pause


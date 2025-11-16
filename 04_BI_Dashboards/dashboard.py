"""
E-Commerce Analytics BI Dashboard
Interactive dashboard using Dash and Plotly
"""

import dash
from dash import dcc, html, Input, Output, dash_table
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import mysql.connector
from mysql.connector import Error
import json
from datetime import datetime, timedelta
import os

# Load database configuration
def load_db_config():
    """Load database configuration from ETL config"""
    try:
        with open('../02_ETL/etl_config.json', 'r') as f:
            config = json.load(f)
        return config['target_database']
    except:
        # Default configuration
        return {
            'host': 'localhost',
            'port': 3306,
            'database': 'ecommerce_dw',
            'user': 'root',
            'password': 'your_password_here'
        }

# Database connection
def get_db_connection():
    """Create database connection"""
    config = load_db_config()
    try:
        conn = mysql.connector.connect(
            host=config['host'],
            port=config['port'],
            database=config['database'],
            user=config['user'],
            password=config['password']
        )
        return conn
    except Error as e:
        print(f"Database connection error: {e}")
        return None

# Load data functions
def load_sales_by_month():
    """Load sales data by month"""
    conn = get_db_connection()
    if not conn:
        return pd.DataFrame()
    
    query = """
    SELECT 
        d.year_number,
        d.month_number,
        d.month_name,
        CONCAT(d.year_number, '-', LPAD(d.month_number, 2, '0')) as year_month,
        COUNT(DISTINCT fs.order_id) as total_orders,
        SUM(fs.quantity) as total_quantity_sold,
        SUM(fs.line_total) as total_revenue,
        SUM(fs.profit_amount) as total_profit,
        AVG(fs.profit_margin_percent) as avg_profit_margin
    FROM fact_sales fs
    INNER JOIN dim_date d ON fs.date_key = d.date_key
    GROUP BY d.year_number, d.month_number, d.month_name
    ORDER BY d.year_number, d.month_number
    """
    
    df = pd.read_sql(query, conn)
    conn.close()
    return df

def load_top_products():
    """Load top products by revenue"""
    conn = get_db_connection()
    if not conn:
        return pd.DataFrame()
    
    query = """
    SELECT 
        dp.product_name,
        dp.category_name,
        SUM(fs.quantity) as total_quantity_sold,
        SUM(fs.line_total) as total_revenue,
        SUM(fs.profit_amount) as total_profit
    FROM fact_sales fs
    INNER JOIN dim_product dp ON fs.product_key = dp.product_key
    GROUP BY dp.product_key, dp.product_name, dp.category_name
    ORDER BY total_revenue DESC
    LIMIT 10
    """
    
    df = pd.read_sql(query, conn)
    conn.close()
    return df

def load_sales_by_category():
    """Load sales by product category"""
    conn = get_db_connection()
    if not conn:
        return pd.DataFrame()
    
    query = """
    SELECT 
        dp.category_name,
        SUM(fs.quantity) as total_quantity_sold,
        SUM(fs.line_total) as total_revenue,
        SUM(fs.profit_amount) as total_profit
    FROM fact_sales fs
    INNER JOIN dim_product dp ON fs.product_key = dp.product_key
    GROUP BY dp.category_name
    ORDER BY total_revenue DESC
    """
    
    df = pd.read_sql(query, conn)
    conn.close()
    return df

def load_customer_segments():
    """Load customer segmentation data"""
    conn = get_db_connection()
    if not conn:
        return pd.DataFrame()
    
    query = """
    SELECT 
        CASE 
            WHEN lifetime_value >= 1000 THEN 'VIP'
            WHEN lifetime_value >= 500 THEN 'High Value'
            WHEN lifetime_value >= 200 THEN 'Medium Value'
            ELSE 'Low Value'
        END as customer_segment,
        COUNT(*) as customer_count,
        AVG(lifetime_value) as avg_lifetime_value
    FROM (
        SELECT 
            dc.customer_key,
            SUM(fs.line_total) as lifetime_value
        FROM fact_sales fs
        INNER JOIN dim_customer dc ON fs.customer_key = dc.customer_key
        GROUP BY dc.customer_key
    ) customer_metrics
    GROUP BY customer_segment
    ORDER BY avg_lifetime_value DESC
    """
    
    df = pd.read_sql(query, conn)
    conn.close()
    return df

def load_inventory_status():
    """Load current inventory status"""
    conn = get_db_connection()
    if not conn:
        return pd.DataFrame()
    
    query = """
    SELECT 
        dp.product_name,
        dp.category_name,
        fi.quantity_on_hand,
        fi.reorder_level,
        fi.stock_value,
        fi.is_low_stock,
        fi.is_out_of_stock
    FROM fact_inventory fi
    INNER JOIN dim_product dp ON fi.product_key = dp.product_key
    WHERE fi.snapshot_date = (SELECT MAX(snapshot_date) FROM fact_inventory)
    ORDER BY fi.stock_value DESC
    LIMIT 20
    """
    
    df = pd.read_sql(query, conn)
    conn.close()
    return df

def load_sales_by_region():
    """Load sales by geographic region"""
    conn = get_db_connection()
    if not conn:
        return pd.DataFrame()
    
    query = """
    SELECT 
        dl.region,
        dl.country,
        COUNT(DISTINCT fs.order_id) as total_orders,
        SUM(fs.line_total) as total_revenue,
        SUM(fs.profit_amount) as total_profit
    FROM fact_sales fs
    INNER JOIN dim_location dl ON fs.location_key = dl.location_key
    GROUP BY dl.region, dl.country
    ORDER BY total_revenue DESC
    """
    
    df = pd.read_sql(query, conn)
    conn.close()
    return df

# Initialize Dash app
app = dash.Dash(__name__)
app.title = "E-Commerce Analytics Dashboard"

# Define app layout
app.layout = html.Div([
    html.Div([
        html.H1("E-Commerce Sales & Inventory Analytics Dashboard", 
                style={'textAlign': 'center', 'color': '#2c3e50', 'marginBottom': '30px'}),
    ]),
    
    # Key Metrics Row
    html.Div([
        html.Div(id='key-metrics', style={'display': 'flex', 'justifyContent': 'space-around', 'marginBottom': '30px'}),
    ]),
    
    # Sales Trend Chart
    html.Div([
        html.H3("Sales Trend Over Time", style={'marginBottom': '20px'}),
        dcc.Graph(id='sales-trend-chart'),
    ], style={'marginBottom': '40px', 'padding': '20px', 'backgroundColor': '#f8f9fa', 'borderRadius': '10px'}),
    
    # Top Products and Categories Row
    html.Div([
        html.Div([
            html.H3("Top 10 Products by Revenue", style={'marginBottom': '20px'}),
            dcc.Graph(id='top-products-chart'),
        ], style={'width': '48%', 'display': 'inline-block', 'padding': '20px', 'backgroundColor': '#f8f9fa', 'borderRadius': '10px', 'marginRight': '2%'}),
        
        html.Div([
            html.H3("Sales by Category", style={'marginBottom': '20px'}),
            dcc.Graph(id='category-chart'),
        ], style={'width': '48%', 'display': 'inline-block', 'padding': '20px', 'backgroundColor': '#f8f9fa', 'borderRadius': '10px'}),
    ], style={'marginBottom': '40px'}),
    
    # Customer Segmentation and Region Row
    html.Div([
        html.Div([
            html.H3("Customer Segmentation", style={'marginBottom': '20px'}),
            dcc.Graph(id='customer-segment-chart'),
        ], style={'width': '48%', 'display': 'inline-block', 'padding': '20px', 'backgroundColor': '#f8f9fa', 'borderRadius': '10px', 'marginRight': '2%'}),
        
        html.Div([
            html.H3("Sales by Region", style={'marginBottom': '20px'}),
            dcc.Graph(id='region-chart'),
        ], style={'width': '48%', 'display': 'inline-block', 'padding': '20px', 'backgroundColor': '#f8f9fa', 'borderRadius': '10px'}),
    ], style={'marginBottom': '40px'}),
    
    # Inventory Status Table
    html.Div([
        html.H3("Current Inventory Status (Top 20)", style={'marginBottom': '20px'}),
        html.Div(id='inventory-table'),
    ], style={'marginBottom': '40px', 'padding': '20px', 'backgroundColor': '#f8f9fa', 'borderRadius': '10px'}),
    
    # Refresh button
    html.Div([
        html.Button('Refresh Data', id='refresh-btn', n_clicks=0,
                   style={'padding': '10px 20px', 'fontSize': '16px', 'backgroundColor': '#3498db', 
                         'color': 'white', 'border': 'none', 'borderRadius': '5px', 'cursor': 'pointer'}),
    ], style={'textAlign': 'center', 'marginBottom': '20px'}),
    
    dcc.Interval(
        id='interval-component',
        interval=300000,  # Refresh every 5 minutes
        n_intervals=0
    )
])

# Callbacks
@app.callback(
    [Output('sales-trend-chart', 'figure'),
     Output('top-products-chart', 'figure'),
     Output('category-chart', 'figure'),
     Output('customer-segment-chart', 'figure'),
     Output('region-chart', 'figure'),
     Output('inventory-table', 'children'),
     Output('key-metrics', 'children')],
    [Input('refresh-btn', 'n_clicks'),
     Input('interval-component', 'n_intervals')]
)
def update_dashboard(n_clicks, n_intervals):
    """Update all dashboard components"""
    
    # Load data
    sales_df = load_sales_by_month()
    top_products_df = load_top_products()
    category_df = load_sales_by_category()
    customer_seg_df = load_customer_segments()
    region_df = load_sales_by_region()
    inventory_df = load_inventory_status()
    
    # Sales Trend Chart
    if not sales_df.empty:
        fig_trend = make_subplots(specs=[[{"secondary_y": True}]])
        fig_trend.add_trace(
            go.Scatter(x=sales_df['year_month'], y=sales_df['total_revenue'], 
                      name='Revenue', line=dict(color='#3498db', width=3)),
            secondary_y=False,
        )
        fig_trend.add_trace(
            go.Scatter(x=sales_df['year_month'], y=sales_df['total_orders'], 
                      name='Orders', line=dict(color='#e74c3c', width=2)),
            secondary_y=True,
        )
        fig_trend.update_xaxes(title_text="Month")
        fig_trend.update_yaxes(title_text="Revenue ($)", secondary_y=False)
        fig_trend.update_yaxes(title_text="Number of Orders", secondary_y=True)
        fig_trend.update_layout(title="Monthly Sales Revenue and Orders", 
                               height=400, template='plotly_white')
    else:
        fig_trend = go.Figure()
        fig_trend.add_annotation(text="No data available", xref="paper", yref="paper", x=0.5, y=0.5)
    
    # Top Products Chart
    if not top_products_df.empty:
        fig_products = px.bar(top_products_df, x='total_revenue', y='product_name',
                             orientation='h', color='category_name',
                             title="Top 10 Products by Revenue",
                             labels={'total_revenue': 'Revenue ($)', 'product_name': 'Product'},
                             height=400)
        fig_products.update_layout(template='plotly_white', showlegend=True)
    else:
        fig_products = go.Figure()
    
    # Category Chart
    if not category_df.empty:
        fig_category = px.pie(category_df, values='total_revenue', names='category_name',
                             title="Revenue Distribution by Category",
                             height=400)
        fig_category.update_layout(template='plotly_white')
    else:
        fig_category = go.Figure()
    
    # Customer Segment Chart
    if not customer_seg_df.empty:
        fig_segment = px.bar(customer_seg_df, x='customer_segment', y='customer_count',
                            color='avg_lifetime_value', color_continuous_scale='Viridis',
                            title="Customer Segmentation",
                            labels={'customer_count': 'Number of Customers', 
                                   'customer_segment': 'Segment'},
                            height=400)
        fig_segment.update_layout(template='plotly_white', showlegend=False)
    else:
        fig_segment = go.Figure()
    
    # Region Chart
    if not region_df.empty:
        fig_region = px.bar(region_df, x='region', y='total_revenue', color='country',
                           title="Sales by Geographic Region",
                           labels={'total_revenue': 'Revenue ($)', 'region': 'Region'},
                           height=400)
        fig_region.update_layout(template='plotly_white')
    else:
        fig_region = go.Figure()
    
    # Inventory Table
    if not inventory_df.empty:
        inventory_table = dash_table.DataTable(
            data=inventory_df.to_dict('records'),
            columns=[{'name': i, 'id': i} for i in inventory_df.columns],
            style_cell={'textAlign': 'left', 'padding': '10px'},
            style_header={'backgroundColor': '#3498db', 'color': 'white', 'fontWeight': 'bold'},
            style_data_conditional=[
                {
                    'if': {'filter_query': '{is_out_of_stock} == True'},
                    'backgroundColor': '#e74c3c',
                    'color': 'white',
                },
                {
                    'if': {'filter_query': '{is_low_stock} == True'},
                    'backgroundColor': '#f39c12',
                    'color': 'white',
                }
            ],
            page_size=10
        )
    else:
        inventory_table = html.Div("No inventory data available")
    
    # Key Metrics
    if not sales_df.empty:
        total_revenue = sales_df['total_revenue'].sum()
        total_orders = sales_df['total_orders'].sum()
        total_profit = sales_df['total_profit'].sum()
        avg_order_value = total_revenue / total_orders if total_orders > 0 else 0
        
        metrics = [
            html.Div([
                html.H4(f"${total_revenue:,.2f}", style={'color': '#3498db', 'margin': '0'}),
                html.P("Total Revenue", style={'margin': '5px 0', 'color': '#7f8c8d'})
            ], style={'textAlign': 'center', 'padding': '20px', 'backgroundColor': 'white', 
                     'borderRadius': '10px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'}),
            html.Div([
                html.H4(f"{total_orders:,}", style={'color': '#e74c3c', 'margin': '0'}),
                html.P("Total Orders", style={'margin': '5px 0', 'color': '#7f8c8d'})
            ], style={'textAlign': 'center', 'padding': '20px', 'backgroundColor': 'white', 
                     'borderRadius': '10px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'}),
            html.Div([
                html.H4(f"${total_profit:,.2f}", style={'color': '#27ae60', 'margin': '0'}),
                html.P("Total Profit", style={'margin': '5px 0', 'color': '#7f8c8d'})
            ], style={'textAlign': 'center', 'padding': '20px', 'backgroundColor': 'white', 
                     'borderRadius': '10px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'}),
            html.Div([
                html.H4(f"${avg_order_value:.2f}", style={'color': '#9b59b6', 'margin': '0'}),
                html.P("Avg Order Value", style={'margin': '5px 0', 'color': '#7f8c8d'})
            ], style={'textAlign': 'center', 'padding': '20px', 'backgroundColor': 'white', 
                     'borderRadius': '10px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'})
        ]
    else:
        metrics = [html.Div("No data available")]
    
    return fig_trend, fig_products, fig_category, fig_segment, fig_region, inventory_table, metrics

if __name__ == '__main__':
    print("Starting E-Commerce Analytics Dashboard...")
    print("Dashboard will be available at http://127.0.0.1:8050")
    app.run_server(debug=True, host='127.0.0.1', port=8050)


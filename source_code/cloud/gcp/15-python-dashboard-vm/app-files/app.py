from flask import Flask, render_template, jsonify, request
from flask_sqlalchemy import SQLAlchemy
import plotly.graph_objs as go
import plotly.utils
import pandas as pd
import numpy as np
import json
import os
from datetime import datetime, timedelta
import random

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', 'sqlite:///dashboard.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Database Models
class SalesData(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.Date, nullable=False)
    product = db.Column(db.String(100), nullable=False)
    sales = db.Column(db.Float, nullable=False)
    region = db.Column(db.String(50), nullable=False)

class UserActivity(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    timestamp = db.Column(db.DateTime, nullable=False)
    user_count = db.Column(db.Integer, nullable=False)
    page_views = db.Column(db.Integer, nullable=False)

@app.route('/')
def dashboard():
    return render_template('dashboard.html')

@app.route('/api/sales')
def api_sales():
    sales_data = SalesData.query.all()
    
    # Create DataFrame for easier manipulation
    df = pd.DataFrame([{
        'date': s.date,
        'product': s.product,
        'sales': s.sales,
        'region': s.region
    } for s in sales_data])
    
    if df.empty:
        return jsonify({'error': 'No sales data available'})
    
    # Sales by product
    product_sales = df.groupby('product')['sales'].sum().reset_index()
    
    fig = go.Figure(data=[
        go.Bar(x=product_sales['product'], y=product_sales['sales'])
    ])
    fig.update_layout(title='Sales by Product', xaxis_title='Product', yaxis_title='Sales ($)')
    
    return jsonify({
        'chart': json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder),
        'total_sales': df['sales'].sum(),
        'products_count': len(df['product'].unique())
    })

@app.route('/api/activity')
def api_activity():
    activity_data = UserActivity.query.order_by(UserActivity.timestamp.desc()).limit(24).all()
    
    df = pd.DataFrame([{
        'timestamp': a.timestamp,
        'user_count': a.user_count,
        'page_views': a.page_views
    } for a in activity_data])
    
    if df.empty:
        return jsonify({'error': 'No activity data available'})
    
    fig = go.Figure()
    fig.add_trace(go.Scatter(x=df['timestamp'], y=df['user_count'], name='Users'))
    fig.add_trace(go.Scatter(x=df['timestamp'], y=df['page_views'], name='Page Views'))
    fig.update_layout(title='User Activity (Last 24 Hours)', xaxis_title='Time', yaxis_title='Count')
    
    return jsonify({
        'chart': json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder),
        'total_users': df['user_count'].sum(),
        'total_views': df['page_views'].sum()
    })

@app.route('/api/regions')
def api_regions():
    sales_data = SalesData.query.all()
    
    df = pd.DataFrame([{
        'region': s.region,
        'sales': s.sales
    } for s in sales_data])
    
    if df.empty:
        return jsonify({'error': 'No regional data available'})
    
    region_sales = df.groupby('region')['sales'].sum().reset_index()
    
    fig = go.Figure(data=[
        go.Pie(labels=region_sales['region'], values=region_sales['sales'])
    ])
    fig.update_layout(title='Sales by Region')
    
    return jsonify({
        'chart': json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder),
        'regions_count': len(region_sales)
    })

@app.route('/admin')
def admin():
    return render_template('admin.html')

@app.route('/api/add_sample_data', methods=['POST'])
def add_sample_data():
    try:
        # Add some sample sales data
        products = ['Laptop', 'Phone', 'Tablet', 'Headphones', 'Monitor']
        regions = ['North', 'South', 'East', 'West', 'Central']
        
        for _ in range(50):
            sale = SalesData(
                date=datetime.now().date() - timedelta(days=random.randint(0, 30)),
                product=random.choice(products),
                sales=random.uniform(100, 1000),
                region=random.choice(regions)
            )
            db.session.add(sale)
        
        # Add user activity data
        for i in range(24):
            activity = UserActivity(
                timestamp=datetime.now() - timedelta(hours=i),
                user_count=random.randint(10, 100),
                page_views=random.randint(50, 500)
            )
            db.session.add(activity)
        
        db.session.commit()
        return jsonify({'message': 'Sample data added successfully'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'deployment': 'gcp-vm-dashboard',
        'database': 'connected' if db.engine.execute('SELECT 1').fetchone() else 'disconnected'
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
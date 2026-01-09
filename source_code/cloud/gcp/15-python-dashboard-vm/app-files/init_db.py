from app import app, db, SalesData, UserActivity
import random
from datetime import datetime, timedelta

def init_database():
    """Initialize database with tables and sample data"""
    with app.app_context():
        # Create all tables
        db.create_all()
        
        # Check if data already exists
        if SalesData.query.first() is not None:
            print("Database already has data, skipping initialization")
            return
        
        print("Initializing database with sample data...")
        
        # Add sample sales data
        products = ['Laptop', 'Phone', 'Tablet', 'Headphones', 'Monitor', 'Keyboard', 'Mouse']
        regions = ['North America', 'Europe', 'Asia', 'South America', 'Africa']
        
        for _ in range(100):
            sale = SalesData(
                date=datetime.now().date() - timedelta(days=random.randint(0, 90)),
                product=random.choice(products),
                sales=round(random.uniform(50, 2000), 2),
                region=random.choice(regions)
            )
            db.session.add(sale)
        
        # Add user activity data for the last 48 hours
        for i in range(48):
            activity = UserActivity(
                timestamp=datetime.now() - timedelta(hours=i),
                user_count=random.randint(20, 150),
                page_views=random.randint(100, 800)
            )
            db.session.add(activity)
        
        db.session.commit()
        print("✅ Database initialized with sample data")

if __name__ == '__main__':
    init_database()
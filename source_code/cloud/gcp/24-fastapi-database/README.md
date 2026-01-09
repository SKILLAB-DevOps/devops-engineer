# FastAPI Star Wars Database API

A production-ready FastAPI application that collects Star Wars data from SWAPI and stores it in Google Cloud SQL PostgreSQL database.

## Features

- **Database Integration**: Full PostgreSQL integration with SQLAlchemy ORM
- **Star Wars API**: Collects data from swapi.tech (characters, planets, starships)
- **Cloud SQL**: Managed PostgreSQL database on Google Cloud
- **REST API**: Clean endpoints for data collection and retrieval
- **Database Models**: Structured tables for Star Wars entities
- **Health Monitoring**: Database connectivity checks
- **Statistics**: Real-time data counts and collection history

## Architecture

```
FastAPI Application (Cloud Run)
        ↓
Cloud SQL PostgreSQL
        ↓
Tables: characters, planets, starships, collections
```

## Database Schema

### Characters Table
- id, name, height, mass, hair_color, skin_color, eye_color
- birth_year, gender, homeworld, raw_data, created_at

### Planets Table  
- id, name, rotation_period, orbital_period, diameter
- climate, gravity, terrain, surface_water, population, raw_data, created_at

### Starships Table
- id, name, model, manufacturer, cost_in_credits, length
- crew, passengers, starship_class, raw_data, created_at

### Collections Table
- id, collection_name, endpoints_collected, total_items
- status, created_at, notes

## Quick Start

### 1. Deploy Infrastructure and Application
```bash
./deploy.sh YOUR_PROJECT_ID
```

This script will:
- Create Cloud SQL PostgreSQL instance
- Set up database and user
- Build and deploy FastAPI container to Cloud Run
- Configure database connectivity

### 2. Test the Application
```bash
./test.sh https://your-service-url
```

## API Endpoints

### Core Operations
- `GET /` - API information and available endpoints
- `GET /health` - Health check with database connectivity
- `POST /collect` - Collect Star Wars data and store in database

### Data Retrieval
- `GET /characters` - List stored characters
- `GET /planets` - List stored planets  
- `GET /starships` - List stored starships
- `GET /collections` - Collection history
- `GET /stats` - Database statistics

## Usage Examples

### Collect Star Wars Data
```bash
curl -X POST https://your-service-url/collect \
  -H "Content-Type: application/json" \
  -d '{
    "endpoints": ["people", "planets", "starships"],
    "max_items_per_endpoint": 5
  }'
```

### Retrieve Characters
```bash
curl https://your-service-url/characters
```

### Get Statistics
```bash
curl https://your-service-url/stats
```

## Database Operations

### Connect to Cloud SQL
```bash
gcloud sql connect starwars-postgres --user=starwars --database=starwars_db
```

### Useful SQL Queries

#### Character Analysis
```sql
-- Count characters by gender
SELECT gender, COUNT(*) FROM characters GROUP BY gender;

-- Find tall characters
SELECT name, height FROM characters WHERE height::int > 180 ORDER BY height::int DESC;

-- Characters from specific homeworld
SELECT name, homeworld FROM characters WHERE homeworld LIKE '%Tatooine%';
```

#### Planet Analysis  
```sql
-- Planets by climate
SELECT climate, COUNT(*) FROM planets GROUP BY climate;

-- Largest planets by diameter
SELECT name, diameter FROM planets WHERE diameter != 'unknown' ORDER BY diameter::int DESC LIMIT 5;
```

#### Starship Analysis
```sql
-- Starships by class
SELECT starship_class, COUNT(*) FROM starships GROUP BY starship_class ORDER BY COUNT(*) DESC;

-- Most expensive starships
SELECT name, cost_in_credits FROM starships WHERE cost_in_credits != 'unknown' ORDER BY cost_in_credits::bigint DESC LIMIT 5;
```

#### Collection History
```sql
-- Recent collections
SELECT collection_name, total_items, created_at FROM collections ORDER BY created_at DESC;

-- Daily collection summary
SELECT DATE(created_at) as collection_date, SUM(total_items) as total_collected 
FROM collections GROUP BY DATE(created_at);
```

## Configuration

### Environment Variables
- `DATABASE_URL` - PostgreSQL connection string (auto-configured)
- `PORT` - Server port (default: 8080)

### Cloud SQL Configuration
- **Instance**: starwars-postgres
- **Database**: starwars_db  
- **User**: starwars
- **Version**: PostgreSQL 15
- **Tier**: db-f1-micro (cost-effective for development)

## Database vs Storage Comparison

| Feature | Database (This Example) | Storage (Previous Example) |
|---------|------------------------|----------------------------|
| **Data Structure** | Relational tables with schemas | JSON files in buckets |
| **Querying** | SQL queries, complex joins | File-based retrieval |
| **Scalability** | Vertical scaling, read replicas | Horizontal scaling |
| **Consistency** | ACID transactions | Eventual consistency |
| **Cost** | Always-running database instance | Pay per storage/operations |
| **Complexity** | Higher (database management) | Lower (file operations) |
| **Use Cases** | Complex queries, relationships | Simple storage, data lakes |

## Architecture Benefits

### Database Approach
- **Structured Data**: Enforced schemas and data types
- **Complex Queries**: JOIN operations across tables
- **Data Integrity**: Foreign keys and constraints
- **Performance**: Indexed queries and optimizations
- **Analytics**: Built-in aggregation functions

### When to Use Database
- Need complex queries across multiple data types
- Require data relationships and referential integrity
- Want real-time analytics and reporting
- Have structured data with defined schemas
- Need ACID transaction guarantees

## Monitoring and Maintenance

### Cloud SQL Monitoring
```bash
# Instance status
gcloud sql instances describe starwars-postgres

# Database operations
gcloud sql operations list --instance=starwars-postgres

# Performance insights
gcloud sql instances describe starwars-postgres --format="table(state,backendType,databaseVersion)"
```

### Application Logs
```bash
# View Cloud Run logs
gcloud run services logs read starwars-db-api --region=us-central1

# Real-time logs
gcloud run services logs tail starwars-db-api --region=us-central1
```

## Security Considerations

- Database credentials are auto-generated and secure
- Cloud SQL uses private IP when possible
- Cloud Run service uses least-privilege IAM
- Database connections are encrypted in transit

## Cost Optimization

- **db-f1-micro**: Cheapest tier for development
- **Auto-scaling**: Cloud Run scales to zero when unused  
- **Connection Pooling**: Efficient database connections
- **Regional Deployment**: Minimize data transfer costs

## Cleanup

```bash
# Delete Cloud Run service
gcloud run services delete starwars-db-api --region=us-central1

# Delete Cloud SQL instance (careful - this deletes all data!)
gcloud sql instances delete starwars-postgres
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   ```bash
   # Check Cloud SQL instance status
   gcloud sql instances describe starwars-postgres
   ```

2. **Cloud Run Deployment Issues**
   ```bash
   # Check service logs
   gcloud run services logs read starwars-db-api --region=us-central1
   ```

3. **Permission Errors**
   ```bash
   # Ensure APIs are enabled
   gcloud services list --enabled | grep -E "(sql|run|cloudbuild)"
   ```

## Next Steps

- Add data validation and error handling
- Implement pagination for large datasets
- Add authentication and authorization
- Create data backup and recovery procedures
- Set up monitoring and alerting
- Add more Star Wars data endpoints (films, species, vehicles)

This example demonstrates how to build a production-ready database-backed API on Google Cloud Platform, perfect for learning cloud-native application development patterns.
########################################
11.10 Database Services on Google Cloud
########################################

Google Cloud Platform offers multiple database services for different use cases. Understanding when to use each service helps you choose the right data storage solution for your applications.

=========================
Database Options Overview
=========================

.. note::

   GCP provides both relational (SQL) and NoSQL databases, each optimized for specific workload patterns. Choose based on your data structure, scale requirements, and consistency needs.

**Database Services Spectrum:**

.. code-block:: text

   ┌──────────────────────────────────────────────────────────┐
   │                    GCP Database Services                 │
   ├─────────────────┬─────────────────┬──────────────────────┤
   │   Relational    │     NoSQL       │       Analytics      │
   │   (ACID/SQL)    │   (Flexible)    │      (Warehouse)     │
   ├─────────────────┼─────────────────┼──────────────────────┤
   │ • Cloud SQL     │ • Firestore     │ • BigQuery           │
   │ • AlloyDB       │ • Bigtable      │ • BigLake            │
   │ • Spanner       │ • Memorystore   │                      │
   └─────────────────┴─────────────────┴──────────────────────┘

=============================
1. Relational Databases (SQL)
=============================

**Cloud SQL (Managed SQL Databases)**

Fully managed relational databases supporting PostgreSQL, MySQL, and SQL Server.

.. code-block:: bash

   # Create PostgreSQL instance
   gcloud sql instances create my-postgres \
       --database-version=POSTGRES_14 \
       --tier=db-f1-micro \
       --region=us-central1

   # Create database and user
   gcloud sql databases create myapp --instance=my-postgres
   gcloud sql users create appuser --instance=my-postgres --password=securepass

   # Connect to database
   gcloud sql connect my-postgres --user=appuser --database=myapp

**Key Features:**
- **Automatic backups** and point-in-time recovery
- **High availability** with automatic failover
- **Read replicas** for scaling read workloads
- **Security** with VPC and encryption by default

**Best for:** Web applications, e-commerce, CMS, standard business applications

**AlloyDB (High-Performance PostgreSQL)**

PostgreSQL-compatible database with enhanced performance for enterprise workloads.

.. code-block:: bash

   # Create AlloyDB cluster
   gcloud alloydb clusters create production-cluster \
       --region=us-central1 \
       --network=projects/my-project/global/networks/default

   # Create primary instance
   gcloud alloydb instances create primary \
       --cluster=production-cluster \
       --region=us-central1 \
       --instance-type=PRIMARY \
       --cpu-count=4 \
       --memory-size=16GB

**Key Features:**
- **4x faster** OLTP performance than standard PostgreSQL
- **100x faster** analytics queries with columnar engine
- **AI/ML integration** with vector search capabilities
- **Enterprise features** like advanced monitoring

**Best for:** High-performance applications, analytics workloads, enterprise systems

**Cloud Spanner (Global SQL)**

Horizontally scalable, globally distributed SQL database.

.. code-block:: bash

   # Create Spanner instance
   gcloud spanner instances create global-db \
       --config=regional-us-central1 \
       --processing-units=1000

   # Create PostgreSQL-compatible database
   gcloud spanner databases create ecommerce \
       --instance=global-db \
       --database-dialect=POSTGRESQL

**Key Features:**
- **Global distribution** with strong consistency
- **Unlimited scale** (petabytes, millions of QPS)
- **99.999% availability** with automatic failover
- **ACID transactions** across regions

**Best for:** Global applications, financial systems, mission-critical workloads

==================
2. NoSQL Databases
==================

**Firestore (Document Database)**

Serverless NoSQL document database with real-time synchronization.

.. code-block:: python

   from google.cloud import firestore

   # Initialize Firestore
   db = firestore.Client()

   # Add document
   doc_ref = db.collection('products').add({
       'name': 'Laptop',
       'price': 999,
       'category': 'Electronics',
       'inStock': True
   })

   # Query documents
   products = db.collection('products').where('category', '==', 'Electronics').stream()
   for product in products:
       print(f'{product.id} => {product.to_dict()}')

   # Real-time listener
   def on_snapshot(doc_snapshot, changes, read_time):
       for doc in doc_snapshot:
           print(f'Received document snapshot: {doc.id}')

   db.collection('products').on_snapshot(on_snapshot)

**Key Features:**
- **Real-time synchronization** across clients
- **Offline support** with automatic sync
- **Auto-scaling** with serverless pricing
- **Security rules** for access control

**Best for:** Mobile apps, real-time applications, serverless architectures

**Cloud Bigtable (Wide-Column)**

Petabyte-scale NoSQL database for analytical and operational workloads.

.. code-block:: python

   from google.cloud import bigtable

   # Initialize client
   client = bigtable.Client(project='my-project')
   instance = client.instance('my-instance')
   table = instance.table('sensor_data')

   # Write data
   row_key = 'sensor001#1640995200'
   row = table.direct_row(row_key)
   row.set_cell('metrics', 'temperature', 23.5)
   row.set_cell('metrics', 'humidity', 65.0)
   row.commit()

**Key Features:**

- **Petabyte scale** with sub-10ms latency
- **Time-series optimization** for IoT and analytics
- **Auto-scaling** based on throughput
- **HBase compatibility** for easy migration

**Best for:** IoT data, time-series analytics, high-throughput applications

**Memorystore (Redis/Memcached)**

Fully managed in-memory cache for ultra-fast data access.

.. code-block:: bash

   # Create Redis instance
   gcloud redis instances create app-cache \
       --size=1 \
       --region=us-central1 \
       --redis-version=redis_6_x

.. code-block:: python

   import redis

   # Connect to Memorystore Redis
   r = redis.Redis(host='10.0.0.3', port=6379, decode_responses=True)

   # Cache user session
   r.setex('session:user123', 3600, 'session_data_here')

   # Get cached data
   session = r.get('session:user123')

**Key Features:**
- **Sub-millisecond latency** for cached data
- **High availability** with automatic failover
- **VPC integration** for secure access
- **Automatic scaling** and monitoring

**Best for:** Session storage, application caching, real-time analytics

===============================
3. Analytics and Data Warehouse
===============================

**BigQuery (Data Warehouse)**

Serverless, petabyte-scale data warehouse for analytics.

.. code-block:: sql

   -- Create dataset and table
   CREATE SCHEMA analytics;
   
   CREATE TABLE analytics.events (
     user_id STRING,
     event_type STRING,
     timestamp TIMESTAMP,
     properties JSON
   )
   PARTITION BY DATE(timestamp);

   -- Analytics query
   SELECT 
     event_type,
     COUNT(*) as events,
     COUNT(DISTINCT user_id) as unique_users
   FROM analytics.events
   WHERE DATE(timestamp) = CURRENT_DATE()
   GROUP BY event_type
   ORDER BY events DESC;

**Key Features:**
- **Serverless** with automatic scaling
- **SQL interface** with ML integration
- **Petabyte scale** processing
- **Pay-per-query** or flat-rate pricing

**Best for:** Data analytics, business intelligence, data science, reporting

===========================
4. Database Selection Guide
===========================

**Quick Decision Matrix:**

.. code-block:: text

   ┌─────────────────────┬─────────────────┬─────────────────┬─────────────────┐
   │     Use Case        │   Recommended   │   Alternative   │     Reason      │
   ├─────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Web Application     │ Cloud SQL       │ AlloyDB         │ ACID + familiar │
   ├─────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Mobile App          │ Firestore       │ Cloud SQL       │ Real-time sync  │
   ├─────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ IoT/Analytics       │ Bigtable        │ BigQuery        │ High throughput │
   ├─────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Global App          │ Spanner         │ Firestore       │ Strong consist. │
   ├─────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Caching Layer       │ Memorystore     │ None            │ Speed required  │
   ├─────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Data Analytics      │ BigQuery        │ AlloyDB         │ Scale + SQL     │
   └─────────────────────┴─────────────────┴─────────────────┴─────────────────┘

**Decision Tree:**

.. code-block:: text

         Start: What type of data?
                  │
                  ▼
         ┌─────────────────────────────────┐
         │ Structured (SQL) or Unstructured│
         └─────────────┬───────────────────┘
                     │
            ┌────────▼────────────┐
            │ SQL                 │ NoSQL
            │                     │
            ▼                     ▼
         Need global scale?   Need real-time sync?
            │                     │
      ┌─────▼────┐         ┌──────▼─────┐
      │YES    NO │         │YES      NO │ 
      │          │         │            │
      ▼          ▼         ▼            ▼
   Spanner    AlloyDB    Firestore   Bigtable
   Cloud SQL  Cloud SQL

======================
5. Integration Example
======================

**Multi-Database Architecture:**

.. code-block:: text

   E-commerce Platform:
   
   ┌─────────────────────────────────────────────────────────────────┐
   │                 Application Layer                               │
   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
   │  │   Web App   │  │ Mobile App  │  │   Admin Dashboard       │  │
   │  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
   └──────────────────────┬──────────────────────────────────────────┘
                          │
                          ▼
   ┌──────────────────────────────────────────────────────────────────┐
   │                Database Services                                 │
   │  ┌─────────────────┬─────────────────┬─────────────────────────┐ │
   │  │ Product Catalog │ User Sessions   │ Analytics Data          │ │
   │  │                 │                 │                         │ │
   │  │ ┌─────────────┐ │ ┌─────────────┐ │ ┌─────────────────────┐ │ │
   │  │ │  Cloud SQL  │ │ │Memorystore  │ │ │     BigQuery        │ │ │
   │  │ │(PostgreSQL) │ │ │   (Redis)   │ │ │   Data Warehouse    │ │ │
   │  │ └─────────────┘ │ └─────────────┘ │ └─────────────────────┘ │ │
   │  └─────────────────┴─────────────────┴─────────────────────────┘ │
   └──────────────────────────────────────────────────────────────────┘

=================
6. Best Practices
=================

**General Guidelines:**

.. code-block:: text

   + Start simple with Cloud SQL for most applications
   + Use caching (Memorystore) for frequently accessed data
   + Choose NoSQL for flexible schemas and real-time needs
   + Use BigQuery for analytics and reporting workloads
   + Plan for data growth and scaling requirements
   + Implement proper security and access controls
   - Don't use multiple databases without clear reasons
   - Don't ignore backup and recovery planning
   - Don't optimize prematurely - measure first

**Cost Optimization:**

.. code-block:: text

   Database Cost Tips:
   
   • Cloud SQL: Use appropriate instance sizes, enable auto-scaling
   • AlloyDB: Leverage read pools for analytics workloads
   • Firestore: Optimize queries to reduce read operations
   • Bigtable: Use appropriate node counts, consider preemptible
   • BigQuery: Partition tables, use clustering, avoid SELECT *
   • Memorystore: Right-size memory allocation

**Security Essentials:**

.. code-block:: bash

   # Enable private IP for Cloud SQL
   gcloud sql instances patch my-instance \
       --network=projects/my-project/global/networks/my-vpc \
       --no-assign-ip

   # Configure Firestore security rules
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth.uid == userId;
       }
     }
   }

The key to success with GCP databases is understanding your specific requirements for consistency, scale, performance, and cost, then choosing the simplest solution that meets those needs. Start with familiar technologies like Cloud SQL and add specialized databases as your requirements grow.
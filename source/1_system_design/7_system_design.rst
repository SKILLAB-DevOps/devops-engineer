#################
1.7 System Design
#################

System design interviews are seen as one of the hardest part of the recruitment process for software engineers. They require a deep understanding of system architecture, scalability, security, and performance. This guide will help you prepare for system design interviews by covering key concepts, common pitfalls, and best practices.

Keep in mind that nothing can prepare you better than hands-on experience. Practice designing systems, building projects, and learning from real-world scenarios. This guide is a starting point, but practical experience is invaluable.

========================
Common Pitfalls to Avoid
========================

Before proposing a solution the interviewer, take time to understand the problem. These are some of the common mistakes that a candidate can make:

- Diving Straight into Tools without clarifying requirements.
- Overengineering with too many services or microservices when a simpler approach suffices.
- Ignoring Cost: Especially critical in cloud environments.
- Neglecting Operational Concerns: Monitoring, logging, and security are integral parts of system design in Azure.
- Poor Time Management: In an interview, ensure you allocate enough time to walk through requirements, architecture, and a Q&A.

======================
What is System Design?
======================

System design is the process of defining the **architecture**, **modules**, **connections**, and **data** needed to solve a particular problem. It serves as a **blueprint** for development to follow throughout the lifecycle of a system.

Alongside the blueprint, you often create or maintain an **Architecture Design Record (ADR)**, which documents the rationale and trade-offs behind your design decisions. An ADR is a living document that evolves as the system itself evolves.

=============================
How to Approach System Design
=============================

Most systems you build will have these core components:

1. **UserInterface** - Is the way that user interact with your system: webpage, mobile app, API, etc.
2. **Compute** - Is the backend logic that processes requests and generates responses.
3. **Storage** - Is where you store data: databases, caches, file systems, etc.
4. **Network** - Is how your system communicates internally and externally, including load balancers, CDNs, etc.

When getting started, consider:

- **Availability**: How does the system cope with failures and ensure minimal downtime?
- **Security**: How will sensitive data be protected (encryption, authorization, etc.)?
- **Scalability**: How will the system handle increasing load?
- **Performance**: How quickly can the system process requests and manage large data volumes?

But before proposing any architecture, it's crucial to understand the **requirements** and **constraints** of the system. This includes:

- **Functional Requirements**: What the system should do.
- **Non-Functional Requirements**: How the system should perform (e.g., availability, security).
- **Use Cases**: Scenarios that describe how users interact with the system.
- **Constraints**: Limitations on the system (e.g., budget, technology stack, data localization).

.. note::

   Make sure you fully understand what the problem is and start from a simple design before adding complexity. As the system evolves, you can iterate and refine the architecture to meet new requirements.

===============================================
Start with the Problem Statement & Requirements
===============================================

1. Clarify Requirements

   Ask clarifying questions:

      - Who are the key stakeholders/users?
      - What are the primary business goals: performance, cost, time to market?
      - Any specific compliance/security requirements: data residency, GDPR/HIPAA, budget/costs?
      - What are the expected usage patterns:peak load, concurrency, global usage?

   Identify KPIs:

      - Throughput (e.g., requests per second)
      - Latency (e.g., maximum acceptable response time)
      - Data storage/retention needs
      - User growth projections

2. Define Scope

   1. Core features vs. 'Nice-to-Haves': Distinguish must-have functionalities from optional or future enhancements.

   2. Non-Functional Requirements:

      - Availability - What is the acceptable downtime?
      
         - 99.9%(Yearly: 8h 41m 38s)
         - 99.99%(Yearly: 52m 9.8s)
         - 99.999%(Yearly: 5m 15.6s)
         - 99.9999%(Yearly: 31.5s)
         - 99.99999%(Yearly: 3.1s)
      
      - Consistency requirements (strong vs. eventual)
      - Data residency or compliance (GDPR, HIPAA, etc.)
      - Security (encryption, access control)
      - Scalability (horizontal vs. vertical)
      - Performance (latency, throughput)
      - Cost (budget constraints)

=============================
Common System Design Patterns
=============================

1. Monolithic vs. Microservices Architectures

   a. Monolithic Architecture

      - Definition: All services run in a single process, sharing the same database and codebase.
      - Pros: Easier to develop, deploy, and test initially; straightforward for small apps.
      - Cons: Lack of modularity at scale; difficult to isolate failures and scale different components independently; large codebase becomes cumbersome over time.

   b. Microservices Architecture
      
      - Definition: Breaks an application into independent services, each focusing on a specific business capability.
      - Pros: Independent deployment and scaling; promotes modularity; isolates failures more effectively.
      - Cons: Increased complexity (deployment, orchestration, monitoring); requires careful inter-service communication design.

2. Event-Driven Architecture (EDA)

   a. Key Concepts
      
      - Producers and Consumers: Services communicate by publishing events (producers) and reacting to them (consumers).
      - Benefits: Loose coupling between components; scalable asynchronous communication; real-time data processing.
      - Common Tools:

         - Message brokers like Kafka, RabbitMQ, or Azure Service Bus.
         - Event routing services like AWS EventBridge or Azure Event Grid.
   
   b. Example Patterns Within EDA
      - Pub/Sub (Publish-Subscribe): Enables broadcast of events to multiple subscribers simultaneously.
      - Stream Processing: Consuming and processing a continuous flow of events (e.g., with Apache Kafka Streams, Azure Stream Analytics, or Apache Flink).

3. Saga Pattern (Distributed Transactions)

   - Definition: Saga: A sequence of local transactions in a distributed environment, coordinated using events or orchestration, ensuring data consistency without relying on a traditional 2PC (Two-Phase Commit).
   - Types: Choreography: Each service listens for events and performs a local transaction, then publishes new events.
   - Orchestration: A centralized “orchestrator” service coordinates the workflow among all the services.
   - Use Cases: Order Processing: Where multiple services (payments, inventory, shipping) must coordinate to complete or roll back a transaction.
   
4. API Gateway Pattern

   - Definition: API Gateway: A single entry point for client requests. It can handle:
      - Request routing
      - Authentication/Authorization
      - Rate limiting
      - Protocol translations
   - Benefit:
      - Simplifies Clients: They don't need to track multiple service endpoints or integrate with each microservice directly.
      - Cross-Cutting Concerns: Centralizes concerns like security, caching, and request transformations.

5. Service Mesh Pattern

   - Definition: Service Mesh: Abstracts service-to-service communications into a dedicated layer, typically using sidecars.
   - Key Features:
      - Observability (metrics, logs, traces)
      - Traffic management (load balancing, routing)
      - Security (mTLS encryption, policy enforcement)
      - Examples: Istio, Linkerd, Consul.

++++++++++++++++++++++++++++++++++
Step 1: Start With a Simple Design
++++++++++++++++++++++++++++++++++

1. **MVP or Proof of Concept**

   - Begin with a single-instance architecture: a simple **web server** (Node.js/Express, Python/Flask, Java/Spring, etc.) connected to a **single database** (MySQL, PostgreSQL, etc.).
   - Place it behind a basic **reverse proxy** or **web server** (Nginx, Apache) to handle HTTP requests and basic routing.
   - This approach gets core functionality up and running quickly. It's easier to validate requirements and gather feedback before adding complexity.

2. **Identify problems by gathering information**

   - Get the stakeholders feedback to understand what's working and what's not, what are the next features that are requested and the bottlenecks.
   - Use basic monitoring (e.g., api requests, server metrics, DB connections) to find where the system slows under load.
   - Bottlenecks guide where to invest in **scaling**, **caching**, or **load balancing** as your system evolves.

++++++++++++++++++++++++++++
Step 2: Consider Scalability
++++++++++++++++++++++++++++

A single machine 2CPUs - 8GB RAM can hold between 25-100 concurent users. Scalability is the system's ability to handle increasing load without sacrificing performance. There are two key approaches:

1. **Vertical Scaling (Scale Up)**

   - Add more CPU, memory, or disk to a single machine.
   - Simple to implement initially but limited by the maximum capacity of a single server.

2. **Horizontal Scaling (Scale Out)**

   - Run multiple instances of your service in parallel and distribute requests among them.
   - Typically requires **stateless** services, so any instance can handle any request.
   - Uses **load balancers** (e.g., AWS ELB, Nginx, HAProxy) to distribute traffic.
   - Potentially **unlimited** growth but introduces complexity (e.g., data consistency, orchestration).

-----------------------------------------------
Common Strategies Supporting Horizontal Scaling
-----------------------------------------------

1. **Load Balancing**

   Load balancers distribute incoming traffic to multiple servers, improving efficiency and reliability. They help:
   
   - Prevent traffic from going to **unhealthy** servers.
   - Avoid **resource overload**.
   - Eliminate a **single point of failure** (when deployed in at least an active-passive configuration).

   **Implementation** can be hardware-based (expensive, specialized appliances) or software-based (e.g., HAProxy, Nginx).

   **Key Features**:

   - **SSL Termination**: Offloads encryption/decryption from backend servers.  
   - **Session Persistence**: Routes a user to the same server if sessions are stored locally.  
   - **Redundancy**: Multiple load balancers in active-passive or active-active mode for high availability.

   **Traffic Routing Strategies**:

   - **Random**: Simple but can cause uneven distribution.  
   - **Least Loaded**: Sends traffic to the instance with the fewest active connections or lowest usage.  
   - **Session-Based (Sticky Sessions)**: Ensures a user's requests go to the same instance.  
   - **Round Robin / Weighted Round Robin**: Cycles through servers; Weighted Round Robin allocates more traffic to beefier servers.  
   - **Layer 4 Routing**: Uses source/destination IP/ports, lower latency but less flexible.  
   - **Layer 7 Routing**: Uses HTTP headers/URLs for more advanced routing but needs more processing power.

   **Challenges**: Can become a **bottleneck** if not provisioned properly, adds complexity, and a single load balancer can be a failure point if not replicated.

2. **Caching**

   - **Local Caching** or **CDN** for static assets on the client's browser or via HTTP cache headers.
   - **Application Cache** (e.g., Redis, Memcached) to store frequently accessed data (sessions, query results).  
   - **Database Caching** (indexes, query caching) to reduce expensive queries.
   
   **What is a CDN (Content Delivery Network)**

   A CDN is a geographically distributed network of proxy servers designed to deliver content (e.g., images, CSS, JS) from locations nearer to the user.

   **Advantages**:

   - **Lower Latency**: Users download assets from servers close to them.
   - **Reduced Load**: Offloads requests from your main servers.

   **Push CDNs vs. Pull CDNs**:

   - **Push**: You actively upload new content to the CDN as it changes. Good for smaller or rarely updated content.  
   - **Pull**: The CDN fetches content from your server on the first request. Good for large sites with frequently requested content.

   **Disadvantages**:  
   - **Costs** could be significant with high traffic.  
   - Possible **stale data** if content changes before the TTL expires.  
   - Requires **URL rewrites** for static assets.

3. **Database Sharding or Replication**

   - **Master-Slave (Primary-Replica) Replication**: Replicas handle reads, master handles writes.  
   - **Sharding (Horizontal Partitioning)**: Splits data across multiple DB servers. Each shard handles a subset of the data.

++++++++++++++++++++++++++++++++
Step 3: Ensure High Availability
++++++++++++++++++++++++++++++++

High availability means your system remains up and responsive even when components fail.

1. **Redundancy**

   - Run multiple instances of each service in different **availability zones** or data centers.
   - If one instance fails, another instance automatically takes over.

2. **Active-Active vs. Active-Passive**

   - **Active-Active**: All instances handle traffic concurrently.  
   - **Active-Passive**: Only the primary instance handles traffic; the secondary waits on standby.

3. **Failover Mechanisms**

   - **Health Checks**: Regularly check each instance's health. Unhealthy instances are removed from rotation.  
   - **Automatic/Manual Failover**: If a primary database fails, promote a replica to primary.

4. **Resiliency Patterns**

   - **Circuit Breaker**: Prevents cascading failures by “tripping” if a downstream service is unresponsive.  
   - **Bulkhead Pattern**: Partitions resources (threads, connections) so one failing service can't exhaust them all.

+++++++++++++++++++++++++++++++++++++++++++
Step 4: Incorporate Security Best Practices
+++++++++++++++++++++++++++++++++++++++++++

Security should be part of the initial design, not an afterthought.

1. **Authentication & Authorization**

   - Use industry-standard protocols (OAuth2, JWT) for user identity and permissions.
   - Implement RBAC (role-based access control) or ABAC (attribute-based) for fine-grained policies.

2. **Transport Layer Security (TLS)**

   - Encrypt data in transit (HTTPS).  
   - Keep TLS configurations updated; disable weak ciphers and protocols.

3. **Data Protection**

   - Encrypt data at rest (database, disk-level encryption).  
   - Store secrets securely (Vault, AWS KMS).  
   - Sanitize inputs to avoid SQL injection, XSS, CSRF, etc.

4. **Infrastructure Security**

   - **Network Segmentation**: Place critical services in private subnets.  
   - **Firewalls/Security Groups**: Restrict inbound/outbound traffic.  
   - **Monitoring & Auditing**: Track logs, user actions, anomalies.

++++++++++++++++++++++++++++
Step 5: Optimize Performance
++++++++++++++++++++++++++++

Performance focuses on **latency** (response times) and **throughput** (requests per second).

1. **Caching Strategy**

   - **Application-Level**: Cache expensive queries or computations (Redis, Memcached).  
   - **DB Query Optimization**: Proper indexing, denormalization, avoiding full table scans.  
   - **Edge Caching (CDN)**: Serve static content from edge servers.

2. **Asynchronous Processing**

   - Move long-running tasks to background jobs with message queues (RabbitMQ, Kafka, AWS SQS).  
   - Keep the main request cycle fast and responsive.

3. **Efficient Data Modeling**

   - Choose **SQL** vs. **NoSQL** based on data relationships, query patterns, and scalability needs.  
   - **NoSQL** can offer flexible schemas and high throughput (Cassandra, DynamoDB, MongoDB).  
   - **Relational DBs** (MySQL, PostgreSQL) excel at strong consistency and complex joins.

4. **Load Testing & Profiling**

   - Use tools like **JMeter**, **Gatling**, or **Locust** to simulate load and identify bottlenecks.  
   - Profile code (CPU, memory usage) to optimize critical paths.

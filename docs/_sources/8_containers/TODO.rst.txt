####
TODO
####

This section contains practical exercises designed to build your container skills progressively. Each task includes estimated completion time and clear success criteria.

.. note::

    **How to Use This Section:**
    
    1. Start with Quick Questions to test your understanding
    2. Complete the 10-Minute Tasks to build hands-on experience
    3. Use the ANSWERS.rst file for detailed solutions
    4. Think through the Open-Ended Questions for deeper understanding

===============
Quick Questions
===============

**These questions test your foundational container knowledge. Check ANSWERS.rst for explanations.**

1. **What is the main difference between a container image and a container?**

2. **Why do containers start faster than virtual machines?**

3. **What happens to data inside a container when it stops?**

4. **How do you pass environment variables to a Python container?**

5. **What is the purpose of a Dockerfile?**

6. **Why should you avoid running containers as root?**

7. **What is the difference between COPY and ADD in a Dockerfile?**

8. **How do you persist data from a container?**

9. **What is Docker Compose used for?**

10. **How do you limit memory usage for a container?**

===============
10-Minute Tasks
===============

**Each task should take about 10-15 minutes to complete. All use Python applications.**

-------------------
Task 1: Hello World
-------------------

**Objective:** Create your first Python container

**What to do:**

- Create a simple Python script that prints "Hello from Container!"
- Write a Dockerfile to containerize it
- Build and run the container

**Success criteria:**

- Container starts and prints the message
- Container exits cleanly

**Skills practiced:** Basic Dockerfile, building images, running containers

-----------------------------
Task 2: Environment Variables
-----------------------------

**Objective:** Use environment variables in a Python container

**What to do:**

- Modify your Python script to use `os.environ.get()`
- Print a greeting using a NAME environment variable
- Pass the variable when running the container

**Success criteria:**

- Script uses environment variable for the name
- Default value works when variable not provided

**Skills practiced:** Environment variables, Python os module

--------------------------
Task 3: File System Access
--------------------------

**Objective:** Read files from the host system

**What to do:**

- Create a Python script that reads a text file
- Mount a host directory into the container
- Test reading different files

**Success criteria:**

- Container can read files from host directory
- Changes on host are visible in container

**Skills practiced:** Volume mounting, file I/O

----------------------
Task 4: Python Web API
----------------------

**Objective:** Containerize a simple Flask web application

**What to do:**

- Create a Flask app with one endpoint that returns JSON
- Write a Dockerfile with proper port exposure
- Run container and test the API

**Success criteria:**

- Web app accessible from browser
- JSON response returns correctly
- Container stops gracefully

**Skills practiced:** Web applications, port mapping, Flask

-------------------------
Task 5: Multi-Stage Build
-------------------------

**Objective:** Optimize image size using multi-stage builds

**What to do:**

- Create a Python script that requires building dependencies
- Write a multi-stage Dockerfile
- Compare image sizes before/after optimization

**Success criteria:**

- Final image is smaller than single-stage version
- Application still works correctly

**Skills practiced:** Multi-stage builds, image optimization

--------------------------
Task 6: Container Networks
--------------------------

**Objective:** Connect two Python containers

**What to do:**

- Create a simple HTTP client and server in Python
- Run both in separate containers on same network
- Test communication between containers

**Success criteria:**

- Client successfully connects to server
- Communication works using container names

**Skills practiced:** Container networking, service discovery

----------------------
Task 7: Docker Compose
----------------------

**Objective:** Use Docker Compose for multi-container setup

**What to do:**

- Create a Python web app and Redis cache
- Write docker-compose.yml file
- Test that web app can connect to Redis

**Success criteria:**

- Both containers start with single command
- Web app successfully uses Redis
- Data persists in Redis between requests

**Skills practiced:** Docker Compose, service dependencies

---------------------
Task 8: Health Checks
---------------------

**Objective:** Add health monitoring to your Python container

**What to do:**

- Add a health check endpoint to your Flask app
- Configure HEALTHCHECK in Dockerfile
- Test health check functionality

**Success criteria:**

- Health check endpoint returns 200 status
- Docker shows container as healthy
- Unhealthy containers are detected

**Skills practiced:** Health checks, monitoring, Flask routes

----------------------
Task 9: Container Logs
----------------------

**Objective:** Implement proper logging in containerized Python apps

**What to do:**

- Add structured logging to your Python application
- Configure logging to write to stdout
- View and filter container logs

**Success criteria:**

- Logs visible using `docker logs`
- Log format is consistent and readable
- Different log levels work correctly

**Skills practiced:** Python logging, container logging patterns

---------------------------
Task 10: Resource Limits
---------------------------

**Objective:** Control container resource usage

**What to do:**

- Create a Python script that uses memory and CPU
- Run container with memory and CPU limits
- Monitor resource usage

**Success criteria:**

- Container respects memory limits
- CPU usage is properly constrained
- Container behavior is predictable under limits

**Skills practiced:** Resource management, container monitoring

====================
Open-Ended Questions
====================

**These questions don't have single correct answers. Think through them and discuss with peers.**

**Question 1: Container Security Strategy**

*How would you design a security strategy for Python containers in production?*

**Consider:**

- User permissions and non-root execution
- Image vulnerability scanning
- Runtime security monitoring
- Secrets management
- Network isolation

**Guidelines:**

- Start with least privilege principle
- Implement defense in depth
- Consider your threat model
- Balance security with developer productivity

**Question 2: Multi-Environment Deployment**

*How would you manage the same Python application across development, staging, and production environments using containers?*

**Consider:**

- Configuration management
- Environment-specific dependencies
- Database connections
- Logging and monitoring
- Performance differences

**Guidelines:**

- Use environment variables for configuration
- Keep images identical across environments
- Consider using different compose files
- Think about data persistence strategies

**Question 3: Microservices Architecture**

*When would you split a Python application into multiple containers vs keeping it as a single container?*

**Consider:**

- Team boundaries and ownership
- Scaling requirements
- Technology diversity
- Development and deployment complexity
- Communication patterns

**Guidelines:**

- Start with a monolith, split when needed
- Consider Conway's Law
- Think about data consistency
- Evaluate operational overhead

**Question 4: Container Orchestration**

*How would you decide between Docker Compose, Kubernetes, and other orchestration tools for your Python applications?*

**Consider:**

- Application complexity
- Team size and expertise
- Scaling requirements
- High availability needs
- Infrastructure constraints

**Guidelines:**

- Match tool complexity to problem complexity
- Consider learning curve and maintenance
- Think about long-term growth
- Evaluate ecosystem and community support

**Question 5: Performance Optimization**

*What strategies would you use to optimize Python container performance in production?*

**Consider:**

- Image size and build time
- Startup time optimization
- Memory usage patterns
- CPU utilization
- I/O performance

**Guidelines:**

- Profile before optimizing
- Consider using Alpine vs Ubuntu base images
- Think about Python-specific optimizations
- Balance optimization effort with impact
- Monitor performance metrics continuously
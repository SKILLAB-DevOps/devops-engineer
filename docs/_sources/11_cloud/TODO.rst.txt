####
TODO
####

.. note::

   This section contains a series of exercises and assessment questions designed to reinforce the concepts from the cloud computing chapters. Solutions and detailed explanations are provided in the `solutions.rst` file. It is highly recommended to attempt the exercises yourself before reviewing the solutions.

==============================
Part 1: Foundational Exercises
==============================

These exercises cover the core concepts of cloud computing, service models, and architectural patterns.

==============================================
Exercise 1: Cloud Service Model Recommendation
==============================================

**Scenario:** You are a cloud architect consulting for three different companies.

*   **Company A (StartupFast):** A 2-person startup building a new food delivery app. They need to launch in 8 weeks with a limited budget and expect viral growth.
*   **Company B (MegaCorp):** A Fortune 500 manufacturing company with existing .NET applications, a large IT department, strict compliance requirements (SOX, GDPR), and a hybrid cloud strategy.
*   **Company C (DataInsights LLC):** An AI/ML consultancy that processes terabytes of data with variable workloads. Their team consists of data scientists, not DevOps engineers.

**Task:** For each company, recommend the optimal mix of cloud service models (IaaS, PaaS, SaaS) and justify your choices. Outline the key services you would use and the primary benefits of your proposed architecture.

===================================
Exercise 2: Scaling Strategy Design
===================================

**Scenario:** You are designing a news website that experiences highly variable traffic: low during normal hours but massive, unpredictable spikes during breaking news events.

**Task:**
1.  Design two scaling strategies: one based on **vertical scaling** and one on **horizontal scaling**.
2.  Create a comparison matrix evaluating each strategy on cost, response time to traffic spikes, complexity, and reliability.
3.  Which strategy would you choose and why?

===========================================
Exercise 3: VM vs. Container Migration Plan
===========================================

**Scenario:** Your team is migrating a traditional 3-tier web application (React frontend, Node.js backend, PostgreSQL database) from on-premises servers to the cloud.

**Task:**
1.  Outline a migration plan using a **VM-based (IaaS)** architecture.
2.  Outline a migration plan using a **container-based (PaaS/CaaS)** architecture on Kubernetes.
3.  Compare the two approaches, focusing on resource efficiency, deployment speed, operational complexity, and cost.

===============================
Part 2: Hands-On Implementation
===============================

These exercises require you to apply your knowledge using specific tools and cloud provider services.

=======================================
Exercise 4: Multi-Cloud Service Mapping
=======================================

**Task:** Create a service mapping table for the following categories across AWS, Azure, and GCP. This is a reference exercise to build familiarity.

*   Compute (VMs, Containers, Serverless)
*   Storage (Object, Block)
*   Database (SQL, NoSQL)
*   Networking (VPC, Load Balancer, CDN)
*   Identity & Access Management
*   Monitoring

================================================
Exercise 5: Terraform Multi-Cloud Implementation
================================================

**Scenario:** Implement a simple web server infrastructure on both AWS and Azure using a single Terraform project.

**Task:**
1.  Structure your Terraform project with a root `main.tf` and provider-specific modules (e.g., `./modules/aws` and `./modules/azure`).
2.  The root module should use a variable (e.g., `var.cloud_provider`) to decide which child module to use.
3.  Each module should create a virtual network, a subnet, and a single web server VM that responds to HTTP requests.
4.  Demonstrate how you would deploy to AWS and then to Azure by changing the input variable.

*(For a full solution, see the practical lab in section 0.8)*

============================
Part 3: Assessment Questions
============================

Attempt to answer these questions to test your understanding of the key concepts.

=========================
Multiple Choice Questions
=========================

1.  In the IaaS model, which of the following is the **customer** responsible for managing?
    a) Physical servers
    b) Virtualization hypervisor
    c) Operating System
    d) Data center security

2.  A startup wants to launch a new application as quickly as possible with a small team. Which cloud strategy is generally most suitable?
    a) Cloud Agnostic
    b) Cloud Native
    c) On-Premises
    d) Private Cloud

3.  What is the primary advantage of horizontal scaling over vertical scaling?
    a) It is always cheaper.
    b) It improves the performance of a single instance.
    c) It increases availability and fault tolerance.
    d) It requires less complex networking.

4.  Which tool is best suited for managing a cloud-agnostic infrastructure as code?
    a) AWS CloudFormation
    b) Azure Resource Manager
    c) Terraform
    d) Google Cloud Deployment Manager

5.  What is the main purpose of an API Gateway in a microservices architecture?
    a) To run application business logic.
    b) To provide a single entry point for clients and handle cross-cutting concerns.
    c) To store and manage application data.
    d) To replace the need for a container orchestrator.

======================
Short Answer Questions
======================

1.  Explain the concept of "cattle vs. pets" in cloud infrastructure management and how it relates to the Cloud Native approach.
2.  Describe the trade-offs between using a managed database service (like AWS RDS) versus self-hosting a database (like PostgreSQL on an EC2 VM).
3.  What are the "6 Rs" of cloud migration? List and briefly describe at least four of them.

#####################################
11.3 GCP Compute Services Overview
#####################################

Google Cloud Platform offers three primary compute services that address different application deployment needs. Understanding when and how to use Cloud Run, Compute Engine VMs, and Google Kubernetes Engine (GKE) is crucial for effective cloud architecture.

===============================
Overview of GCP Compute Options
===============================

.. note::

   GCP provides a spectrum of compute services from fully managed serverless to complete infrastructure control. Each service targets different use cases and operational requirements.

**GCP Compute Services Spectrum:**

.. code-block:: text

   ┌─────────────────────────────────────────────────────────────────┐
   │                    GCP Compute Services                         │
   ├─────────────────┬─────────────────┬─────────────────────────────┤
   │   Cloud Run     │   GKE           │    Compute Engine           │
   │   (Serverless)  │   (Kubernetes)  │    (Virtual Machines)       │
   ├─────────────────┼─────────────────┼─────────────────────────────┤
   │ Fully Managed   │ Container Mgmt  │ Infrastructure Control      │
   │ Pay per Request │ Orchestration   │ Full OS Access              │
   │ Auto Scaling    │ Multi-Service   │ Custom Configuration        │
   │ Zero Ops        │ Complex Apps    │ Legacy Applications         │
   └─────────────────┴─────────────────┴─────────────────────────────┘
          ▲                   ▲                       ▲
     Less Control          Balanced            More Control
     Less Management                          More Management

================================
1. Google Cloud Run (Serverless)
================================

**What is Cloud Run?**

Cloud Run is Google's fully managed serverless platform for running stateless containerized applications. It automatically scales from zero to thousands of instances based on incoming requests.

**Key Characteristics:**

.. code-block:: text

   Cloud Run Architecture:
   
   ┌─────────────────────────────────────────────────────────────┐
   │                    Internet Traffic                         │
   └──────────────────────┬──────────────────────────────────────┘
                          │
   ┌─────────────────────────────────────────────────────────────┐
   │              Google Load Balancer                           │
   │              (Automatic SSL, CDN)                           │
   └──────────────────────┬──────────────────────────────────────┘
                          │
   ┌─────────────────────────────────────────────────────────────┐
   │                 Cloud Run Service                           │
   │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
   │  │Container │  │Container │  │Container │  │Container │     │
   │  │Instance  │  │Instance  │  │Instance  │  │Instance  │     │
   │  │   (0-1)  │  │   (0-1)  │  │   (0-1)  │  │   (0-1)  │     │
   │  └──────────┘  └──────────┘  └──────────┘  └──────────┘     │
   │      Auto Scale: 0 → 1000+ based on requests                │
   └─────────────────────────────────────────────────────────────┘

**Cloud Run Features:**

- **Serverless**: No infrastructure management
- **Containerized**: Deploy any language via containers
- **Auto-scaling**: Scale to zero when idle
- **Pay-per-use**: Only pay for actual request processing time
- **HTTPS by default**: Automatic SSL certificates
- **Traffic splitting**: Blue-green and canary deployments

**Deployment Methods:**

.. code-block:: bash

   # Method 1: Deploy from Docker image
   gcloud run deploy my-service \
     --image gcr.io/my-project/my-app:latest \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated

   # Method 2: Deploy from source code (Buildpacks)
   gcloud run deploy my-service \
     --source . \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated

**Best Use Cases:**

- **Web APIs and microservices**
- **Event-driven applications**
- **Batch processing jobs**
- **Serverless backends for mobile/web apps**
- **Applications with variable traffic patterns**

**Limitations:**

- **Request timeout**: Maximum 60 minutes
- **Memory limit**: Up to 32 GiB
- **CPU limit**: Up to 8 vCPUs
- **Stateless only**: No persistent local storage
- **Cold starts**: Latency for new instances

====================================
2. Compute Engine (Virtual Machines)
====================================

**What is Compute Engine?**

Compute Engine provides scalable, high-performance virtual machines running on Google's infrastructure. It offers complete control over the operating system and configuration.

**Key Characteristics:**

.. code-block:: text

   Compute Engine Architecture:
   
   ┌──────────────────────────────────────────────────────────┐
   │                  Your Project                            │
   │  ┌───────────────────────────────────────────────────────┤
   │  │               VPC Network                             │
   │  │  ┌────────────────────────────────────────────────────┤
   │  │  │            Subnet (us-central1-a)                  │
   │  │  │  ┌──────────────────┐  ┌──────────────────┐        │
   │  │  │  │   VM Instance    │  │   VM Instance    │        │
   │  │  │  │   ┌──────────────┤  │   ┌──────────────┤        │
   │  │  │  │   │ Ubuntu 22.04 │  │   │ Windows 2022 │        │
   │  │  │  │   │ 4 vCPUs      │  │   │ 8 vCPUs      │        │
   │  │  │  │   │ 16 GB RAM    │  │   │ 32 GB RAM    │        │
   │  │  │  │   │ 100 GB SSD   │  │   │ 500 GB SSD   │        │
   │  │  │  │   └──────────────┤  │   └──────────────┤        │
   │  │  │  └──────────────────┘  └──────────────────┘        │
   │  │  └────────────────────────────────────────────────────┤
   │  └───────────────────────────────────────────────────────┤
   └──────────────────────────────────────────────────────────┘

**Compute Engine Features:**

- **Full OS control**: Choose from Linux or Windows
- **Custom machine types**: Tailor CPU, memory, and storage
- **Persistent disks**: Separate compute and storage
- **GPU support**: Add GPUs for ML/AI workloads
- **Live migration**: Maintenance without downtime
- **Preemptible instances**: Up to 80% cost savings

**Deployment Example:**

.. code-block:: bash

   # Create a VM instance with startup script
   gcloud compute instances create my-web-server \
     --zone=us-central1-a \
     --machine-type=e2-medium \
     --boot-disk-size=20GB \
     --boot-disk-type=pd-standard \
     --image-family=ubuntu-2204-lts \
     --image-project=ubuntu-os-cloud \
     --tags=web-server \
     --startup-script='#!/bin/bash
       apt-get update
       apt-get install -y apache2
       systemctl start apache2
       systemctl enable apache2'

   # Create firewall rule for HTTP traffic
   gcloud compute firewall-rules create allow-http \
     --allow tcp:80 \
     --source-ranges 0.0.0.0/0 \
     --target-tags web-server

**Best Use Cases:**

- **Legacy applications requiring specific OS configurations**
- **Applications needing persistent local storage**
- **High-performance computing workloads**
- **Custom network configurations**
- **Applications requiring specific compliance controls**
- **Long-running batch jobs or services**

**Management Considerations:**

- **OS patching and security updates**
- **Monitoring and logging setup**
- **Backup and disaster recovery planning**
- **Resource scaling and optimization**

=================================
3. Google Kubernetes Engine (GKE)
=================================

**What is GKE?**

GKE is Google's managed Kubernetes service that provides a powerful orchestration system for containerized applications while reducing the operational overhead of managing Kubernetes clusters.

**Key Characteristics:**

.. code-block:: text

   GKE Architecture:
   
   ┌───────────────────────────────────────────────────────────┐
   │                    GKE Cluster                            │
   │  ┌────────────────────────────────────────────────────────┤
   │  │               Control Plane                            │
   │  │               (Fully Managed)                          │
   │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────┐      │
   │  │  │API      │ │etcd     │ │Scheduler│ │Controller│      │
   │  │  │Server   │ │Database │ │         │ │Manager   │      │
   │  │  └─────────┘ └─────────┘ └─────────┘ └──────────┘      │
   │  └────────────────────────────────────────────────────────┤
   │  ┌────────────────────────────────────────────────────────┤
   │  │                 Worker Nodes                           │
   │  │  ┌───────────────────┐ ┌───────────────────┐           │
   │  │  │   Node 1          │ │   Node 2          │           │
   │  │  │  ┌─────────────┐  │ │  ┌─────────────┐  │           │
   │  │  │  │   Pod       │  │ │  │   Pod       │  │           │
   │  │  │  │ ┌─────────┐ │  │ │  │ ┌─────────┐ │  │           │
   │  │  │  │ │Frontend │ │  │ │  │ │Backend  │ │  │           │
   │  │  │  │ │Container│ │  │ │  │ │Container│ │  │           │
   │  │  │  │ └─────────┘ │  │ │  │ └─────────┘ │  │           │
   │  │  │  └─────────────┘  │ │  └─────────────┘  │           │
   │  │  │  ┌─────────────┐  │ │  ┌─────────────┐  │           │
   │  │  │  │   Pod       │  │ │  │   Pod       │  │           │
   │  │  │  │ ┌─────────┐ │  │ │  │ ┌─────────┐ │  │           │
   │  │  │  │ │Database │ │  │ │  │ │Cache    │ │  │           │
   │  │  │  │ │Container│ │  │ │  │ │Container│ │  │           │
   │  │  │  │ └─────────┘ │  │ │  │ └─────────┘ │  │           │
   │  │  │  └─────────────┘  │ │  └─────────────┘  │           │
   │  │  └───────────────────┘ └───────────────────┘           │
   │  └────────────────────────────────────────────────────────┤
   └───────────────────────────────────────────────────────────┘

**GKE Features:**

- **Managed control plane**: Google handles Kubernetes masters
- **Auto-scaling**: Horizontal Pod Autoscaler and Vertical Pod Autoscaler
- **Auto-upgrade**: Automatic Kubernetes version updates
- **Auto-repair**: Automatic node replacement when unhealthy
- **Workload Identity**: Secure access to Google Cloud services
- **Binary Authorization**: Ensure only trusted container images

**GKE Modes:**

.. code-block:: text

   GKE Operating Modes:
   
   ┌─────────────────────┬─────────────────────┐
   │    Standard Mode    │   Autopilot Mode    │
   ├─────────────────────┼─────────────────────┤
   │ • Node management   │ • Fully managed     │
   │ • Flexible config   │ • Simplified ops    │
   │ • Cost optimization │ • Pay-per-pod       │
   │ • Advanced features │ • Built-in security │
   └─────────────────────┴─────────────────────┘

**Deployment Example:**

.. code-block:: bash

   # Create GKE cluster
   gcloud container clusters create my-cluster \
     --zone us-central1-a \
     --num-nodes 3 \
     --enable-autoscaling \
     --min-nodes 1 \
     --max-nodes 10 \
     --machine-type e2-standard-2

   # Get credentials
   gcloud container clusters get-credentials my-cluster --zone us-central1-a

   # Deploy application
   kubectl create deployment nginx --image=nginx:latest
   kubectl expose deployment nginx --port=80 --type=LoadBalancer

   # Scale deployment
   kubectl scale deployment nginx --replicas=5

**Best Use Cases:**

- **Microservices architectures**
- **Multi-service applications requiring orchestration**
- **Applications needing advanced deployment patterns**
- **Workloads requiring service mesh capabilities**
- **Applications with complex scaling requirements**
- **Multi-tenant applications**

======================================
Service Comparison and Decision Matrix
======================================

**When to Choose Each Service:**

.. code-block:: text

   Decision Tree:
   
   Start Here
       │
       ▼
   ┌─────────────────────────────────────────┐
   │ Do you need infrastructure control?     │
   └─────────────┬───────────────────────────┘
                 │
        ┌────────▼────────┐
        │ YES             │ NO
        │                 │
        ▼                 ▼
   ┌─────────────┐   ┌─────────────────────────────────┐
   │ Compute     │   │ Is it a single containerized    │
   │ Engine      │   │ stateless service?              │
   │ (VMs)       │   └─────────────┬───────────────────┘
   └─────────────┘                 │
                            ┌──────▼──────┐
                            │ YES         │ NO
                            │             │
                            ▼             ▼
                    ┌───────────────┐ ┌─────────────┐
                    │ Cloud Run     │ │ GKE         │
                    │ (Serverless)  │ │ (Kubernetes)│
                    └───────────────┘ └─────────────┘

**Detailed Comparison Matrix:**

.. code-block:: text

   ┌────────────────────┬─────────────────┬─────────────────┬─────────────────┐
   │     Criteria       │   Cloud Run     │      GKE        │ Compute Engine  │
   ├────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Management Level   │ Fully Managed   │ Semi-Managed    │ Self-Managed    │
   ├────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Scaling Model      │ Auto (0-1000+)  │ Manual/Auto     │ Manual/Auto     │
   ├────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Pricing Model      │ Pay-per-request │ Pay-per-pod     │ Pay-per-VM      │
   ├────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Cold Start         │ 0-3 seconds     │ Pod startup     │ VM boot time    │
   ├────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Request Timeout    │ 60 minutes      │ Configurable    │ No limit        │
   ├────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Persistent Storage │ None            │ Yes (PV/PVC)    │ Yes (Disks)     │
   ├────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Network Control    │ Limited         │ Full (CNI)      │ Full (VPC)      │
   ├────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ OS Access          │ None            │ None            │ Full            │
   ├────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Multi-Service Apps │ External coord  │ Native support  │ Manual setup    │
   ├────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Vendor Lock-in     │ High            │ Low (K8s std)   │ Medium          │
   ├────────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Learning Curve     │ Low             │ High            │ Medium          │
   └────────────────────┴─────────────────┴─────────────────┴─────────────────┘

**Cost Analysis:**

.. code-block:: text

   Cost Comparison (Typical Web Application):
   
   Cloud Run (100K requests/month):
   ├─ CPU: $0.024/100ms x 100K = $2.40
   ├─ Memory: $0.0025/100ms x 100K = $0.25
   ├─ Requests: $0.40/1M x 0.1M = $0.04
   └─ Total: ~$2.69/month
   
   GKE Standard (3 e2-small nodes):
   ├─ Nodes: 3 x $15/month = $45.00
   ├─ Management fee: $74.40/month (free for Autopilot)
   └─ Total: ~$119.40/month
   
   Compute Engine (1 e2-medium instance):
   ├─ Instance: 1 x $25/month = $25.00
   ├─ Storage: 20GB x $0.04/GB = $0.80
   └─ Total: ~$25.80/month

============================
Real-World Use Case Examples
============================

**Example 1: E-commerce Platform**

.. code-block:: text

   E-commerce Architecture:
   
   ┌──────────────────────────────────────────────────────────┐
   │                Frontend (React SPA)                      │
   │                  Cloud Run                               │
   │  • Serves static assets and SSR                          │
   │  • Auto-scales during traffic spikes                     │
   │  • $2-5/month for normal traffic                         │
   └─────────────────┬────────────────────────────────────────┘
                     │ API calls
                     ▼
   ┌──────────────────────────────────────────────────────────┐
   │              Microservices (GKE)                         │
   │  ┌─────────────┬─────────────┬─────────────────────────┐ │
   │  │ User Service│Cart Service │ Payment Service         │ │
   │  │             │             │ (High Security)         │ │
   │  └─────────────┴─────────────┴─────────────────────────┘ │
   │  • Complex inter-service communication                   │
   │  • Service mesh for security and observability           │
   └─────────────────┬────────────────────────────────────────┘
                     │ Database connections
                     ▼
   ┌──────────────────────────────────────────────────────────┐
   │           Database (Compute Engine)                      │
   │  • PostgreSQL with specific performance tuning           │
   │  • Custom backup and replication setup                   │
   │  • Persistent storage with high IOPS                     │
   └──────────────────────────────────────────────────────────┘

**Example 2: Data Processing Pipeline**

.. code-block:: bash

   # Cloud Run for API ingestion
   gcloud run deploy data-ingestion-api \
     --image gcr.io/project/data-api:latest \
     --memory 2Gi \
     --cpu 2 \
     --max-instances 100

   # GKE for batch processing
   kubectl apply -f - <<EOF
   apiVersion: batch/v1
   kind: Job
   metadata:
     name: data-processor
   spec:
     parallelism: 10
     template:
       spec:
         containers:
         - name: processor
           image: gcr.io/project/data-processor:latest
           resources:
             requests:
               memory: "4Gi"
               cpu: "2"
   EOF

   # Compute Engine for ML training
   gcloud compute instances create ml-training-instance \
     --machine-type n1-highmem-16 \
     --accelerator type=nvidia-tesla-v100,count=4 \
     --boot-disk-size 200GB \
     --image-family pytorch-latest-gpu \
     --image-project deeplearning-platform-release

=====================================
Migration Strategies Between Services
=====================================

**From Compute Engine to Cloud Run:**

.. code-block:: text

   Migration Path: VM → Serverless
   
   Step 1: Containerize Application
   ┌─────────────────────────────────────────────┐
   │ VM Application                              │
   │ ├─ Install dependencies on VM               │
   │ ├─ Configure web server                     │
   │ └─ Start application                        │
   └─────────────────────────────────────────────┘
                    │ Containerize
                    ▼
   ┌─────────────────────────────────────────────┐
   │ Dockerfile                                  │
   │ FROM python:3.9-slim                        │
   │ COPY requirements.txt .                     │
   │ RUN pip install -r requirements.txt         │
   │ COPY app.py .                               │
   │ CMD ["python", "app.py"]                    │
   └─────────────────────────────────────────────┘
   
   Step 2: Make Stateless
   • Move sessions to external store (Redis)
   • Use environment variables for configuration
   • Implement health check endpoints
   
   Step 3: Deploy to Cloud Run
   gcloud run deploy my-app --source .

**From Cloud Run to GKE:**

.. code-block:: text

   Migration Path: Serverless → Kubernetes
   
   When to migrate:
   • Need persistent storage
   • Complex inter-service communication
   • Advanced networking requirements
   • Custom scaling policies
   
   Migration steps:
   1. Create Kubernetes manifests
   2. Set up service mesh (Istio)
   3. Configure persistent volumes
   4. Implement proper monitoring

==================================
Best Practices and Recommendations
==================================

**Cloud Run Best Practices:**

.. code-block:: text

   ✓ Design for statelessness
   ✓ Optimize container startup time
   ✓ Use minimal base images
   ✓ Implement proper health checks
   ✓ Set appropriate concurrency limits
   ✓ Use environment variables for configuration
   ✓ Implement graceful shutdown
   ✗ Don't store data locally
   ✗ Don't rely on sticky sessions
   ✗ Don't use long-running background tasks

**GKE Best Practices:**

.. code-block:: text

   ✓ Use namespaces for isolation
   ✓ Implement resource quotas and limits
   ✓ Use horizontal pod autoscaling
   ✓ Implement proper monitoring and logging
   ✓ Use secrets for sensitive data
   ✓ Implement network policies
   ✓ Use readiness and liveness probes
   ✗ Don't run as root in containers
   ✗ Don't store secrets in container images
   ✗ Don't ignore security contexts

**Compute Engine Best Practices:**

.. code-block:: text

   ✓ Use startup scripts for automation
   ✓ Implement regular backups
   ✓ Use managed instance groups for HA
   ✓ Configure proper firewall rules
   ✓ Use preemptible instances for cost savings
   ✓ Implement monitoring and alerting
   ✓ Keep OS and software updated
   ✗ Don't expose unnecessary ports
   ✗ Don't run services as root
   ✗ Don't ignore security patches

==========================================
Performance and Scalability Considerations
==========================================

**Latency Comparison:**

.. code-block:: text

   Cold Start Performance:
   
   Cloud Run:
   ├─ Container startup: 0.1-3 seconds
   ├─ Language runtime: 0.1-2 seconds
   └─ Total: 0.2-5 seconds
   
   GKE:
   ├─ Pod scheduling: 0.1-1 second
   ├─ Container startup: 0.1-3 seconds
   └─ Total: 0.2-4 seconds
   
   Compute Engine:
   ├─ VM boot: 20-60 seconds
   ├─ Service startup: 1-10 seconds
   └─ Total: 21-70 seconds

**Scaling Characteristics:**

.. code-block:: text

   Scaling Speed:
   
   Cloud Run:    0 → 1000 instances in ~10 seconds
   GKE:          1 → 100 pods in ~30 seconds
   Compute:      1 → 10 VMs in ~2-3 minutes

**Throughput Capabilities:**

.. code-block:: text

   Maximum Throughput (per instance):
   
   Cloud Run:    1000 concurrent requests
   GKE Pod:      Limited by container resources
   Compute VM:   Limited by VM size and config

=======================
Security Considerations
=======================

**Security Model Comparison:**

.. code-block:: text

   ┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐
   │ Security Aspect │   Cloud Run     │      GKE        │ Compute Engine  │
   ├─────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Network         │ Private Google  │ VPC Native      │ Full VPC        │
   │ Isolation       │ network         │ with policies   │ control         │
   ├─────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Container       │ Automatic       │ Pod Security    │ Manual          │
   │ Security        │ sandboxing      │ Standards       │ hardening       │
   ├─────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Identity        │ Service         │ Workload        │ Service         │
   │ Management      │ accounts        │ Identity        │ accounts        │
   ├─────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Secrets         │ Environment     │ Kubernetes      │ Metadata/       │
   │ Management      │ variables       │ secrets         │ Secret Manager  │
   ├─────────────────┼─────────────────┼─────────────────┼─────────────────┤
   │ Compliance      │ Automatic       │ Manual config   │ Full            │
   │ Controls        │ compliance      │ required        │ responsibility  │
   └─────────────────┴─────────────────┴─────────────────┴─────────────────┘

============================
Monitoring and Observability
============================

**Built-in Monitoring:**

.. code-block:: bash

   # Cloud Run monitoring
   gcloud run services describe SERVICE_NAME \
     --region=REGION \
     --format="table(status.traffic[].latestRevision:label=LATEST,
     status.traffic[].percent:label=PERCENT,
     status.traffic[].url:label=URL)"

   # GKE cluster monitoring
   kubectl top nodes
   kubectl top pods --all-namespaces

   # Compute Engine monitoring
   gcloud compute instances describe INSTANCE_NAME \
     --zone=ZONE \
     --format="table(status,machineType.basename(),
     scheduling.preemptible:label=PREEMPTIBLE)"

**Custom Metrics Setup:**

.. code-block:: yaml

   # GKE Prometheus monitoring
   apiVersion: v1
   kind: ServiceMonitor
   metadata:
     name: app-metrics
   spec:
     selector:
       matchLabels:
         app: my-application
     endpoints:
     - port: metrics
       path: /metrics

===============================
Summary and Decision Guidelines
===============================

**Quick Decision Guide:**

.. code-block:: text

   Choose Cloud Run when:
   ✓ Building stateless web APIs or microservices
   ✓ Traffic is sporadic or unpredictable
   ✓ Want zero infrastructure management
   ✓ Need automatic HTTPS and scaling
   ✓ Budget-conscious for low-traffic applications
   
   Choose GKE when:
   ✓ Managing multiple interconnected services
   ✓ Need advanced deployment strategies
   ✓ Require service mesh capabilities
   ✓ Want Kubernetes portability
   ✓ Have complex networking requirements
   
   Choose Compute Engine when:
   ✓ Need full OS control and customization
   ✓ Running legacy applications
   ✓ Require specific compliance controls
   ✓ Need persistent local storage
   ✓ Have long-running or stateful workloads

**Cost-Performance Sweet Spots:**

.. code-block:: text

   Development/Testing:    Cloud Run (lowest cost)
   Small Production:       Cloud Run (best value)
   Medium Production:      GKE Autopilot (balanced)
   Large Production:       GKE Standard (most control)
   Enterprise/Legacy:      Compute Engine (maximum flexibility)

The choice between Cloud Run, GKE, and Compute Engine ultimately depends on your specific requirements for control, scalability, cost, and operational complexity. Start simple with Cloud Run, evolve to GKE for orchestration needs, and use Compute Engine when you need maximum control.
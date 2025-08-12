####
TODO
####

**Mastering Container Orchestration in Production**

This chapter's assignments test your understanding of Kubernetes concepts and your ability to deploy, manage, and troubleshoot containerized applications in production environments. Complete all theoretical questions before moving to practical deployments.

**Time Allocation:**

- Theoretical Questions: 60-90 minutes total
- Easy Deployments: 30 minutes each (150 minutes total)
- Advanced Deployments: 30 minutes each (90 minutes total)

=====================
Theoretical Questions
=====================

**Instructions:** Answer each question concisely but comprehensively. Focus on practical understanding rather than memorization.

**Q1. Control Loop Pattern**
Explain how Kubernetes' control loop pattern ensures application reliability. Provide a specific scenario where a pod crashes and describe the step-by-step process Kubernetes uses to restore the desired state.

**Q2. Pods vs Containers**
A developer asks: "Why do we need Pods when we already have containers? Can't we just run containers directly?" Explain the concept of Pods and provide two practical examples where multiple containers in a single Pod make sense.

**Q3. Service Discovery**
Your web application needs to connect to a database. In Docker Compose, you used service names. How does service discovery work in Kubernetes? Explain the role of Services, DNS, and environment variables.

**Q4. Declarative vs Imperative**
Compare declarative and imperative approaches in Kubernetes. Provide examples of both styles and explain why declarative management is preferred for production environments.

**Q5. Rolling Updates**
Describe how Kubernetes performs zero-downtime deployments using rolling updates. What happens if the new version of your application has a critical bug? Explain the rollback process.

**Q6. Resource Management**
A Pod keeps getting killed with "OOMKilled" status. Explain what this means and how you would use resource requests and limits to prevent this issue. Provide a YAML example.

**Q7. ConfigMaps vs Secrets**
When should you use ConfigMaps versus Secrets? Provide practical examples for each and explain the security implications of improper usage.

**Q8. Horizontal Pod Autoscaler**
Your application experiences traffic spikes during business hours. Explain how Horizontal Pod Autoscaler (HPA) works and what metrics it can use to make scaling decisions.

**Q9. Kubernetes Architecture**
A colleague claims "If the master node fails, all applications stop working." Is this statement correct? Explain the role of the control plane vs worker nodes and how high availability is achieved.

**Q10. GitOps Workflow**
Describe a complete GitOps workflow where code changes automatically deploy to Kubernetes. Include CI/CD pipeline steps, image tagging strategies, and deployment validation.

=====================
Practical Deployments
=====================

**Prerequisites:**

- Local Kubernetes cluster (kind, k3s, k0s, Rancher Desktop, or Docker Desktop)
- kubectl configured and working
- Basic understanding of YAML syntax

======================================
Easy Deployments (5 x 30 minutes each)
======================================

**Deploy 1: Static Web Application**
**Scenario:** Deploy a simple Python FastAPI web server that serves custom content.

**Requirements:**

1. Create a deployment with 3 replicas of a Python FastAPI application
2. Use a ConfigMap to provide custom application configuration
3. Expose the application using a LoadBalancer service
4. Verify the application is accessible and serving your custom content

**Deliverables:**

- `deployment.yaml`
- `configmap.yaml` (for application configuration or custom content)
- `service.yaml`
- Screenshot showing the custom Python FastAPI webpage

**Deploy 2: Database with Persistent Storage**
**Scenario:** Deploy PostgreSQL database with persistent data storage.

**Requirements:**

1. Create a PersistentVolumeClaim for database storage
2. Deploy PostgreSQL using the official image
3. Use a Secret to store database credentials
4. Create a Service for internal database access
5. Verify data persists after pod restart

**Deliverables:**

- `postgres-deployment.yaml`
- `postgres-pvc.yaml`
- `postgres-secret.yaml`
- `postgres-service.yaml`
- Commands showing data persistence test

**Deploy 3: Multi-Tier Application**
**Scenario:** Deploy a complete web application stack with Python FastAPI frontend and backend.

**Requirements:**

1. Deploy a Python FastAPI backend API with RESTful endpoints
2. Deploy a Python FastAPI frontend web application
3. Configure the frontend to communicate with the backend via HTTP requests
4. Use appropriate Services for inter-service communication
5. Expose only the frontend to external traffic

**Deliverables:**

- `fastapi-backend-deployment.yaml`
- `fastapi-frontend-deployment.yaml`
- `backend-service.yaml`
- `frontend-service.yaml`
- Network diagram showing communication flow

**Deploy 4: Application Health Monitoring**
**Scenario:** Deploy a Python FastAPI application with comprehensive health checking.

**Requirements:**

1. Deploy a Python FastAPI web application with health endpoints (/health, /ready)
2. Configure liveness probes to restart unhealthy containers
3. Configure readiness probes to control traffic routing
4. Implement startup probes for slow-starting applications
5. Test probe functionality by simulating failures

**Deliverables:**

- `fastapi-app-deployment.yaml` with all three probe types
- Commands demonstrating probe behavior
- Documentation of test scenarios and results

**Deploy 5: Resource-Constrained Environment**
**Scenario:** Deploy Python FastAPI applications with proper resource management.

**Requirements:**

1. Deploy a memory-intensive Python FastAPI application (use libraries like pandas or numpy)
2. Set appropriate resource requests and limits
3. Configure a ResourceQuota for the namespace
4. Deploy a second Python FastAPI application that respects the quota
5. Demonstrate what happens when resources are exceeded

**Deliverables:**

- `fastapi-app-deployment.yaml` with resource specifications
- `resource-quota.yaml`
- `namespace.yaml`
- Documentation showing resource enforcement

==========================================
Advanced Deployments (3 x 30 minutes each)
==========================================

**Advanced Deploy 1: Blue-Green Deployment**
**Scenario:** Implement a blue-green deployment strategy for zero-downtime updates using Python FastAPI applications.

**Requirements:**

1. Deploy version 1 of a Python FastAPI application (blue environment)
2. Deploy version 2 alongside version 1 (green environment) with different features
3. Use Services and labels to switch traffic between versions
4. Implement a rollback mechanism
5. Document the complete process and traffic switching

**Deliverables:**

- `blue-deployment.yaml` (Python FastAPI v1.0)
- `green-deployment.yaml` (Python FastAPI v2.0 with new features)
- `service.yaml` with selector switching capability
- Shell script automating the blue-green switch
- Documentation of the deployment process

**Advanced Deploy 2: Microservices with Service Mesh**
**Scenario:** Deploy a Python FastAPI microservices application with advanced networking.

**Requirements:**

1. Deploy 3-4 Python FastAPI microservices that communicate with each other
2. Implement service-to-service authentication using Secrets and API keys
3. Use Network Policies to restrict inter-service communication
4. Implement circuit breaker pattern using Python libraries (httpx with retries)
5. Add distributed tracing headers between services

**Deliverables:**

- Multiple Python FastAPI microservice deployment files
- `network-policy.yaml` restricting traffic
- Documentation of service communication patterns
- Example API calls showing authentication
- Network topology diagram

**Advanced Deploy 3: GitOps Pipeline Integration**
**Scenario:** Create a complete GitOps workflow with automated deployment for Python FastAPI applications.

**Requirements:**

1. Set up a Git repository with Kubernetes manifests for Python FastAPI applications
2. Create a GitHub Action that builds and pushes Python FastAPI Docker images
3. Implement automatic deployment when manifests change
4. Include environment promotion (dev → staging → prod)
5. Add deployment validation and health checks for Python FastAPI services

**Deliverables:**

- GitHub repository with complete Python FastAPI application workflow
- `.github/workflows/deploy.yaml` for Python FastAPI Docker builds
- Multi-environment Kubernetes manifests for Python FastAPI services
- Deployment validation scripts for Python FastAPI applications
- Documentation of the complete GitOps flow

====================
Additional Resources
====================

**Kubernetes Documentation:**
- Official Kubernetes tutorials: https://kubernetes.io/docs/tutorials/
- Best practices guide: https://kubernetes.io/docs/concepts/configuration/overview/

**Tools for Testing:**
- `kubectl explain <resource>` - Get documentation for any Kubernetes resource
- `kubectl describe <resource> <name>` - Debug resource issues
- `kubectl logs <pod-name>` - View application logs
- `kubectl port-forward <resource> <local-port>:<remote-port>` - Test connectivity

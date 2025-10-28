##############################
11.9 Security Best Practices
##############################

.. note::

    Security is a shared responsibility between Google Cloud and you. Google secures the underlying infrastructure, while you're responsible for securing your applications, data, and access controls. This chapter covers GCP security best practices, tools, and services to help you build and maintain secure cloud environments.

====================================
Security Shared Responsibility Model
====================================

**Google's Responsibilities:**

- Physical security of data centers
- Hardware and network infrastructure
- Hypervisor and host OS security
- Service availability and reliability
- Data encryption at rest by default

**Your Responsibilities:**

- Identity and Access Management (IAM)
- Data classification and encryption keys
- Network configuration
- Application security
- Access controls and monitoring
- Compliance requirements

====================================
Identity and Access Management (IAM)
====================================

**Principle of Least Privilege:**

.. code-block:: bash

    # BAD: Granting owner role to everyone
    gcloud projects add-iam-policy-binding my-project \
        --member="user:alice@example.com" \
        --role="roles/owner"
    
    # GOOD: Grant specific roles needed
    gcloud projects add-iam-policy-binding my-project \
        --member="user:alice@example.com" \
        --role="roles/compute.instanceAdmin.v1"

**Service Account Best Practices:**

.. code-block:: bash

    # Create service account with descriptive name
    gcloud iam service-accounts create app-backend-sa \
        --display-name="Backend Application Service Account" \
        --description="SA for backend application with minimal permissions"
    
    # Grant only necessary permissions
    gcloud projects add-iam-policy-binding my-project \
        --member="serviceAccount:app-backend-sa@my-project.iam.gserviceaccount.com" \
        --role="roles/storage.objectViewer"
    
    # Disable default service account
    gcloud iam service-accounts disable \
        PROJECT_NUMBER-compute@developer.gserviceaccount.com

**Use Workload Identity (GKE):**

.. code-block:: bash

    # Enable Workload Identity on cluster
    gcloud container clusters update my-cluster \
        --zone=us-central1-a \
        --workload-pool=PROJECT_ID.svc.id.goog
    
    # Create Kubernetes service account
    kubectl create serviceaccount app-ksa
    
    # Bind Kubernetes SA to Google SA
    gcloud iam service-accounts add-iam-policy-binding \
        app-backend-sa@PROJECT_ID.iam.gserviceaccount.com \
        --role roles/iam.workloadIdentityUser \
        --member "serviceAccount:PROJECT_ID.svc.id.goog[default/app-ksa]"
    
    # Annotate Kubernetes service account
    kubectl annotate serviceaccount app-ksa \
        iam.gke.io/gcp-service-account=app-backend-sa@PROJECT_ID.iam.gserviceaccount.com

**Regular Access Reviews:**

.. code-block:: bash

    # List all IAM policies
    gcloud projects get-iam-policy my-project \
        --format=json > iam-policy.json
    
    # Audit service accounts
    gcloud iam service-accounts list \
        --format="table(email,displayName,disabled)"
    
    # Find unused service accounts
    gcloud recommender recommendations list \
        --project=PROJECT_ID \
        --location=global \
        --recommender=google.iam.policy.Recommender

================
Network Security
================

**VPC Security:**

.. code-block:: bash

    # Create custom VPC
    gcloud compute networks create secure-vpc \
        --subnet-mode=custom \
        --bgp-routing-mode=regional
    
    # Create subnet with Private Google Access
    gcloud compute networks subnets create private-subnet \
        --network=secure-vpc \
        --region=us-central1 \
        --range=10.0.1.0/24 \
        --enable-private-ip-google-access

**Firewall Rules Best Practices:**

.. code-block:: bash

    # Default deny all ingress (implicit in GCP)
    # Only allow necessary traffic
    
    # Allow SSH only from specific IP (bastion)
    gcloud compute firewall-rules create allow-ssh-bastion \
        --network=secure-vpc \
        --allow=tcp:22 \
        --source-ranges=10.0.0.10/32 \
        --target-tags=ssh-access
    
    # Allow HTTPS from internet
    gcloud compute firewall-rules create allow-https \
        --network=secure-vpc \
        --allow=tcp:443 \
        --source-ranges=0.0.0.0/0 \
        --target-tags=web-server
    
    # Allow internal communication between VMs
    gcloud compute firewall-rules create allow-internal \
        --network=secure-vpc \
        --allow=tcp:0-65535,udp:0-65535,icmp \
        --source-ranges=10.0.0.0/16
    
    # Log firewall rules for monitoring
    gcloud compute firewall-rules update allow-https \
        --enable-logging

**Cloud NAT for Egress:**

.. code-block:: bash

    # Create Cloud Router
    gcloud compute routers create nat-router \
        --network=secure-vpc \
        --region=us-central1
    
    # Configure Cloud NAT (VMs don't need public IPs)
    gcloud compute routers nats create nat-config \
        --router=nat-router \
        --region=us-central1 \
        --nat-all-subnet-ip-ranges \
        --auto-allocate-nat-external-ips

**Private GKE Cluster:**

.. code-block:: bash

    # Create private GKE cluster
    gcloud container clusters create private-cluster \
        --zone=us-central1-a \
        --enable-private-nodes \
        --enable-private-endpoint \
        --enable-ip-alias \
        --master-ipv4-cidr=172.16.0.0/28 \
        --no-enable-basic-auth \
        --no-issue-client-certificate

**VPC Service Controls:**

.. code-block:: bash

    # Create access policy
    gcloud access-context-manager policies create \
        --organization=ORGANIZATION_ID \
        --title="Production Access Policy"
    
    # Create service perimeter
    gcloud access-context-manager perimeters create prod_perimeter \
        --title="Production Perimeter" \
        --resources=projects/PROJECT_NUMBER \
        --restricted-services=storage.googleapis.com,bigquery.googleapis.com \
        --policy=POLICY_ID

=============
Data Security
=============

**Encryption at Rest:**

.. code-block:: bash

    # Create encryption key
    gcloud kms keyrings create my-keyring \
        --location=us-central1
    
    gcloud kms keys create my-key \
        --location=us-central1 \
        --keyring=my-keyring \
        --purpose=encryption
    
    # Create disk with customer-managed encryption
    gcloud compute disks create encrypted-disk \
        --size=100GB \
        --zone=us-central1-a \
        --kms-key=projects/PROJECT_ID/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key
    
    # Create VM with encrypted disk
    gcloud compute instances create secure-vm \
        --zone=us-central1-a \
        --disk=name=encrypted-disk,boot=yes

**Encryption in Transit:**

.. code-block:: bash

    # All GCP services use TLS by default
    # For custom apps, ensure TLS is enabled
    
    # Create SSL certificate for Load Balancer
    gcloud compute ssl-certificates create my-cert \
        --certificate=cert.pem \
        --private-key=key.pem \
        --global

**Secret Management:**

.. code-block:: bash

    # Enable Secret Manager API
    gcloud services enable secretmanager.googleapis.com
    
    # Create secret
    echo -n "my-db-password" | gcloud secrets create db-password \
        --data-file=-
    
    # Grant access to service account
    gcloud secrets add-iam-policy-binding db-password \
        --member="serviceAccount:app-sa@PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/secretmanager.secretAccessor"
    
    # Access secret in application
    gcloud secrets versions access latest --secret="db-password"

**Use Secret Manager with GKE:**

.. code-block:: yaml

    # deployment.yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: app-pod
    spec:
      serviceAccountName: app-ksa
      containers:
      - name: app
        image: myapp:1.0
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-password
              key: password

.. code-block:: bash

    # Install External Secrets Operator
    helm repo add external-secrets https://charts.external-secrets.io
    helm install external-secrets external-secrets/external-secrets
    
    # Create SecretStore
    cat <<EOF | kubectl apply -f -
    apiVersion: external-secrets.io/v1beta1
    kind: SecretStore
    metadata:
      name: gcpsm-secret-store
    spec:
      provider:
        gcpsm:
          projectID: "PROJECT_ID"
          auth:
            workloadIdentity:
              clusterLocation: us-central1
              clusterName: my-cluster
              serviceAccountRef:
                name: app-ksa
    EOF

**Data Loss Prevention (DLP):**

.. code-block:: python

    # dlp-scan.py
    from google.cloud import dlp_v2
    
    def inspect_content(project_id, content):
        """Scan content for sensitive data."""
        dlp = dlp_v2.DlpServiceClient()
        
        parent = f"projects/{project_id}"
        
        # Configure what to scan for
        info_types = [
            {"name": "EMAIL_ADDRESS"},
            {"name": "PHONE_NUMBER"},
            {"name": "CREDIT_CARD_NUMBER"},
            {"name": "US_SOCIAL_SECURITY_NUMBER"}
        ]
        
        inspect_config = {
            "info_types": info_types,
            "min_likelihood": dlp_v2.Likelihood.POSSIBLE
        }
        
        item = {"value": content}
        
        response = dlp.inspect_content(
            request={
                "parent": parent,
                "inspect_config": inspect_config,
                "item": item
            }
        )
        
        if response.result.findings:
            print("Sensitive data found:")
            for finding in response.result.findings:
                print(f"  - {finding.info_type.name}: {finding.quote}")
        else:
            print("No sensitive data found.")

================
Compute Security
================

**VM Security Best Practices:**

.. code-block:: bash

    # Use Shielded VMs (secure boot, vTPM, integrity monitoring)
    gcloud compute instances create secure-vm \
        --zone=us-central1-a \
        --machine-type=n1-standard-2 \
        --shielded-secure-boot \
        --shielded-vtpm \
        --shielded-integrity-monitoring
    
    # Disable external IP (use Cloud NAT)
    gcloud compute instances create private-vm \
        --zone=us-central1-a \
        --machine-type=n1-standard-2 \
        --no-address \
        --subnet=private-subnet
    
    # Use custom service account
    gcloud compute instances create vm-with-sa \
        --zone=us-central1-a \
        --service-account=app-sa@PROJECT_ID.iam.gserviceaccount.com \
        --scopes=cloud-platform
    
    # Enable OS Login (instead of SSH keys)
    gcloud compute instances add-metadata vm-with-oslogin \
        --zone=us-central1-a \
        --metadata=enable-oslogin=TRUE

**OS Patch Management:**

.. code-block:: bash

    # Enable OS Config API
    gcloud services enable osconfig.googleapis.com
    
    # Create patch deployment
    gcloud compute os-config patch-deployments create monthly-patches \
        --file=patch-deployment.yaml

.. code-block:: yaml

    # patch-deployment.yaml
    patchConfig:
      rebootConfig: DEFAULT
      apt:
        type: DIST
    oneTimeSchedule:
      executeTime: '2024-02-01T02:00:00Z'
    instanceFilter:
      all: true

**Container Security:**

.. code-block:: bash

    # Scan container images for vulnerabilities
    gcloud artifacts docker images scan \
        us-central1-docker.pkg.dev/PROJECT_ID/my-repo/myapp:latest
    
    # View scan results
    gcloud artifacts docker images list-vulnerabilities \
        us-central1-docker.pkg.dev/PROJECT_ID/my-repo/myapp:latest

**Binary Authorization:**

.. code-block:: bash

    # Enable Binary Authorization
    gcloud services enable binaryauthorization.googleapis.com
    
    # Create policy requiring attestations
    cat > policy.yaml << EOF
    admissionWhitelistPatterns:
    - namePattern: gcr.io/google-containers/*
    - namePattern: k8s.gcr.io/*
    defaultAdmissionRule:
      requireAttestationsBy:
      - projects/PROJECT_ID/attestors/my-attestor
      enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
    globalPolicyEvaluationMode: ENABLE
    EOF
    
    gcloud container binauthz policy import policy.yaml

======================
Monitoring and Logging
======================

**Cloud Logging:**

.. code-block:: bash

    # View logs
    gcloud logging read "resource.type=gce_instance" \
        --limit 50 \
        --format json
    
    # Create log sink to export logs
    gcloud logging sinks create security-logs-sink \
        storage.googleapis.com/security-logs-bucket \
        --log-filter='severity >= ERROR'
    
    # Create metric from logs
    gcloud logging metrics create failed-login-attempts \
        --description="Count of failed login attempts" \
        --log-filter='resource.type="gce_instance" AND
                     textPayload=~"Failed password"'

**Cloud Monitoring Alerts:**

.. code-block:: bash

    # Create alert policy
    cat > alert-policy.yaml << EOF
    displayName: "High Failed Login Attempts"
    conditions:
    - displayName: "Failed logins > 10"
      conditionThreshold:
        filter: 'metric.type="logging.googleapis.com/user/failed-login-attempts"'
        comparison: COMPARISON_GT
        thresholdValue: 10
        duration: 300s
    notificationChannels:
    - projects/PROJECT_ID/notificationChannels/CHANNEL_ID
    EOF
    
    gcloud alpha monitoring policies create --policy-from-file=alert-policy.yaml

**Audit Logging:**

.. code-block:: bash

    # Admin Activity logs (always on, free)
    gcloud logging read "logName:activity" --limit 10
    
    # Data Access logs (must be enabled)
    gcloud logging read "logName:data_access" --limit 10
    
    # Query specific events
    gcloud logging read \
        'protoPayload.methodName="v1.compute.instances.delete"' \
        --limit 10 \
        --format json

**Security Command Center:**

.. code-block:: bash

    # Enable Security Command Center
    gcloud services enable securitycenter.googleapis.com
    
    # List findings
    gcloud scc findings list ORGANIZATION_ID \
        --filter="state=\"ACTIVE\""
    
    # Get specific finding
    gcloud scc findings describe FINDING_NAME

=================
Security Scanning
=================

**Web Security Scanner:**

.. code-block:: bash

    # Enable Web Security Scanner API
    gcloud services enable websecurityscanner.googleapis.com
    
    # Create scan configuration
    gcloud alpha web-security-scanner scan-configs create \
        --display-name="My App Scan" \
        --starting-urls="https://myapp.example.com"
    
    # Start scan
    gcloud alpha web-security-scanner scan-runs start \
        SCAN_CONFIG_NAME

**Container Analysis:**

.. code-block:: bash

    # Automatically scans images pushed to Container Registry/Artifact Registry
    # View vulnerabilities
    gcloud container images describe \
        gcr.io/PROJECT_ID/myapp:latest \
        --show-package-vulnerability

**Event Threat Detection:**

- Automatically enabled in Security Command Center
- Detects:
  - Malware
  - Cryptomining
  - Brute force SSH
  - IAM anomalies
  - Data exfiltration

=========================
Compliance and Governance
=========================

**Organization Policies:**

.. code-block:: bash

    # Require OS Login on all VMs
    gcloud resource-manager org-policies enable-enforce \
        compute.requireOsLogin \
        --organization=ORGANIZATION_ID
    
    # Restrict VM external IPs
    gcloud resource-manager org-policies set-policy \
        restrict-vm-external-ips.yaml \
        --organization=ORGANIZATION_ID

.. code-block:: yaml

    # restrict-vm-external-ips.yaml
    constraint: compute.vmExternalIpAccess
    listPolicy:
      deniedValues:
      - "*"

**Resource Hierarchy:**

.. code-block:: bash

    # Best practice: Use folders for organization
    # Organization
    #   └── Folder: Production
    #       ├── Project: prod-web
    #       └── Project: prod-api
    #   └── Folder: Development
    #       ├── Project: dev-web
    #       └── Project: dev-api
    
    # Create folder
    gcloud resource-manager folders create \
        --display-name="Production" \
        --organization=ORGANIZATION_ID

**Access Transparency:**

.. code-block:: bash

    # View Access Transparency logs (Enterprise only)
    gcloud logging read \
        'logName:"cloudaudit.googleapis.com%2Faccess_transparency"' \
        --limit 10

=================
Incident Response
=================

**Incident Response Plan:**

1. **Detection**

   - Monitor Security Command Center
   - Set up alerts for anomalies
   - Regular log reviews

2. **Analysis**

   - Review audit logs
   - Check Cloud Monitoring
   - Investigate affected resources

3. **Containment**

   - Isolate affected resources
   - Revoke compromised credentials
   - Apply firewall rules

4. **Eradication**

   - Remove malicious resources
   - Patch vulnerabilities
   - Update access controls

5. **Recovery**

   - Restore from backups
   - Verify system integrity
   - Resume normal operations

6. **Post-Incident**

   - Document incident
   - Update procedures
   - Implement preventive measures

**Quick Response Commands:**

.. code-block:: bash

    # Disable compromised service account
    gcloud iam service-accounts disable \
        compromised-sa@PROJECT_ID.iam.gserviceaccount.com
    
    # Remove IAM binding immediately
    gcloud projects remove-iam-policy-binding my-project \
        --member="user:compromised@example.com" \
        --role="roles/owner"
    
    # Block VM from internet
    gcloud compute firewall-rules create block-compromised-vm \
        --action=DENY \
        --rules=all \
        --source-ranges=0.0.0.0/0 \
        --target-tags=compromised-vm \
        --priority=100
    
    # Stop VM immediately
    gcloud compute instances stop compromised-vm \
        --zone=us-central1-a
    
    # Take snapshot for forensics
    gcloud compute disks snapshot compromised-disk \
        --snapshot-names=forensic-snapshot-$(date +%s) \
        --zone=us-central1-a

===================
Security Automation
===================

**Automated Security Checks:**

.. code-block:: python

    # security-checks.py
    from google.cloud import compute_v1
    from google.cloud import logging
    
    def check_vm_security(project_id, zone):
        """Check VMs for security best practices."""
        compute = compute_v1.InstancesClient()
        instances = compute.list(project=project_id, zone=zone)
        
        issues = []
        
        for instance in instances:
            # Check for external IP
            for interface in instance.network_interfaces:
                if interface.access_configs:
                    issues.append(f"{instance.name}: Has external IP")
            
            # Check for default service account
            for sa in instance.service_accounts:
                if 'compute@developer' in sa.email:
                    issues.append(f"{instance.name}: Uses default SA")
            
            # Check for Shielded VM
            if not instance.shielded_instance_config:
                issues.append(f"{instance.name}: Not a Shielded VM")
        
        return issues
    
    # Run checks
    issues = check_vm_security('my-project', 'us-central1-a')
    for issue in issues:
        print(f"{issue}")

**Security Response Automation:**

.. code-block:: python

    # auto-response.py
    from google.cloud import pubsub_v1
    from google.cloud import compute_v1
    import json
    
    def handle_security_finding(event, context):
        """Respond to Security Command Center finding."""
        pubsub_message = base64.b64decode(event['data']).decode('utf-8')
        finding = json.loads(pubsub_message)
        
        # Check finding type
        if finding['category'] == 'MALWARE':
            # Isolate affected VM
            instance_name = extract_instance_name(finding)
            isolate_vm(instance_name)
            send_alert(f"VM {instance_name} isolated due to malware")
    
    def isolate_vm(instance_name):
        """Apply deny-all firewall rule to VM."""
        compute = compute_v1.FirewallsClient()
        # Create isolation rule
        # Implementation details...

==================
Security Checklist
==================

**IAM and Authentication:**

Use principle of least privilege
Enable MFA for all users
Regular access reviews
Use service accounts instead of user accounts
Enable Workload Identity for GKE
Disable default service accounts
Set up Cloud Identity for user management

**Network Security:**

Use private IPs where possible
Implement firewall rules with logging
Enable VPC Flow Logs
Use Cloud NAT for egress
Implement VPC Service Controls
Use Private Google Access
Enable DDoS protection

**Data Security:**

Enable encryption at rest (CMEK where needed)
Ensure encryption in transit (TLS)
Use Secret Manager for secrets
Implement data classification
Enable DLP scanning
Regular backups with testing
Implement retention policies

**Compute Security:**

Use Shielded VMs
Enable OS Login
Disable external IPs
Regular patching
Container vulnerability scanning
Enable Binary Authorization
Use minimal base images

**Monitoring and Logging:**

Enable audit logging
Set up Cloud Monitoring alerts
Export logs to Cloud Storage
Enable Security Command Center
Configure log retention
Regular log analysis
Incident response plan

**Compliance:**

Implement organization policies
Use resource hierarchy
Enable Access Transparency (if needed)
Regular compliance audits
Document security controls
Security training for team

======================
Security Tools Summary
======================

+--------------------------------+----------------------------------------+
| Tool                           | Purpose                                |
+================================+========================================+
| Cloud IAM                      | Identity and access management         |
+--------------------------------+----------------------------------------+
| VPC Service Controls           | Create security perimeters             |
+--------------------------------+----------------------------------------+
| Secret Manager                 | Manage secrets securely                |
+--------------------------------+----------------------------------------+
| Cloud KMS                      | Encryption key management              |
+--------------------------------+----------------------------------------+
| Security Command Center        | Centralized security dashboard         |
+--------------------------------+----------------------------------------+
| Web Security Scanner           | Scan web apps for vulnerabilities      |
+--------------------------------+----------------------------------------+
| Container Analysis             | Scan container images                  |
+--------------------------------+----------------------------------------+
| Binary Authorization           | Deploy only verified containers        |
+--------------------------------+----------------------------------------+
| Cloud Armor                    | DDoS protection and WAF                |
+--------------------------------+----------------------------------------+
| Cloud DLP                      | Discover and protect sensitive data    |
+--------------------------------+----------------------------------------+
| Cloud Logging                  | Centralized logging                    |
+--------------------------------+----------------------------------------+
| Cloud Monitoring               | Alerting and monitoring                |
+--------------------------------+----------------------------------------+
| Organization Policy            | Enforce compliance                     |
+--------------------------------+----------------------------------------+
| Access Transparency            | Log Google access to your data         |
+--------------------------------+----------------------------------------+

======================
Best Practices Summary
======================

**1. Defense in Depth:**

- Multiple layers of security
- Assume breach mentality
- Zero trust architecture

**2. Automation:**

- Automate security checks
- Automated incident response
- Infrastructure as Code with security

**3. Monitoring:**

- Continuous monitoring
- Real-time alerts
- Regular audits

**4. Training:**

- Regular security training
- Security awareness program
- Incident response drills

**5. Documentation:**

- Security policies
- Incident response procedures
- Architecture documentation

====================
Additional Resources
====================

- GCP Security Overview: https://cloud.google.com/security
- Security Command Center: https://cloud.google.com/security-command-center
- Security Best Practices: https://cloud.google.com/security/best-practices
- Compliance Documentation: https://cloud.google.com/security/compliance
- Security Bulletins: https://cloud.google.com/support/bulletins
- NIST Cybersecurity Framework on GCP: https://cloud.google.com/architecture/framework/security

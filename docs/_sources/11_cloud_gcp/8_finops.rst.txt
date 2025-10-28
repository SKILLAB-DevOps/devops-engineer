###################################
11.8 FinOps and Cost Optimization
###################################

.. note::

    FinOps (Financial Operations) is the practice of bringing financial accountability to cloud spending. Google Cloud provides numerous tools and strategies to help you monitor, analyze, and optimize your cloud costs. This chapter covers cost management best practices, monitoring tools, and optimization strategies specific to GCP.

=========================
Understanding GCP Pricing
=========================

**Key Pricing Concepts:**

- **Pay-as-you-go**: Pay only for what you use
- **Per-second billing**: Most services billed per second (minimum 1 minute)
- **Sustained use discounts**: Automatic discounts for long-running workloads
- **Committed use discounts**: Discounts for 1 or 3-year commitments
- **Free tier**: Always free and trial offerings
- **Network egress**: Data leaving GCP incurs charges

**Major Cost Categories:**

+---------------------------+----------------------------------+
| Category                  | Examples                         |
+===========================+==================================+
| Compute                   | VMs, GKE nodes, Cloud Run        |
+---------------------------+----------------------------------+
| Storage                   | Cloud Storage, Persistent Disks  |
+---------------------------+----------------------------------+
| Networking                | Load Balancers, Egress traffic   |
+---------------------------+----------------------------------+
| Data Processing           | BigQuery, Dataflow               |
+---------------------------+----------------------------------+
| Databases                 | Cloud SQL, Firestore             |
+---------------------------+----------------------------------+

=====================
Cost Management Tools
=====================

**1. Cloud Billing Reports:**

.. code-block:: bash

    # Enable Cloud Billing API
    gcloud services enable cloudbilling.googleapis.com
    
    # List billing accounts
    gcloud billing accounts list
    
    # View billing account details
    gcloud billing accounts describe BILLING_ACCOUNT_ID

**Access Billing Reports:**

- Navigate to Cloud Console → Billing → Reports
- View costs by:
  - Project
  - Service
  - SKU (Stock Keeping Unit)
  - Location
  - Label
- Filter by time range
- Group and filter data
- Export to BigQuery for analysis

**2. Cost Table:**

View detailed cost breakdown:

- Navigate to Billing → Cost table
- See itemized costs
- Drill down into specific resources
- Identify cost drivers

**3. Pricing Calculator:**

Estimate costs before deployment:

- Visit: https://cloud.google.com/products/calculator
- Select services and configurations
- Get monthly cost estimates
- Save and share estimates

=============================
Setting Up Budgets and Alerts
=============================

**Create Budget via Console:**

1. Navigate to Billing → Budgets & alerts
2. Click "Create budget"
3. Set budget scope (all projects or specific)
4. Set budget amount
5. Configure threshold alerts

**Create Budget via gcloud:**

.. code-block:: bash

    # Create budget with alerts
    gcloud billing budgets create \
        --billing-account=BILLING_ACCOUNT_ID \
        --display-name="Monthly Budget" \
        --budget-amount=1000USD \
        --threshold-rule=percent=50 \
        --threshold-rule=percent=90 \
        --threshold-rule=percent=100

**Budget Alert Configuration:**

.. code-block:: yaml

    # budget.yaml
    displayName: "Production Environment Budget"
    budgetFilter:
      projects:
      - projects/my-prod-project
      services:
      - services/95FF-2EF5-5EA1  # Compute Engine
    amount:
      specifiedAmount:
        currencyCode: USD
        units: 1000
    thresholdRules:
    - thresholdPercent: 0.5
      spendBasis: CURRENT_SPEND
    - thresholdPercent: 0.9
      spendBasis: CURRENT_SPEND
    - thresholdPercent: 1.0
      spendBasis: CURRENT_SPEND

**Programmatic Budget Alerts:**

.. code-block:: bash

    # Create Pub/Sub topic for budget alerts
    gcloud pubsub topics create budget-alerts
    
    # Create Cloud Function to process alerts
    cat > main.py << 'EOF'
    import base64
    import json
    
    def process_budget_alert(event, context):
        """Process budget alert from Pub/Sub."""
        pubsub_message = base64.b64decode(event['data']).decode('utf-8')
        notification = json.loads(pubsub_message)
        
        cost_amount = notification['costAmount']
        budget_amount = notification['budgetAmount']
        
        if cost_amount >= budget_amount:
            print(f"ALERT: Budget exceeded! Cost: ${cost_amount}, Budget: ${budget_amount}")
            # Add your notification logic here
            # - Send email
            # - Send Slack message
            # - Create incident ticket
            # - Shutdown non-critical resources
    EOF

============================
Cost Optimization Strategies
============================

**1. Compute Engine Optimization:**

**Right-sizing VMs:**

.. code-block:: bash

    # Get VM recommendations
    gcloud recommender recommendations list \
        --project=PROJECT_ID \
        --location=us-central1 \
        --recommender=google.compute.instance.MachineTypeRecommender
    
    # View specific recommendation
    gcloud recommender recommendations describe RECOMMENDATION_ID \
        --project=PROJECT_ID \
        --location=us-central1 \
        --recommender=google.compute.instance.MachineTypeRecommender

**Use Committed Use Discounts:**

.. code-block:: bash

    # Create 1-year commitment for VMs
    gcloud compute commitments create my-commitment \
        --region=us-central1 \
        --plan=12-month \
        --resources=vcpu=20,memory=40GB

**Use Preemptible/Spot VMs:**

.. code-block:: bash

    # Create preemptible VM (up to 80% cheaper)
    gcloud compute instances create preemptible-vm \
        --zone=us-central1-a \
        --machine-type=n1-standard-4 \
        --preemptible
    
    # Create Spot VM (even more flexible)
    gcloud compute instances create spot-vm \
        --zone=us-central1-a \
        --machine-type=n1-standard-4 \
        --provisioning-model=SPOT

**Auto-stopping Idle VMs:**

.. code-block:: bash

    # Create schedule to stop VMs
    cat > stop-schedule.yaml << EOF
    name: stop-dev-vms
    schedule:
      cron: "0 18 * * 1-5"  # 6 PM weekdays
    action:
      instances:
      - projects/PROJECT_ID/zones/us-central1-a/instances/dev-vm-1
      - projects/PROJECT_ID/zones/us-central1-a/instances/dev-vm-2
      command: stop
    EOF

**2. Storage Optimization:**

**Cloud Storage Lifecycle Policies:**

.. code-block:: json

    // lifecycle-policy.json
    {
      "lifecycle": {
        "rule": [
          {
            "action": {
              "type": "SetStorageClass",
              "storageClass": "NEARLINE"
            },
            "condition": {
              "age": 30,
              "matchesPrefix": ["logs/", "backups/"]
            }
          },
          {
            "action": {
              "type": "SetStorageClass",
              "storageClass": "COLDLINE"
            },
            "condition": {
              "age": 90
            }
          },
          {
            "action": {
              "type": "SetStorageClass",
              "storageClass": "ARCHIVE"
            },
            "condition": {
              "age": 365
            }
          },
          {
            "action": {
              "type": "Delete"
            },
            "condition": {
              "age": 730,
              "isLive": false
            }
          }
        ]
      }
    }

.. code-block:: bash

    # Apply lifecycle policy
    gsutil lifecycle set lifecycle-policy.json gs://my-bucket

**Persistent Disk Optimization:**

.. code-block:: bash

    # Take snapshots and delete disk
    gcloud compute disks snapshot my-disk --zone=us-central1-a
    gcloud compute disks delete my-disk --zone=us-central1-a
    
    # Create disk from snapshot when needed
    gcloud compute disks create restored-disk \
        --source-snapshot=my-snapshot \
        --zone=us-central1-a
    
    # Use balanced persistent disk (cheaper than SSD)
    gcloud compute disks create balanced-disk \
        --type=pd-balanced \
        --size=100GB \
        --zone=us-central1-a

**3. GKE Optimization:**

**Use Autopilot Mode:**

.. code-block:: bash

    # Autopilot automatically optimizes resource allocation
    gcloud container clusters create-auto my-cluster \
        --region=us-central1

**Enable Cluster Autoscaler:**

.. code-block:: bash

    # Enable autoscaling to match demand
    gcloud container clusters update my-cluster \
        --enable-autoscaling \
        --min-nodes=1 \
        --max-nodes=10 \
        --zone=us-central1-a

**Use Preemptible Nodes:**

.. code-block:: bash

    # Create node pool with preemptible nodes
    gcloud container node-pools create preemptible-pool \
        --cluster=my-cluster \
        --zone=us-central1-a \
        --preemptible \
        --num-nodes=3 \
        --enable-autoscaling \
        --min-nodes=1 \
        --max-nodes=10

**Set Resource Limits:**

.. code-block:: yaml

    # Ensure pods request only needed resources
    apiVersion: v1
    kind: Pod
    metadata:
      name: optimized-pod
    spec:
      containers:
      - name: app
        image: myapp:1.0
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"

**4. Cloud Run Optimization:**

.. code-block:: bash

    # Use minimum instances only when needed
    gcloud run services update myapp \
        --min-instances=0 \
        --max-instances=10 \
        --cpu=1 \
        --memory=512Mi

**5. Networking Optimization:**

**Minimize Egress Traffic:**

- Use Cloud CDN for static content
- Keep data transfers within GCP
- Use regional resources over global
- Compress data before transfer

**Delete Unused Load Balancers:**

.. code-block:: bash

    # List forwarding rules
    gcloud compute forwarding-rules list
    
    # Delete unused load balancer
    gcloud compute forwarding-rules delete my-lb --global

===========================
Cost Analysis and Reporting
===========================

**Export Billing Data to BigQuery:**

1. Navigate to Billing → Billing export
2. Enable "Detailed usage cost" export
3. Select BigQuery dataset
4. Data updates daily

**Query Cost Data:**

.. code-block:: sql

    -- Top 10 most expensive services
    SELECT
      service.description,
      SUM(cost) as total_cost
    FROM
      `project.dataset.gcp_billing_export_v1_XXXXXX`
    WHERE
      _PARTITIONTIME >= TIMESTAMP('2024-01-01')
    GROUP BY
      service.description
    ORDER BY
      total_cost DESC
    LIMIT 10;
    
    -- Daily cost trend
    SELECT
      DATE(usage_start_time) as date,
      SUM(cost) as daily_cost
    FROM
      `project.dataset.gcp_billing_export_v1_XXXXXX`
    WHERE
      _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
    GROUP BY
      date
    ORDER BY
      date DESC;
    
    -- Cost by project
    SELECT
      project.name,
      SUM(cost) as total_cost
    FROM
      `project.dataset.gcp_billing_export_v1_XXXXXX`
    WHERE
      _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
    GROUP BY
      project.name
    ORDER BY
      total_cost DESC;
    
    -- Cost by labels
    SELECT
      labels.value as environment,
      SUM(cost) as total_cost
    FROM
      `project.dataset.gcp_billing_export_v1_XXXXXX`,
      UNNEST(labels) as labels
    WHERE
      labels.key = 'environment'
      AND _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
    GROUP BY
      environment
    ORDER BY
      total_cost DESC;

**Create Cost Dashboard:**

.. code-block:: sql

    -- Create view for dashboard
    CREATE OR REPLACE VIEW `project.dataset.cost_summary` AS
    SELECT
      DATE(usage_start_time) as date,
      service.description as service,
      project.name as project,
      SUM(cost) as cost
    FROM
      `project.dataset.gcp_billing_export_v1_XXXXXX`
    WHERE
      _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
    GROUP BY
      date, service, project;

**Use Data Studio for Visualization:**

1. Navigate to Data Studio (https://datastudio.google.com)
2. Create new report
3. Connect to BigQuery billing export
4. Create charts:
   - Line chart for cost trends
   - Pie chart for service breakdown
   - Table for detailed costs
   - Scorecard for total spend

==========================
Resource Labeling Strategy
==========================

**Why Use Labels:**

- Track costs by team, project, or environment
- Automate resource management
- Improve cost allocation
- Enable chargeback/showback

**Labeling Best Practices:**

.. code-block:: bash

    # Standard label structure
    # environment: dev, staging, prod
    # team: engineering, data, platform
    # cost-center: cc-1001, cc-1002
    # application: web-app, api-service
    # owner: alice, bob
    
    # Label a VM instance
    gcloud compute instances update my-instance \
        --zone=us-central1-a \
        --update-labels=environment=prod,team=engineering,cost-center=cc-1001
    
    # Label a GCS bucket
    gsutil label ch -l environment:prod gs://my-bucket
    gsutil label ch -l team:data gs://my-bucket
    
    # Label a GKE cluster
    gcloud container clusters update my-cluster \
        --zone=us-central1-a \
        --update-labels=environment=prod,team=platform

**Query by Labels:**

.. code-block:: bash

    # List resources with specific label
    gcloud compute instances list --filter="labels.environment=prod"
    
    # List all labels on a resource
    gcloud compute instances describe my-instance \
        --zone=us-central1-a \
        --format="value(labels)"

============================
Cost Optimization Automation
============================

**Automated Shutdown Script:**

.. code-block:: python

    # stop-idle-vms.py
    from google.cloud import compute_v1
    from datetime import datetime, timedelta
    
    def stop_idle_vms(project_id, zone):
        """Stop VMs that have been idle for > 1 hour."""
        compute_client = compute_v1.InstancesClient()
        
        instances = compute_client.list(project=project_id, zone=zone)
        
        for instance in instances:
            # Check if instance has 'auto-stop' label
            if 'auto-stop' in instance.labels:
                # Check CPU usage (simplified)
                # In production, query Cloud Monitoring API
                
                print(f"Stopping idle instance: {instance.name}")
                operation = compute_client.stop(
                    project=project_id,
                    zone=zone,
                    instance=instance.name
                )
                operation.result()  # Wait for completion
    
    if __name__ == '__main__':
        stop_idle_vms('my-project', 'us-central1-a')

**Automated Snapshot Cleanup:**

.. code-block:: python

    # cleanup-old-snapshots.py
    from google.cloud import compute_v1
    from datetime import datetime, timedelta
    
    def delete_old_snapshots(project_id, days_old=30):
        """Delete snapshots older than specified days."""
        snapshots_client = compute_v1.SnapshotsClient()
        
        cutoff_date = datetime.now() - timedelta(days=days_old)
        
        snapshots = snapshots_client.list(project=project_id)
        
        for snapshot in snapshots:
            creation_time = datetime.fromisoformat(
                snapshot.creation_timestamp.replace('Z', '+00:00')
            )
            
            if creation_time < cutoff_date:
                print(f"Deleting old snapshot: {snapshot.name}")
                operation = snapshots_client.delete(
                    project=project_id,
                    snapshot=snapshot.name
                )
                operation.result()

**Schedule with Cloud Scheduler:**

.. code-block:: bash

    # Deploy Cloud Function
    gcloud functions deploy stop-idle-vms \
        --runtime python39 \
        --trigger-http \
        --entry-point stop_idle_vms
    
    # Create schedule (daily at 2 AM)
    gcloud scheduler jobs create http stop-vms-daily \
        --schedule="0 2 * * *" \
        --uri="https://REGION-PROJECT_ID.cloudfunctions.net/stop-idle-vms" \
        --http-method=GET

===========================
Cost Optimization Checklist
===========================

**Daily:**

Monitor budget alerts
Review cost anomalies
Check for unused resources

**Weekly:**

Review cost reports
Analyze top cost drivers
Validate resource utilization
Delete unused disks and snapshots
Review GKE cluster efficiency

**Monthly:**

Review and adjust budgets
Analyze cost trends
Review committed use discounts
Update resource labels
Conduct cost optimization review
Review and implement recommendations

**Quarterly:**

Review architecture for cost optimization
Evaluate committed use discount opportunities
Review pricing changes
Conduct FinOps training
Update cost allocation methods

==========================
Recommendations Engine
==========================

**View All Recommendations:**

.. code-block:: bash

    # List all cost recommendations
    gcloud recommender recommendations list \
        --project=PROJECT_ID \
        --location=us-central1 \
        --recommender=google.compute.instance.MachineTypeRecommender
    
    # List idle VM recommendations
    gcloud recommender recommendations list \
        --project=PROJECT_ID \
        --location=us-central1 \
        --recommender=google.compute.instance.IdleResourceRecommender
    
    # List idle disk recommendations
    gcloud recommender recommendations list \
        --project=PROJECT_ID \
        --location=us-central1 \
        --recommender=google.compute.disk.IdleResourceRecommender

**Apply Recommendations:**

.. code-block:: bash

    # Mark recommendation as applied
    gcloud recommender recommendations mark-claimed \
        RECOMMENDATION_ID \
        --project=PROJECT_ID \
        --location=us-central1 \
        --recommender=google.compute.instance.MachineTypeRecommender

==============================
Cost Allocation and Chargeback
==============================

**Setup Cost Allocation:**

1. **Label Resources Consistently:**

.. code-block:: bash

    # Define labeling policy
    # cost-center: Department code
    # project: Project identifier
    # environment: dev/staging/prod
    
    gcloud compute instances update vm-1 \
        --update-labels=cost-center=eng-001,project=web-app,environment=prod

2. **Create Billing Reports by Label:**

.. code-block:: sql

    -- Cost by cost center
    SELECT
      labels.value as cost_center,
      SUM(cost) as total_cost
    FROM
      `project.dataset.gcp_billing_export_v1_XXXXXX`,
      UNNEST(labels) as labels
    WHERE
      labels.key = 'cost-center'
      AND EXTRACT(MONTH FROM usage_start_time) = EXTRACT(MONTH FROM CURRENT_DATE())
    GROUP BY
      cost_center
    ORDER BY
      total_cost DESC;

3. **Generate Chargeback Reports:**

.. code-block:: python

    # generate-chargeback.py
    from google.cloud import bigquery
    import pandas as pd
    
    def generate_chargeback_report(project_id, dataset_id, table_id):
        """Generate monthly chargeback report."""
        client = bigquery.Client(project=project_id)
        
        query = f"""
        SELECT
          labels.value as department,
          service.description as service,
          SUM(cost) as cost
        FROM
          `{project_id}.{dataset_id}.{table_id}`,
          UNNEST(labels) as labels
        WHERE
          labels.key = 'cost-center'
          AND EXTRACT(MONTH FROM usage_start_time) = EXTRACT(MONTH FROM CURRENT_DATE())
        GROUP BY
          department, service
        ORDER BY
          department, cost DESC
        """
        
        df = client.query(query).to_dataframe()
        
        # Export to CSV
        filename = f"chargeback_{datetime.now().strftime('%Y%m')}.csv"
        df.to_csv(filename, index=False)
        print(f"Report generated: {filename}")

==============
Best Practices
==============

**1. Organization:**

- Establish clear project structure
- Use folders and labels consistently
- Implement proper IAM policies
- Document cost allocation methods

**2. Monitoring:**

- Set up budget alerts
- Review costs regularly
- Monitor cost anomalies
- Track cost trends

**3. Optimization:**

- Right-size resources regularly
- Use committed use discounts
- Implement auto-scaling
- Delete unused resources
- Use appropriate storage classes

**4. Governance:**

- Define approval processes for new resources
- Implement resource quotas
- Require cost estimates for new projects
- Conduct regular cost reviews

**5. Culture:**

- Educate teams on cloud costs
- Make cost data transparent
- Reward cost-conscious behavior
- Include cost in architectural decisions

====================
Common Cost Pitfalls
====================

**1. Idle Resources:**

- Stopped VMs still incur disk costs
- Unused load balancers
- Orphaned persistent disks
- Old snapshots

**2. Over-Provisioning:**

- VMs larger than needed
- Excessive storage allocation
- Too many always-on instances

**3. Network Costs:**

- Unnecessary cross-region traffic
- High egress costs
- Multiple NAT gateways

**4. Missing Discounts:**

- Not using committed use discounts
- Not using sustained use discounts
- Paying for Standard when Preemptible works

===============================
Cost Optimization Tools Summary
===============================

+----------------------------+----------------------------------+
| Tool                       | Purpose                          |
+============================+==================================+
| Cloud Billing Reports      | View and analyze costs           |
+----------------------------+----------------------------------+
| Budgets & Alerts           | Control spending                 |
+----------------------------+----------------------------------+
| Recommender                | Get optimization suggestions     |
+----------------------------+----------------------------------+
| BigQuery Export            | Detailed cost analysis           |
+----------------------------+----------------------------------+
| Pricing Calculator         | Estimate costs                   |
+----------------------------+----------------------------------+
| Resource Labels            | Track and allocate costs         |
+----------------------------+----------------------------------+
| Committed Use Discounts    | Save on long-term workloads      |
+----------------------------+----------------------------------+
| Cloud Monitoring           | Track resource utilization       |
+----------------------------+----------------------------------+

====================
Additional Resources
====================

- GCP Pricing: https://cloud.google.com/pricing
- Pricing Calculator: https://cloud.google.com/products/calculator
- Cost Management Guide: https://cloud.google.com/cost-management
- FinOps Foundation: https://www.finops.org/
- Billing Documentation: https://cloud.google.com/billing/docs
- Cost Optimization Best Practices: https://cloud.google.com/blog/topics/cost-management

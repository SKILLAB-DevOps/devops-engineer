#########################################
11.1 Identity and Access Management (IAM)
#########################################

.. note::

    Google Cloud IAM (Identity and Access Management) provides unified access control across all GCP services. It allows you to manage who (identity) has what access (role) to which resources. IAM follows the principle of least privilege and uses a role-based access control (RBAC) model.

=================
IAM Core Concepts
=================

**Members (Who)**

Members are the identities that can access your Google Cloud resources. There are five types of members:

1. **Google Account**: Represents a developer, administrator, or any other person who interacts with GCP
   - Example: alice@example.com

2. **Service Account**: Special account for applications and VMs
   - Example: my-service@project-id.iam.gserviceaccount.com

3. **Google Group**: Named collection of Google Accounts and service accounts
   - Example: admins@example.com

4. **Google Workspace Domain**: Represents all Google Accounts in an organization
   - Example: example.com

5. **Cloud Identity Domain**: Like Google Workspace but without access to Workspace applications
   - Example: example.com

**Roles (What)**

Roles are collections of permissions. You grant roles to members to allow them to perform actions on resources.

Three types of roles:

1. **Basic Roles** (Legacy - use sparingly):

   - Owner: Full control including managing access
   - Editor: Modify and delete access
   - Viewer: Read-only access

2. **Predefined Roles**: Fine-grained access control managed by Google
   - Example: `roles/compute.instanceAdmin.v1` - Full control of Compute Engine instances

3. **Custom Roles**: User-defined roles with specific permissions
   - Created for specific organizational needs

**Resources (Where)**

Resources are GCP entities that you can grant access to:

- Projects
- Compute Engine instances
- Cloud Storage buckets
- BigQuery datasets
- And more...

**Permissions**

Permissions determine what operations are allowed on a resource. They follow this format:

.. code-block:: text

    <service>.<resource>.<verb>
    
    Examples:
    - compute.instances.create
    - storage.buckets.get
    - bigquery.datasets.update

====================
IAM Policy Structure
====================

An IAM policy is a collection of role bindings that bind one or more members to roles.

**Policy JSON Format:**

.. code-block:: json

    {
        "bindings": [
            {
                "role": "roles/storage.objectViewer",
                "members": [
                    "user:alice@example.com",
                    "serviceAccount:my-service@project.iam.gserviceaccount.com",
                    "group:admins@example.com"
                ]
            },
            {
                "role": "roles/storage.objectAdmin",
                "members": [
                    "user:bob@example.com"
                ],
                "condition": {
                    "title": "Expires in 2024",
                    "expression": "request.time < timestamp('2024-12-31T23:59:59Z')"
                }
            }
        ],
        "etag": "BwXhFxF7dqE=",
        "version": 3
    }

=====================
Setting Up IAM Access
=====================

**Prerequisites:**

.. code-block:: bash

    # Install Google Cloud CLI if not already installed
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
    
    # Authenticate
    gcloud auth login
    
    # Set your project
    gcloud config set project PROJECT_ID

**View Current IAM Policy:**

.. code-block:: bash

    # View project IAM policy
    gcloud projects get-iam-policy PROJECT_ID
    
    # View IAM policy in readable format
    gcloud projects get-iam-policy PROJECT_ID --format=json | jq
    
    # View IAM policy for a specific resource (e.g., storage bucket)
    gsutil iam get gs://BUCKET_NAME

**Grant IAM Roles:**

.. code-block:: bash

    # Grant a role to a user at project level
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="user:alice@example.com" \
        --role="roles/compute.viewer"
    
    # Grant a role to a service account
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="serviceAccount:my-service@PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/storage.objectAdmin"
    
    # Grant a role to a Google Group
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="group:developers@example.com" \
        --role="roles/editor"
    
    # Grant a role to all authenticated users
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="allAuthenticatedUsers" \
        --role="roles/viewer"

**Remove IAM Roles:**

.. code-block:: bash

    # Remove a role from a user
    gcloud projects remove-iam-policy-binding PROJECT_ID \
        --member="user:alice@example.com" \
        --role="roles/compute.viewer"

**Grant Roles with Conditions:**

.. code-block:: bash

    # Grant time-bound access
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="user:temp-contractor@example.com" \
        --role="roles/viewer" \
        --condition='expression=request.time < timestamp("2024-12-31T23:59:59Z"),title=Temporary Access,description=Access expires at end of 2024'

================
Service Accounts
================

Service accounts are special Google accounts that represent applications or VMs, not individual users.

**Create a Service Account:**

.. code-block:: bash

    # Create service account
    gcloud iam service-accounts create my-service-account \
        --display-name="My Service Account" \
        --description="Service account for application authentication"
    
    # List service accounts
    gcloud iam service-accounts list
    
    # Get service account email
    SA_EMAIL=$(gcloud iam service-accounts list \
        --filter="displayName:My Service Account" \
        --format="value(email)")
    
    echo $SA_EMAIL

**Grant Roles to Service Account:**

.. code-block:: bash

    # Grant roles at project level
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="serviceAccount:$SA_EMAIL" \
        --role="roles/storage.objectViewer"
    
    # Grant multiple roles
    for role in "roles/compute.viewer" "roles/storage.objectAdmin" "roles/logging.logWriter"; do
        gcloud projects add-iam-policy-binding PROJECT_ID \
            --member="serviceAccount:$SA_EMAIL" \
            --role="$role"
    done

**Create and Manage Service Account Keys:**

.. code-block:: bash

    # Create a JSON key file
    gcloud iam service-accounts keys create ~/key.json \
        --iam-account=$SA_EMAIL
    
    # List keys for service account
    gcloud iam service-accounts keys list \
        --iam-account=$SA_EMAIL
    
    # Delete a key
    gcloud iam service-accounts keys delete KEY_ID \
        --iam-account=$SA_EMAIL

.. warning::

    Service account keys are powerful credentials. Store them securely and rotate them regularly. Consider using Workload Identity or service account impersonation instead of downloading keys when possible.

**Use Service Account Authentication:**

.. code-block:: bash

    # Authenticate using service account key
    gcloud auth activate-service-account --key-file=~/key.json
    
    # Set as environment variable for application authentication
    export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"

**Service Account Impersonation:**

.. code-block:: bash

    # Grant user permission to impersonate service account
    gcloud iam service-accounts add-iam-policy-binding $SA_EMAIL \
        --member="user:alice@example.com" \
        --role="roles/iam.serviceAccountUser"
    
    # Use impersonation in gcloud commands
    gcloud compute instances list \
        --impersonate-service-account=$SA_EMAIL

============
Custom Roles
============

Create custom roles when predefined roles don't meet your needs.

**Create a Custom Role:**

.. code-block:: bash

    # Create role definition file
    cat > custom-role.yaml <<EOF
    title: "Custom Instance Operator"
    description: "Can start and stop instances but not delete"
    stage: "GA"
    includedPermissions:
    - compute.instances.start
    - compute.instances.stop
    - compute.instances.get
    - compute.instances.list
    - compute.zones.get
    - compute.zones.list
    EOF
    
    # Create custom role at project level
    gcloud iam roles create customInstanceOperator \
        --project=PROJECT_ID \
        --file=custom-role.yaml
    
    # Create custom role at organization level
    gcloud iam roles create customInstanceOperator \
        --organization=ORGANIZATION_ID \
        --file=custom-role.yaml

**Update a Custom Role:**

.. code-block:: bash

    # Add permissions to existing role
    gcloud iam roles update customInstanceOperator \
        --project=PROJECT_ID \
        --add-permissions=compute.instances.reset
    
    # Remove permissions
    gcloud iam roles update customInstanceOperator \
        --project=PROJECT_ID \
        --remove-permissions=compute.instances.reset

**List and Describe Roles:**

.. code-block:: bash

    # List all roles
    gcloud iam roles list
    
    # List project custom roles
    gcloud iam roles list --project=PROJECT_ID
    
    # Describe a specific role
    gcloud iam roles describe roles/compute.instanceAdmin.v1
    
    # Describe custom role
    gcloud iam roles describe customInstanceOperator --project=PROJECT_ID

=====================
IAM Policy Management
=====================

**Export and Import Policies:**

.. code-block:: bash

    # Export current policy to file
    gcloud projects get-iam-policy PROJECT_ID > policy.json
    
    # Edit policy.json as needed, then import
    gcloud projects set-iam-policy PROJECT_ID policy.json

**Using Policy Analyzer:**

.. code-block:: bash

    # Analyze who has access to a resource
    gcloud asset analyze-iam-policy \
        --organization=ORGANIZATION_ID \
        --full-resource-name="//compute.googleapis.com/projects/PROJECT_ID/zones/us-central1-a/instances/INSTANCE_NAME"
    
    # Find all resources a user has access to
    gcloud asset analyze-iam-policy \
        --organization=ORGANIZATION_ID \
        --identity="user:alice@example.com"

==============
IAM Conditions
==============

IAM Conditions allow you to define and enforce conditional, attribute-based access control for GCP resources.

**Common Condition Examples:**

.. code-block:: bash

    # Time-based access
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="user:contractor@example.com" \
        --role="roles/viewer" \
        --condition='expression=request.time < timestamp("2024-06-30T00:00:00Z"),title=Access until June 2024'
    
    # Resource-based access (only specific instances)
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="user:developer@example.com" \
        --role="roles/compute.instanceAdmin.v1" \
        --condition='expression=resource.name.startsWith("projects/PROJECT_ID/zones/us-central1-a/instances/dev-"),title=Dev instances only'
    
    # IP-based access
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="user:admin@example.com" \
        --role="roles/owner" \
        --condition='expression=origin.ip in ["203.0.113.0/24"],title=Office IP only'

==============
Best Practices
==============

**1. Use Principle of Least Privilege:**

.. code-block:: bash

    # Bad: Granting Editor role when only read access is needed
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="user:alice@example.com" \
        --role="roles/editor"
    
    # Good: Grant specific role for the task
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="user:alice@example.com" \
        --role="roles/storage.objectViewer"

**2. Use Groups Instead of Individual Users:**

.. code-block:: bash

    # Create a group in Google Workspace or Cloud Identity
    # Then grant access to the group
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="group:developers@example.com" \
        --role="roles/editor"

**3. Separate Environments:**

.. code-block:: bash

    # Use separate projects for dev, staging, production
    # Grant different access levels to each
    
    # Development project - broader access
    gcloud projects add-iam-policy-binding dev-project \
        --member="group:developers@example.com" \
        --role="roles/editor"
    
    # Production project - restricted access
    gcloud projects add-iam-policy-binding prod-project \
        --member="group:developers@example.com" \
        --role="roles/viewer"

**4. Regular Access Reviews:**

.. code-block:: bash

    # Export IAM policy for review
    gcloud projects get-iam-policy PROJECT_ID \
        --format=json > iam-audit-$(date +%Y%m%d).json
    
    # List all service accounts and their keys
    gcloud iam service-accounts list
    gcloud iam service-accounts keys list --iam-account=SA_EMAIL

**5. Enable Audit Logging:**

.. code-block:: bash

    # View admin activity logs
    gcloud logging read "resource.type=project AND protoPayload.methodName=SetIamPolicy" \
        --limit 50 \
        --format json
    
    # Monitor for privilege escalation
    gcloud logging read "protoPayload.methodName=google.iam.admin.v1.CreateRole" \
        --limit 10

**6. Use Workload Identity for GKE:**

Instead of downloading service account keys for applications running in GKE, use Workload Identity:

.. code-block:: bash

    # Enable Workload Identity on GKE cluster
    gcloud container clusters update CLUSTER_NAME \
        --workload-pool=PROJECT_ID.svc.id.goog
    
    # Bind Kubernetes service account to GCP service account
    gcloud iam service-accounts add-iam-policy-binding $SA_EMAIL \
        --role roles/iam.workloadIdentityUser \
        --member "serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]"

=======================
Practical IAM Scenarios
=======================

**Scenario 1: Onboarding a New Developer**

.. code-block:: bash

    # Add to developers group
    # (Done via Google Workspace or Cloud Identity admin console)
    
    # Grant group access to development project
    gcloud projects add-iam-policy-binding dev-project-id \
        --member="group:developers@example.com" \
        --role="roles/editor"
    
    # Grant read-only access to production
    gcloud projects add-iam-policy-binding prod-project-id \
        --member="group:developers@example.com" \
        --role="roles/viewer"

**Scenario 2: Application Service Account**

.. code-block:: bash

    # Create service account for application
    gcloud iam service-accounts create webapp-backend \
        --display-name="Web Application Backend"
    
    # Grant necessary permissions
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="serviceAccount:webapp-backend@PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/datastore.user"
    
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="serviceAccount:webapp-backend@PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/storage.objectViewer"
    
    # For Cloud Run, assign service account
    gcloud run deploy webapp \
        --image gcr.io/PROJECT_ID/webapp \
        --service-account webapp-backend@PROJECT_ID.iam.gserviceaccount.com

**Scenario 3: External Auditor Access**

.. code-block:: bash

    # Grant time-limited read-only access
    gcloud projects add-iam-policy-binding PROJECT_ID \
        --member="user:auditor@external-company.com" \
        --role="roles/viewer" \
        --condition='expression=request.time < timestamp("2024-01-31T23:59:59Z"),title=Audit Access Q1 2024'

**Scenario 4: Cross-Project Access**

.. code-block:: bash

    # Service account in Project A needs access to storage in Project B
    
    # In Project B, grant access to Project A's service account
    gcloud projects add-iam-policy-binding project-b-id \
        --member="serviceAccount:service-a@project-a-id.iam.gserviceaccount.com" \
        --role="roles/storage.objectViewer"

==========================
Troubleshooting IAM Issues
==========================

**Check Permissions:**

.. code-block:: bash

    # Test if you have a specific permission
    gcloud projects get-iam-policy PROJECT_ID \
        --flatten="bindings[].members" \
        --filter="bindings.members:user:YOUR_EMAIL"
    
    # Check what you can do on a resource
    gcloud compute instances test-iam-permissions INSTANCE_NAME \
        --zone=ZONE \
        --permissions=compute.instances.start,compute.instances.stop

**Common IAM Errors:**

1. **Error 403: Permission Denied**

.. code-block:: bash

    # Check if user has necessary role
    gcloud projects get-iam-policy PROJECT_ID \
        --flatten="bindings[].members" \
        --filter="bindings.members:user:alice@example.com"

2. **Error: Service Account Key Rotation**

.. code-block:: bash

    # List all keys
    gcloud iam service-accounts keys list \
        --iam-account=SA_EMAIL
    
    # Create new key
    gcloud iam service-accounts keys create new-key.json \
        --iam-account=SA_EMAIL
    
    # Delete old key after updating applications
    gcloud iam service-accounts keys delete OLD_KEY_ID \
        --iam-account=SA_EMAIL

3. **IAM Policy Sync Issues**

.. code-block:: bash

    # Force policy refresh
    gcloud projects get-iam-policy PROJECT_ID > /dev/null
    
    # Wait a few seconds for propagation
    sleep 5
    
    # Try operation again

====================
IAM Security Scanner
====================

.. code-block:: bash

    # Install Security Command Center (requires organization)
    gcloud scc findings list ORGANIZATION_ID \
        --filter="category='PUBLIC_IP_ADDRESS'"
    
    # Check for overly permissive IAM bindings
    gcloud asset search-all-iam-policies \
        --scope=organizations/ORGANIZATION_ID \
        --query="policy:roles/owner OR policy:roles/editor"

====================
Additional Resources
====================

- Official IAM Documentation: https://cloud.google.com/iam/docs
- IAM Best Practices: https://cloud.google.com/iam/docs/best-practices
- Predefined Roles Reference: https://cloud.google.com/iam/docs/understanding-roles
- IAM Conditions: https://cloud.google.com/iam/docs/conditions-overview
- Service Accounts Best Practices: https://cloud.google.com/iam/docs/best-practices-service-accounts

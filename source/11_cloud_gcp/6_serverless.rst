###########################
11.6 Serverless Computing
###########################

.. note::

    Google Cloud offers multiple serverless platforms that allow you to build and deploy applications without managing servers. The main serverless offerings are **Cloud Run** (for containerized applications) and **Cloud Functions** (for event-driven functions). Both services automatically scale based on traffic and you only pay for the resources you use.

===================
Serverless Overview
===================

**Why Serverless?**

- **No Server Management**: Focus on code, not infrastructure
- **Automatic Scaling**: Scale to zero and to thousands of instances
- **Pay-per-Use**: Only pay when code is running
- **Built-in High Availability**: Automatic redundancy and failover
- **Fast Development**: Quick iterations and deployments

**GCP Serverless Services:**

+-------------------+---------------------------+---------------------------+---------------------------+
| Service           | Best For                  | Runtime                   | Trigger Types             |
+===================+===========================+===========================+===========================+
| Cloud Functions   | Event-driven functions    | Node.js, Python, Go, Java | HTTP, Cloud events        |
+-------------------+---------------------------+---------------------------+---------------------------+
| Cloud Run         | Containerized apps        | Any language (Docker)     | HTTP requests             |
+-------------------+---------------------------+---------------------------+---------------------------+
| App Engine        | Full web applications     | Multiple runtimes         | HTTP requests             |
+-------------------+---------------------------+---------------------------+---------------------------+

=========
Cloud Run
=========

Cloud Run is a fully managed compute platform that automatically scales your stateless containers.

**Key Features:**

- Run any containerized application
- Automatically scales from 0 to N instances
- Built on Knative (portable)
- Integrates with Cloud Build for CI/CD
- Custom domains and SSL certificates
- WebSocket and gRPC support

**Cloud Run Setup:**

.. code-block:: bash

    # Enable Cloud Run API
    gcloud services enable run.googleapis.com
    
    # Set default region
    gcloud config set run/region us-central1

======================
Cloud Run: Hello World
======================

**Create a Simple FastAPI App:**

.. code-block:: bash

    # Create app directory
    mkdir hello-cloudrun
    cd hello-cloudrun
    
    # Create requirements.txt
    cat > requirements.txt << EOF
    fastapi==0.104.1
    uvicorn[standard]==0.24.0
    EOF
    
    # Create main application
    cat > main.py << 'EOF'
    import os
    from fastapi import FastAPI, Query
    
    app = FastAPI(title="Cloud Run Hello World")
    
    @app.get("/")
    async def hello(name: str = Query(default="World")):
        return {
            "message": f"Hello {name}! Running on Cloud Run",
            "service": "FastAPI on Cloud Run"
        }
    
    @app.get("/health")
    async def health():
        return {"status": "healthy"}
    
    if __name__ == "__main__":
        import uvicorn
        port = int(os.environ.get("PORT", 8080))
        uvicorn.run(app, host="0.0.0.0", port=port)
    EOF
    
    # Create Dockerfile
    cat > Dockerfile << 'EOF'
    FROM python:3.11-slim
    
    WORKDIR /app
    
    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt
    
    COPY main.py .
    
    ENV PORT=8080
    
    CMD exec uvicorn main:app --host 0.0.0.0 --port $PORT
    EOF

**Deploy to Cloud Run:**

.. code-block:: bash

    # Deploy (builds container automatically)
    gcloud run deploy hello-cloudrun \
        --source . \
        --platform managed \
        --region us-central1 \
        --allow-unauthenticated
    
    # Output shows service URL:
    # Service URL: https://hello-cloudrun-xxxxx-uc.a.run.app
    
    # Test the service
    curl https://hello-cloudrun-xxxxx-uc.a.run.app
    curl "https://hello-cloudrun-xxxxx-uc.a.run.app?name=DevOps"

**Deploy Pre-built Container:**

.. code-block:: bash

    # Build container with Cloud Build
    gcloud builds submit --tag gcr.io/PROJECT_ID/hello-cloudrun
    
    # Deploy from Container Registry
    gcloud run deploy hello-cloudrun \
        --image gcr.io/PROJECT_ID/hello-cloudrun \
        --platform managed \
        --region us-central1 \
        --allow-unauthenticated

=======================
Cloud Run Configuration
=======================

**Service Configuration:**

.. code-block:: bash

    # Deploy with custom settings
    gcloud run deploy myapp \
        --image gcr.io/PROJECT_ID/myapp \
        --platform managed \
        --region us-central1 \
        --memory 512Mi \
        --cpu 2 \
        --timeout 300 \
        --max-instances 100 \
        --min-instances 1 \
        --concurrency 80 \
        --port 8080 \
        --allow-unauthenticated

**Configuration Options:**

- **--memory**: Memory allocation (128Mi to 32Gi)
- **--cpu**: CPU allocation (1, 2, 4, or 8)
- **--timeout**: Request timeout (max 3600s)
- **--max-instances**: Maximum concurrent instances
- **--min-instances**: Keep instances warm (costs more)
- **--concurrency**: Requests per container instance
- **--port**: Container port (default 8080)

**Environment Variables:**

.. code-block:: bash

    # Set environment variables
    gcloud run deploy myapp \
        --image gcr.io/PROJECT_ID/myapp \
        --set-env-vars "API_KEY=abc123,ENVIRONMENT=prod"
    
    # Update environment variables
    gcloud run services update myapp \
        --update-env-vars "NEW_VAR=value"
    
    # Remove environment variables
    gcloud run services update myapp \
        --remove-env-vars "OLD_VAR"
    
    # Load from file
    gcloud run services update myapp \
        --env-vars-file=env.yaml

**Secrets:**

.. code-block:: bash

    # Create secret in Secret Manager
    echo -n "my-secret-value" | gcloud secrets create my-secret --data-file=-
    
    # Deploy with secret as environment variable
    gcloud run deploy myapp \
        --image gcr.io/PROJECT_ID/myapp \
        --update-secrets="DB_PASSWORD=my-secret:latest"
    
    # Mount secret as file
    gcloud run deploy myapp \
        --image gcr.io/PROJECT_ID/myapp \
        --update-secrets="/secrets/db-password=my-secret:latest"

=========================
Cloud Run: Authentication
=========================

**Require Authentication:**

.. code-block:: bash

    # Deploy with authentication required (default)
    gcloud run deploy myapp \
        --image gcr.io/PROJECT_ID/myapp \
        --no-allow-unauthenticated
    
    # Grant user access
    gcloud run services add-iam-policy-binding myapp \
        --member="user:alice@example.com" \
        --role="roles/run.invoker"
    
    # Grant service account access
    gcloud run services add-iam-policy-binding myapp \
        --member="serviceAccount:my-sa@project.iam.gserviceaccount.com" \
        --role="roles/run.invoker"

**Call Authenticated Service:**

.. code-block:: bash

    # Get ID token
    TOKEN=$(gcloud auth print-identity-token)
    
    # Call service with token
    curl -H "Authorization: Bearer $TOKEN" \
        https://myapp-xxxxx-uc.a.run.app

=========================
Cloud Run: Custom Domains
=========================

**Map Custom Domain:**

.. code-block:: bash

    # Add domain mapping
    gcloud run domain-mappings create \
        --service myapp \
        --domain api.example.com \
        --region us-central1
    
    # List domain mappings
    gcloud run domain-mappings list
    
    # Get DNS records to configure
    gcloud run domain-mappings describe \
        --domain api.example.com \
        --region us-central1

=====================
Cloud Run: Management
=====================

**List Services:**

.. code-block:: bash

    # List all services
    gcloud run services list
    
    # Describe service
    gcloud run services describe myapp --region us-central1

**Update Service:**

.. code-block:: bash

    # Update image
    gcloud run services update myapp \
        --image gcr.io/PROJECT_ID/myapp:v2
    
    # Update traffic split (canary deployment)
    gcloud run services update-traffic myapp \
        --to-revisions=myapp-v2=20,myapp-v1=80

**View Logs:**

.. code-block:: bash

    # View logs
    gcloud logs read --service myapp --limit 50
    
    # Stream logs
    gcloud logs tail --service myapp

**Delete Service:**

.. code-block:: bash

    # Delete service
    gcloud run services delete myapp --region us-central1

===============
Cloud Functions
===============

Cloud Functions is a serverless execution environment for building and connecting cloud services with code.

**Key Features:**

- Event-driven execution
- Multiple trigger types (HTTP, Pub/Sub, Storage, Firestore, etc.)
- Automatic scaling
- Built-in monitoring and logging
- Multiple language runtimes

**Supported Runtimes:**

- Node.js (18, 20)
- Python (3.9, 3.10, 3.11, 3.12)
- Go (1.19, 1.20, 1.21)
- Java (11, 17)
- .NET Core (3.1, 6)
- Ruby (2.7, 3.0, 3.2)
- PHP (8.1, 8.2)

**Enable Cloud Functions API:**

.. code-block:: bash

    # Enable API
    gcloud services enable cloudfunctions.googleapis.com
    gcloud services enable cloudbuild.googleapis.com

=============================
Cloud Functions: HTTP Trigger
=============================

**Python HTTP Function:**

.. code-block:: bash

    # Create directory
    mkdir http-function
    cd http-function
    
    # Create main.py
    cat > main.py << 'EOF'
    import functions_framework
    from fastapi import FastAPI, Query
    from fastapi.responses import JSONResponse
    
    app = FastAPI()
    
    @app.get("/")
    async def hello(name: str = Query(default="World")):
        return {
            "message": f"Hello {name}!",
            "function": "HTTP Cloud Function with FastAPI"
        }
    
    @functions_framework.http
    def hello_http(request):
        """HTTP Cloud Function using FastAPI.
        Args:
            request (flask.Request): The request object.
        Returns:
            JSON response from FastAPI application.
        """
        from fastapi.testclient import TestClient
        
        client = TestClient(app)
        
        # Get query parameters
        name = request.args.get('name', 'World')
        
        # Also check JSON body
        if request.is_json:
            data = request.get_json()
            name = data.get('name', name)
        
        # Call FastAPI endpoint
        response = client.get(f"/?name={name}")
        return JSONResponse(content=response.json())
    EOF
    
    # Create requirements.txt
    cat > requirements.txt << EOF
    functions-framework==3.5.0
    fastapi==0.104.1
    EOF

**Deploy HTTP Function:**

.. code-block:: bash

    # Deploy function
    gcloud functions deploy hello-http \
        --gen2 \
        --runtime python311 \
        --trigger-http \
        --entry-point hello_http \
        --region us-central1 \
        --allow-unauthenticated
    
    # Test function
    curl https://REGION-PROJECT_ID.cloudfunctions.net/hello-http
    curl "https://REGION-PROJECT_ID.cloudfunctions.net/hello-http?name=DevOps"
    
    # Test with JSON
    curl -X POST \
        -H "Content-Type: application/json" \
        -d '{"name":"Alice"}' \
        https://REGION-PROJECT_ID.cloudfunctions.net/hello-http

================================
Cloud Functions: Storage Trigger
================================

**Process Uploaded Files:**

.. code-block:: python

    # main.py
    import functions_framework
    from google.cloud import storage
    import os
    
    @functions_framework.cloud_event
    def process_file(cloud_event):
        """Triggered by a change to a Cloud Storage bucket.
        Args:
            cloud_event: Event describing the change in storage.
        """
        data = cloud_event.data
        
        bucket_name = data["bucket"]
        file_name = data["name"]
        
        print(f"Processing file: {file_name} from bucket: {bucket_name}")
        
        # Initialize storage client
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        
        # Process the file
        if file_name.endswith('.txt'):
            content = blob.download_as_text()
            print(f"File content: {content}")
            
            # Example: Create processed file
            processed_name = f"processed/{file_name}"
            processed_blob = bucket.blob(processed_name)
            processed_blob.upload_from_string(content.upper())
            print(f"Created processed file: {processed_name}")

.. code-block:: bash

    # requirements.txt
    cat > requirements.txt << EOF
    functions-framework==3.5.0
    google-cloud-storage==2.10.0
    EOF
    
    # Deploy with Storage trigger
    gcloud functions deploy process-file \
        --gen2 \
        --runtime python311 \
        --trigger-bucket my-bucket \
        --entry-point process_file \
        --region us-central1
    
    # Test by uploading a file
    echo "Hello Cloud Functions" > test.txt
    gsutil cp test.txt gs://my-bucket/
    
    # Check logs
    gcloud functions logs read process-file --gen2 --region us-central1

================================
Cloud Functions: Pub/Sub Trigger
================================

**Process Pub/Sub Messages:**

.. code-block:: python

    # main.py
    import functions_framework
    import base64
    import json
    
    @functions_framework.cloud_event
    def process_message(cloud_event):
        """Triggered from a message on a Pub/Sub topic.
        Args:
            cloud_event: Event with Pub/Sub message.
        """
        # Decode the Pub/Sub message
        pubsub_message = base64.b64decode(cloud_event.data["message"]["data"]).decode()
        
        print(f"Received message: {pubsub_message}")
        
        try:
            # Parse JSON if applicable
            data = json.loads(pubsub_message)
            print(f"Processing data: {data}")
            
            # Your processing logic here
            result = process_data(data)
            print(f"Result: {result}")
            
        except json.JSONDecodeError:
            print(f"Message is not JSON: {pubsub_message}")
    
    def process_data(data):
        """Process the incoming data."""
        # Example processing
        return {"status": "processed", "data": data}

.. code-block:: bash

    # Create Pub/Sub topic
    gcloud pubsub topics create my-topic
    
    # Deploy function with Pub/Sub trigger
    gcloud functions deploy process-message \
        --gen2 \
        --runtime python311 \
        --trigger-topic my-topic \
        --entry-point process_message \
        --region us-central1
    
    # Test by publishing message
    gcloud pubsub topics publish my-topic \
        --message '{"user":"alice","action":"login"}'
    
    # Check logs
    gcloud functions logs read process-message --gen2 --region us-central1

==========================
Cloud Functions: Scheduled
==========================

**Create Scheduled Function:**

.. code-block:: python

    # main.py
    import functions_framework
    from datetime import datetime
    
    @functions_framework.http
    def scheduled_task(request):
        """Scheduled task function."""
        current_time = datetime.now().isoformat()
        
        print(f"Scheduled task running at: {current_time}")
        
        # Your scheduled logic here
        # Examples:
        # - Clean up old data
        # - Generate reports
        # - Send notifications
        # - Backup data
        
        return {"status": "success", "time": current_time}

.. code-block:: bash

    # Deploy function
    gcloud functions deploy scheduled-task \
        --gen2 \
        --runtime python311 \
        --trigger-http \
        --entry-point scheduled_task \
        --region us-central1 \
        --no-allow-unauthenticated
    
    # Create Cloud Scheduler job (runs every day at 2 AM)
    gcloud scheduler jobs create http daily-task \
        --schedule="0 2 * * *" \
        --uri="https://REGION-PROJECT_ID.cloudfunctions.net/scheduled-task" \
        --http-method=GET \
        --oidc-service-account-email=PROJECT_ID@appspot.gserviceaccount.com \
        --location=us-central1
    
    # Test immediately
    gcloud scheduler jobs run daily-task --location=us-central1

==============================
Cloud Functions: Configuration
==============================

**Memory and Timeout:**

.. code-block:: bash

    # Deploy with custom configuration
    gcloud functions deploy my-function \
        --gen2 \
        --runtime python311 \
        --trigger-http \
        --entry-point my_function \
        --memory 512MB \
        --timeout 300s \
        --max-instances 100 \
        --min-instances 1 \
        --region us-central1

**Environment Variables:**

.. code-block:: bash

    # Set environment variables
    gcloud functions deploy my-function \
        --gen2 \
        --runtime python311 \
        --trigger-http \
        --entry-point my_function \
        --set-env-vars API_KEY=abc123,ENVIRONMENT=prod
    
    # Update environment variables
    gcloud functions deploy my-function \
        --gen2 \
        --update-env-vars NEW_VAR=value

**Secrets:**

.. code-block:: bash

    # Use secrets
    gcloud functions deploy my-function \
        --gen2 \
        --runtime python311 \
        --trigger-http \
        --entry-point my_function \
        --set-secrets 'DB_PASSWORD=my-secret:latest'

================================
Advanced Cloud Function Examples
================================

**API Integration Function:**

.. code-block:: python

    # main.py - Weather API Integration
    import functions_framework
    import requests
    import os
    from flask import jsonify
    
    @functions_framework.http
    def get_weather(request):
        """Get weather for a city."""
        request_json = request.get_json(silent=True)
        city = request_json.get('city', 'London') if request_json else 'London'
        
        api_key = os.environ.get('WEATHER_API_KEY')
        url = f"https://api.openweathermap.org/data/2.5/weather"
        params = {'q': city, 'appid': api_key, 'units': 'metric'}
        
        response = requests.get(url, params=params)
        
        if response.status_code == 200:
            data = response.json()
            return jsonify({
                'city': city,
                'temperature': data['main']['temp'],
                'description': data['weather'][0]['description']
            })
        else:
            return jsonify({'error': 'City not found'}), 404

**Database Integration:**

.. code-block:: python

    # main.py - Firestore Integration
    import functions_framework
    from google.cloud import firestore
    from flask import jsonify
    import datetime
    
    db = firestore.Client()
    
    @functions_framework.http
    def save_data(request):
        """Save data to Firestore."""
        request_json = request.get_json(silent=True)
        
        if not request_json or 'data' not in request_json:
            return jsonify({'error': 'No data provided'}), 400
        
        doc_ref = db.collection('items').document()
        doc_ref.set({
            'data': request_json['data'],
            'created_at': datetime.datetime.now()
        })
        
        return jsonify({
            'success': True,
            'id': doc_ref.id
        })

==========================
Cloud Functions Management
==========================

**List Functions:**

.. code-block:: bash

    # List all functions
    gcloud functions list --gen2
    
    # Describe function
    gcloud functions describe my-function \
        --gen2 \
        --region us-central1

**View Logs:**

.. code-block:: bash

    # View logs
    gcloud functions logs read my-function \
        --gen2 \
        --region us-central1 \
        --limit 50
    
    # Stream logs in real-time
    gcloud functions logs read my-function \
        --gen2 \
        --region us-central1 \
        --follow

**Delete Function:**

.. code-block:: bash

    # Delete function
    gcloud functions delete my-function \
        --gen2 \
        --region us-central1

====================
CI/CD for Serverless
====================

**GitHub Actions Workflow (.github/workflows/deploy.yml):**

**For Cloud Run:**

.. code-block:: yaml

    name: Deploy to Cloud Run
    
    on:
      push:
        branches:
          - main
    
    env:
      PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
      REGION: us-central1
      SERVICE_NAME: myapp
    
    jobs:
      deploy:
        runs-on: ubuntu-latest
        
        permissions:
          contents: read
          id-token: write
        
        steps:
          - name: Checkout code
            uses: actions/checkout@v4
          
          - name: Authenticate to Google Cloud
            uses: google-github-actions/auth@v2
            with:
              workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
              service_account: ${{ secrets.WIF_SERVICE_ACCOUNT }}
          
          - name: Set up Cloud SDK
            uses: google-github-actions/setup-gcloud@v2
          
          - name: Build and Deploy to Cloud Run
            run: |
              gcloud run deploy ${{ env.SERVICE_NAME }} \
                --source . \
                --platform managed \
                --region ${{ env.REGION }} \
                --allow-unauthenticated

**For Cloud Functions:**

.. code-block:: yaml

    name: Deploy Cloud Function
    
    on:
      push:
        branches:
          - main
    
    env:
      PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
      REGION: us-central1
      FUNCTION_NAME: my-function
    
    jobs:
      deploy:
        runs-on: ubuntu-latest
        
        permissions:
          contents: read
          id-token: write
        
        steps:
          - name: Checkout code
            uses: actions/checkout@v4
          
          - name: Authenticate to Google Cloud
            uses: google-github-actions/auth@v2
            with:
              workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
              service_account: ${{ secrets.WIF_SERVICE_ACCOUNT }}
          
          - name: Set up Cloud SDK
            uses: google-github-actions/setup-gcloud@v2
          
          - name: Deploy Cloud Function
            run: |
              gcloud functions deploy ${{ env.FUNCTION_NAME }} \
                --gen2 \
                --runtime python311 \
                --trigger-http \
                --entry-point my_function \
                --region ${{ env.REGION }} \
                --allow-unauthenticated

**Setup Workload Identity Federation:**

.. code-block:: bash

    # Create Workload Identity Pool
    gcloud iam workload-identity-pools create "github-pool" \
      --project="${PROJECT_ID}" \
      --location="global" \
      --display-name="GitHub Actions Pool"
    
    # Create Workload Identity Provider
    gcloud iam workload-identity-pools providers create-oidc "github-provider" \
      --project="${PROJECT_ID}" \
      --location="global" \
      --workload-identity-pool="github-pool" \
      --display-name="GitHub Provider" \
      --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
      --issuer-uri="https://token.actions.githubusercontent.com"
    
    # Create Service Account
    gcloud iam service-accounts create github-actions \
      --display-name="GitHub Actions"
    
    # Grant permissions to Service Account
    gcloud projects add-iam-policy-binding $PROJECT_ID \
      --member="serviceAccount:github-actions@${PROJECT_ID}.iam.gserviceaccount.com" \
      --role="roles/run.admin"
    
    gcloud projects add-iam-policy-binding $PROJECT_ID \
      --member="serviceAccount:github-actions@${PROJECT_ID}.iam.gserviceaccount.com" \
      --role="roles/cloudfunctions.admin"
    
    gcloud projects add-iam-policy-binding $PROJECT_ID \
      --member="serviceAccount:github-actions@${PROJECT_ID}.iam.gserviceaccount.com" \
      --role="roles/iam.serviceAccountUser"
    
    # Allow GitHub to impersonate Service Account
    gcloud iam service-accounts add-iam-policy-binding \
      "github-actions@${PROJECT_ID}.iam.gserviceaccount.com" \
      --project="${PROJECT_ID}" \
      --role="roles/iam.workloadIdentityUser" \
      --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR_GITHUB_USER/YOUR_REPO"

**Add Secrets to GitHub:**

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Add these secrets:
   
   - ``GCP_PROJECT_ID``: Your GCP project ID
   - ``WIF_PROVIDER``: ``projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider``
   - ``WIF_SERVICE_ACCOUNT``: ``github-actions@PROJECT_ID.iam.gserviceaccount.com``

==============
Best Practices
==============

**1. Cloud Run:**

- Keep containers stateless
- Store state in external services (databases, Cloud Storage)
- Use health checks
- Implement graceful shutdown
- Set appropriate memory and CPU limits
- Use minimum instances for latency-sensitive apps

**2. Cloud Functions:**

- Keep functions focused and small
- Avoid global variables for state
- Use Cloud Firestore or Cloud Storage for persistence
- Set appropriate timeouts
- Handle errors gracefully
- Use environment variables for configuration

**3. Security:**

- Require authentication when possible
- Use service accounts with minimal permissions
- Store secrets in Secret Manager
- Validate input data
- Use VPC connectors for private resources

**4. Cost Optimization:**

- Set max instances to control costs
- Use appropriate memory allocation
- Implement caching where possible
- Monitor usage and optimize cold starts
- Consider min-instances only when needed

========================
Monitoring and Debugging
========================

**Cloud Run Metrics:**

.. code-block:: bash

    # View metrics in Cloud Console or use:
    gcloud run services describe myapp \
        --region us-central1 \
        --format="value(status.url)"

**Cloud Functions Testing:**

.. code-block:: bash

    # Local testing with Functions Framework
    pip install functions-framework
    
    # Run locally
    functions-framework --target=hello_http --debug

**View Error Reporting:**

- Go to Cloud Console → Error Reporting
- View errors grouped by type
- Set up notifications for new errors

===============
Troubleshooting
===============

**Common Issues:**

1. **Cold Start Latency**
   
   - Use minimum instances
   - Optimize container size
   - Use lighter base images

2. **Timeout Errors**
   
   - Increase timeout setting
   - Optimize code performance
   - Check external API latencies

3. **Memory Issues**
   
   - Increase memory allocation
   - Check for memory leaks
   - Optimize data processing

4. **Permission Errors**
   
   - Verify service account permissions
   - Check IAM policies
   - Enable required APIs

====================
Additional Resources
====================

- Cloud Run Documentation: https://cloud.google.com/run/docs
- Cloud Functions Documentation: https://cloud.google.com/functions/docs
- Serverless on GCP Guide: https://cloud.google.com/serverless
- Cloud Run Samples: https://github.com/GoogleCloudPlatform/cloud-run-samples
- Cloud Functions Samples: https://github.com/GoogleCloudPlatform/functions-framework-python

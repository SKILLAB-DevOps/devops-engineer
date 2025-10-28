####################
11.5 Cloud Storage
####################

.. note::

    Google Cloud Storage is a unified object storage service offering industry-leading scalability, data availability, security, and performance. It's designed for storing and accessing large amounts of unstructured data. Cloud Storage is similar to AWS S3 but offers unique features like automatic multi-regional replication, integrated CDN, and a unified API across storage classes.

==========================
Cloud Storage Fundamentals
==========================

**Key Features:**

- **Unified Experience**: Single API for all storage classes
- **Global Edge Caching**: Automatic caching at Google's edge locations
- **Strong Consistency**: Immediate read-after-write and list consistency
- **Object Versioning**: Maintain multiple versions of objects
- **Lifecycle Management**: Automatic data lifecycle policies
- **Object Composition**: Combine up to 32 objects into one
- **Encryption**: Automatic encryption at rest and in transit
- **IAM Integration**: Fine-grained access control

**Storage Classes:**

+-------------------+------------------+------------------+---------------------------+
| Storage Class     | Access Frequency | Minimum Duration | Use Case                  |
+===================+==================+==================+===========================+
| Standard          | Frequent         | None             | Hot data, websites        |
+-------------------+------------------+------------------+---------------------------+
| Nearline          | Once per month   | 30 days          | Backups, infrequent       |
+-------------------+------------------+------------------+---------------------------+
| Coldline          | Once per quarter | 90 days          | Disaster recovery         |
+-------------------+------------------+------------------+---------------------------+
| Archive           | Once per year    | 365 days         | Long-term archival        |
+-------------------+------------------+------------------+---------------------------+

**Key Concepts:**

- **Buckets**: Containers for storing objects
- **Objects**: Individual pieces of data stored in buckets
- **Metadata**: Key-value pairs associated with objects
- **Access Control**: IAM policies and ACLs for permissions
- **Versioning**: Keep multiple versions of objects
- **Lifecycle**: Automatic object management policies

=================
Installing gsutil
=================

`gsutil` is the command-line tool for interacting with Cloud Storage.

**Install with Google Cloud SDK:**

.. code-block:: bash

    # Install Google Cloud SDK (includes gsutil)
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
    
    # Initialize gcloud
    gcloud init
    
    # Verify gsutil installation
    gsutil version
    
    # Configure credentials
    gcloud auth login

**Standalone Installation:**

.. code-block:: bash

    # Using pip
    pip install gsutil
    
    # Verify
    gsutil version -l

================
Creating Buckets
================

**Create a Bucket:**

.. code-block:: bash

    # Create bucket in multi-region
    gsutil mb gs://my-unique-bucket-name-12345/
    
    # Create bucket in specific region
    gsutil mb -l us-central1 gs://my-regional-bucket/
    
    # Create bucket with specific storage class
    gsutil mb -c NEARLINE gs://my-nearline-bucket/
    
    # Create bucket with all options
    gsutil mb \
        -p PROJECT_ID \
        -c STANDARD \
        -l US \
        -b on \
        gs://my-bucket/

**Bucket Naming Rules:**

- Globally unique across all of Google Cloud
- 3-63 characters long
- Lowercase letters, numbers, dashes, underscores, dots
- Must start and end with a number or letter
- Cannot contain spaces or uppercase letters
- Cannot be an IP address

**Examples:**

.. code-block:: bash

    # Good bucket names
    gsutil mb gs://my-company-data-2024/
    gsutil mb gs://web-assets.example.com/
    gsutil mb gs://backup_files_prod/
    
    # Bad bucket names (will fail)
    gsutil mb gs://My-Bucket/  # Contains uppercase
    gsutil mb gs://my bucket/  # Contains space
    gsutil mb gs://ab/          # Too short

**List Buckets:**

.. code-block:: bash

    # List all buckets in project
    gsutil ls
    
    # List buckets with details
    gsutil ls -L
    
    # List buckets in specific project
    gsutil ls -p PROJECT_ID

=================
Uploading Objects
=================

**Upload Single File:**

.. code-block:: bash

    # Upload file to bucket
    gsutil cp local-file.txt gs://my-bucket/
    
    # Upload to specific path
    gsutil cp local-file.txt gs://my-bucket/folder/subfolder/
    
    # Upload with custom metadata
    gsutil -h "Content-Type:application/json" \
        -h "Cache-Control:public, max-age=3600" \
        cp data.json gs://my-bucket/

**Upload Multiple Files:**

.. code-block:: bash

    # Upload all files in directory
    gsutil cp *.jpg gs://my-bucket/images/
    
    # Upload directory recursively
    gsutil cp -r ./local-folder gs://my-bucket/
    
    # Upload with parallel processing (faster for large files)
    gsutil -m cp -r ./local-folder gs://my-bucket/

**Upload from stdin:**

.. code-block:: bash

    # Pipe data to Cloud Storage
    echo "Hello, Cloud Storage!" | gsutil cp - gs://my-bucket/hello.txt
    
    # Compress and upload
    tar -czf - ./my-folder | gsutil cp - gs://my-bucket/backup.tar.gz

**Resumable Uploads (for large files):**

.. code-block:: bash

    # Automatically enabled for files > 8 MB
    gsutil cp large-file.bin gs://my-bucket/
    
    # Set resumable threshold
    gsutil -o "GSUtil:resumable_threshold=1048576" cp file.bin gs://my-bucket/

===================
Downloading Objects
===================

**Download Single File:**

.. code-block:: bash

    # Download file
    gsutil cp gs://my-bucket/file.txt .
    
    # Download to specific location
    gsutil cp gs://my-bucket/file.txt /local/path/
    
    # Download and rename
    gsutil cp gs://my-bucket/file.txt ./new-name.txt

**Download Multiple Files:**

.. code-block:: bash

    # Download all files from bucket
    gsutil cp gs://my-bucket/* .
    
    # Download directory recursively
    gsutil cp -r gs://my-bucket/folder ./local-folder
    
    # Download with parallel processing
    gsutil -m cp -r gs://my-bucket/* ./local-backup/

**Download with Wildcards:**

.. code-block:: bash

    # Download all JPG files
    gsutil cp gs://my-bucket/*.jpg ./images/
    
    # Download files matching pattern
    gsutil cp gs://my-bucket/logs/2024-*.log ./logs/

===============
Listing Objects
===============

**List Objects:**

.. code-block:: bash

    # List all objects in bucket
    gsutil ls gs://my-bucket/
    
    # List recursively
    gsutil ls -r gs://my-bucket/**
    
    # List with details (size, modification time)
    gsutil ls -l gs://my-bucket/
    
    # List with human-readable sizes
    gsutil ls -lh gs://my-bucket/
    
    # List with additional details
    gsutil ls -L gs://my-bucket/file.txt

**Filter Listings:**

.. code-block:: bash

    # List specific folder
    gsutil ls gs://my-bucket/folder/
    
    # List with wildcard
    gsutil ls gs://my-bucket/**.log
    
    # Count objects
    gsutil ls gs://my-bucket/** | wc -l

================
Managing Objects
================

**Copy Objects:**

.. code-block:: bash

    # Copy within same bucket
    gsutil cp gs://my-bucket/file.txt gs://my-bucket/backup/
    
    # Copy between buckets
    gsutil cp gs://source-bucket/file.txt gs://dest-bucket/
    
    # Copy with parallel processing
    gsutil -m cp gs://source-bucket/** gs://dest-bucket/

**Move/Rename Objects:**

.. code-block:: bash

    # Move object
    gsutil mv gs://my-bucket/old-name.txt gs://my-bucket/new-name.txt
    
    # Move to different bucket
    gsutil mv gs://my-bucket/file.txt gs://other-bucket/

**Delete Objects:**

.. code-block:: bash

    # Delete single object
    gsutil rm gs://my-bucket/file.txt
    
    # Delete multiple objects
    gsutil rm gs://my-bucket/file1.txt gs://my-bucket/file2.txt
    
    # Delete with wildcard
    gsutil rm gs://my-bucket/*.log
    
    # Delete folder recursively
    gsutil rm -r gs://my-bucket/folder/
    
    # Delete all objects in bucket (parallel)
    gsutil -m rm -r gs://my-bucket/**

**Get Object Metadata:**

.. code-block:: bash

    # Display object metadata
    gsutil stat gs://my-bucket/file.txt
    
    # Get specific metadata
    gsutil ls -L gs://my-bucket/file.txt

===============
Object Metadata
===============

**Set Custom Metadata:**

.. code-block:: bash

    # Set metadata during upload
    gsutil -h "x-goog-meta-author:Alice" \
        -h "x-goog-meta-department:Engineering" \
        cp file.txt gs://my-bucket/
    
    # Update metadata on existing object
    gsutil setmeta \
        -h "x-goog-meta-author:Bob" \
        -h "x-goog-meta-updated:2024-01-10" \
        gs://my-bucket/file.txt

**Set Cache Control:**

.. code-block:: bash

    # Set cache headers
    gsutil setmeta \
        -h "Cache-Control:public, max-age=3600" \
        gs://my-bucket/style.css
    
    # Update multiple files
    gsutil -m setmeta \
        -h "Cache-Control:public, max-age=86400" \
        gs://my-bucket/images/*.jpg

**Set Content Type:**

.. code-block:: bash

    # Set content type
    gsutil setmeta \
        -h "Content-Type:application/json" \
        gs://my-bucket/data.json

==============
Access Control
==============

**Bucket-Level IAM:**

.. code-block:: bash

    # Grant user view access
    gsutil iam ch user:alice@example.com:objectViewer gs://my-bucket
    
    # Grant user admin access
    gsutil iam ch user:bob@example.com:objectAdmin gs://my-bucket
    
    # Grant service account access
    gsutil iam ch \
        serviceAccount:my-sa@project.iam.gserviceaccount.com:objectCreator \
        gs://my-bucket
    
    # Make bucket publicly readable
    gsutil iam ch allUsers:objectViewer gs://my-bucket
    
    # View IAM policy
    gsutil iam get gs://my-bucket

**Object-Level ACLs:**

.. code-block:: bash

    # Make object public
    gsutil acl set public-read gs://my-bucket/file.txt
    
    # Make object private
    gsutil acl set private gs://my-bucket/file.txt
    
    # Grant user read access
    gsutil acl ch -u alice@example.com:R gs://my-bucket/file.txt
    
    # Grant group access
    gsutil acl ch -g developers@example.com:R gs://my-bucket/file.txt
    
    # View ACL
    gsutil acl get gs://my-bucket/file.txt

**Signed URLs (Temporary Access):**

.. code-block:: bash

    # Generate signed URL valid for 1 hour
    gsutil signurl -d 1h key.json gs://my-bucket/file.txt
    
    # Generate signed URL for download
    gsutil signurl -d 7d key.json gs://my-bucket/download.zip
    
    # Generate signed URL for upload (PUT)
    gsutil signurl -m PUT -d 1h key.json gs://my-bucket/upload.txt

=================
Object Versioning
=================

**Enable Versioning:**

.. code-block:: bash

    # Enable object versioning
    gsutil versioning set on gs://my-bucket
    
    # Check versioning status
    gsutil versioning get gs://my-bucket

**List Object Versions:**

.. code-block:: bash

    # List all versions of objects
    gsutil ls -a gs://my-bucket/file.txt
    
    # List with generation numbers
    gsutil ls -la gs://my-bucket/

**Access Specific Version:**

.. code-block:: bash

    # Download specific version
    gsutil cp gs://my-bucket/file.txt#1234567890123456 ./
    
    # Delete specific version
    gsutil rm gs://my-bucket/file.txt#1234567890123456

**Disable Versioning:**

.. code-block:: bash

    # Disable versioning (keeps existing versions)
    gsutil versioning set off gs://my-bucket

====================
Lifecycle Management
====================

**Create Lifecycle Configuration:**

.. code-block:: json

    // lifecycle.json
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
              "matchesPrefix": ["logs/"]
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

**Apply Lifecycle Policy:**

.. code-block:: bash

    # Set lifecycle policy
    gsutil lifecycle set lifecycle.json gs://my-bucket
    
    # View lifecycle policy
    gsutil lifecycle get gs://my-bucket

**Common Lifecycle Rules:**

.. code-block:: bash

    # Auto-delete old objects
    cat > delete-old.json << EOF
    {
      "lifecycle": {
        "rule": [{
          "action": {"type": "Delete"},
          "condition": {"age": 90}
        }]
      }
    }
    EOF
    
    gsutil lifecycle set delete-old.json gs://my-bucket
    
    # Move to Nearline after 30 days
    cat > move-nearline.json << EOF
    {
      "lifecycle": {
        "rule": [{
          "action": {
            "type": "SetStorageClass",
            "storageClass": "NEARLINE"
          },
          "condition": {"age": 30}
        }]
      }
    }
    EOF
    
    gsutil lifecycle set move-nearline.json gs://my-bucket

======================
Hosting Static Website
======================

**Setup Website Hosting:**

.. code-block:: bash

    # Create HTML files
    cat > index.html << 'EOF'
    <!DOCTYPE html>
    <html>
    <head>
        <title>My Cloud Storage Website</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                max-width: 800px;
                margin: 50px auto;
                text-align: center;
            }
            h1 { color: #4285f4; }
        </style>
    </head>
    <body>
        <h1>Welcome to My GCS Website!</h1>
        <p>This website is hosted on Google Cloud Storage</p>
    </body>
    </html>
    EOF
    
    cat > 404.html << 'EOF'
    <!DOCTYPE html>
    <html>
    <head><title>404 Not Found</title></head>
    <body>
        <h1>Page Not Found</h1>
        <p>The requested page does not exist.</p>
    </body>
    </html>
    EOF
    
    # Create bucket (must match domain name for custom domain)
    gsutil mb gs://www.example.com/
    
    # Upload files
    gsutil cp index.html gs://www.example.com/
    gsutil cp 404.html gs://www.example.com/
    
    # Set website configuration
    gsutil web set -m index.html -e 404.html gs://www.example.com/
    
    # Make bucket public
    gsutil iam ch allUsers:objectViewer gs://www.example.com/

**Access Website:**

- Default URL: `https://storage.googleapis.com/BUCKET_NAME/index.html`
- Shorter URL: `https://BUCKET_NAME.storage.googleapis.com`
- Custom domain: `https://www.example.com` (requires DNS configuration)

**Configure Custom Domain:**

.. code-block:: bash

    # 1. Verify domain ownership in Google Search Console
    
    # 2. Create CNAME record in your DNS:
    #    www.example.com. CNAME c.storage.googleapis.com.
    
    # 3. Create bucket with domain name
    gsutil mb gs://www.example.com/
    
    # 4. Upload website files
    gsutil cp -r ./website/* gs://www.example.com/
    
    # 5. Configure website
    gsutil web set -m index.html -e 404.html gs://www.example.com/
    
    # 6. Make public
    gsutil iam ch allUsers:objectViewer gs://www.example.com/

======================
Bucket Synchronization
======================

**Sync Local Directory to Bucket:**

.. code-block:: bash

    # Sync directory (upload new and updated files)
    gsutil rsync -r ./local-dir gs://my-bucket/remote-dir
    
    # Sync with delete (remove remote files not in local)
    gsutil rsync -r -d ./local-dir gs://my-bucket/remote-dir
    
    # Dry run (see what would be synced)
    gsutil rsync -r -n ./local-dir gs://my-bucket/remote-dir
    
    # Exclude files
    gsutil rsync -r -x '.*\.tmp$' ./local-dir gs://my-bucket/remote-dir

**Sync Between Buckets:**

.. code-block:: bash

    # Sync between buckets
    gsutil rsync -r gs://source-bucket gs://dest-bucket
    
    # Sync specific folder
    gsutil rsync -r gs://source-bucket/folder gs://dest-bucket/folder

================
Transfer Service
================

For large-scale data transfers, use Storage Transfer Service:

.. code-block:: bash

    # Install transfer service tool
    pip install google-cloud-storage-transfer
    
    # Create transfer job (from AWS S3 to GCS)
    gcloud transfer jobs create \
        s3://my-s3-bucket \
        gs://my-gcs-bucket \
        --source-creds-file=aws-creds.json

==================
Cloud Storage FUSE
==================

Mount Cloud Storage bucket as a file system:

.. code-block:: bash

    # Install gcsfuse
    export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
    echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install gcsfuse
    
    # Create mount point
    mkdir -p ~/gcs-mount
    
    # Mount bucket
    gcsfuse my-bucket ~/gcs-mount
    
    # Access files
    ls ~/gcs-mount
    
    # Unmount
    fusermount -u ~/gcs-mount

======================
Monitoring and Logging
======================

**View Bucket Usage:**

.. code-block:: bash

    # Get bucket size
    gsutil du -s gs://my-bucket
    
    # Get bucket size with human-readable format
    gsutil du -sh gs://my-bucket
    
    # Get detailed usage
    gsutil du -h gs://my-bucket/**

**Enable Logging:**

.. code-block:: bash

    # Create log bucket
    gsutil mb gs://my-logs-bucket
    
    # Enable logging
    gsutil logging set on \
        -b gs://my-logs-bucket \
        -o log-prefix/ \
        gs://my-bucket
    
    # View logging configuration
    gsutil logging get gs://my-bucket

========================
Performance Optimization
========================

**Parallel Processing:**

.. code-block:: bash

    # Use -m flag for parallel operations
    gsutil -m cp -r ./large-folder gs://my-bucket/
    
    # Configure parallel upload settings
    gsutil -o "GSUtil:parallel_thread_count=16" \
        -o "GSUtil:parallel_process_count=4" \
        cp -r ./large-folder gs://my-bucket/

**Composite Objects:**

.. code-block:: bash

    # Split large upload into parts and compose
    gsutil -o GSUtil:parallel_composite_upload_threshold=150M \
        cp large-file.bin gs://my-bucket/

**Resumable Uploads:**

.. code-block:: bash

    # Set resumable threshold (automatically resumes on failure)
    gsutil -o "GSUtil:resumable_threshold=8388608" \
        cp large-file.bin gs://my-bucket/

==============
Best Practices
==============

**1. Bucket Naming:**

- Use descriptive, globally unique names
- Include project name or organization
- Avoid sensitive information in names

**2. Access Control:**

- Use IAM for bucket-level permissions
- Use signed URLs for temporary access
- Never make sensitive data public
- Use service accounts for applications

**3. Cost Optimization:**

- Choose appropriate storage class
- Implement lifecycle policies
- Use Nearline/Coldline for infrequent access
- Monitor and optimize egress traffic

**4. Performance:**

- Use parallel operations (`-m` flag)
- Distribute load across different prefixes
- Use Cloud CDN for frequently accessed content
- Consider regional vs multi-regional based on access patterns

**5. Data Management:**

- Enable versioning for important data
- Implement backup and disaster recovery plans
- Use object lifecycle management
- Regular audit of access permissions

===============
Troubleshooting
===============

**Permission Errors:**

.. code-block:: bash

    # Check IAM permissions
    gsutil iam get gs://my-bucket
    
    # Grant yourself owner access
    gsutil iam ch user:YOUR_EMAIL:objectAdmin gs://my-bucket

**Upload/Download Failures:**

.. code-block:: bash

    # Enable debug output
    gsutil -D cp file.txt gs://my-bucket/
    
    # Check for network issues
    gsutil -d ls gs://my-bucket/

**Quota Errors:**

.. code-block:: bash

    # Check quota limits in Cloud Console
    # Request quota increase if needed

=======
Cleanup
=======

.. code-block:: bash

    # Delete all objects in bucket
    gsutil -m rm -r gs://my-bucket/**
    
    # Delete bucket
    gsutil rb gs://my-bucket
    
    # Force delete (removes all objects)
    gsutil rm -r gs://my-bucket

====================
Additional Resources
====================

- Cloud Storage Documentation: https://cloud.google.com/storage/docs
- gsutil Tool: https://cloud.google.com/storage/docs/gsutil
- Storage Classes: https://cloud.google.com/storage/docs/storage-classes
- Access Control: https://cloud.google.com/storage/docs/access-control
- Best Practices: https://cloud.google.com/storage/docs/best-practices

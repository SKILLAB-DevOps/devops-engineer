# Google Cloud Workflows - Star Wars API Data Collector

A comprehensive data collection solution using Google Cloud Workflows that fetches Star Wars universe data from the SWAPI (Star Wars API) at swapi.tech and stores results in Cloud Storage.

## Overview

This project demonstrates real-world API integration using Google Cloud Workflows to collect structured data from the Star Wars API:

1. **Star Wars Data Collector**: Fetches characters, planets, starships, films, species, and vehicles data
2. **Advanced Scraper**: Enhanced workflow with data enrichment and analysis capabilities

## Features

- **Star Wars API Integration**: Collect comprehensive data from swapi.tech (characters, planets, starships, films, species, vehicles)
- **Multi-Endpoint Processing**: Fetch data from multiple API endpoints in a single workflow execution
- **Structured Data Handling**: Automatically processes JSON API responses with detailed item fetching
- **Error Handling**: Robust error handling with detailed logging for API failures
- **Cloud Storage Integration**: Automatically stores results in Google Cloud Storage with timestamped filenames
- **Data Organization**: Structured output with summaries, detailed items, and metadata
- **Scalable**: Built on Google Cloud's serverless infrastructure
- **Cost-Effective**: Pay only for execution time, efficient API calls

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Workflow      │───▶│  Star Wars API   │───▶│  Cloud Storage  │
│   Trigger       │    │  Data Collection │    │  Results        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │                       ▼                       │
         │              ┌──────────────────┐             │
         │              │  swapi.tech      │             │
         └──────────────│  API Integration │─────────────┘
                        │  & Processing    │
                        └──────────────────┘

Data Flow:
1. Workflow receives endpoints list (people, planets, starships, etc.)
2. For each endpoint, fetches the list of available items
3. Retrieves detailed data for first 5 items from each endpoint
4. Processes and structures the data with metadata
5. Stores complete dataset in Cloud Storage with timestamp
```

## Workflow Files

- `simple-scraper-workflow.yaml` - Star Wars API data collector workflow
- `advanced-scraper-workflow.yaml` - Enhanced workflow with data enrichment
- `scraper-workflow.yaml` - Legacy web scraping workflow  
- `deploy.sh` - One-command deployment script
- `examples.sh` - Star Wars API testing examples

## Prerequisites

1. **Google Cloud Project** with billing enabled
2. **Required APIs enabled**:
   - Cloud Workflows API
   - Cloud Storage API
   - Cloud Build API (optional)

3. **gcloud CLI** installed and configured
4. **Appropriate IAM permissions**:
   - Workflows Developer
   - Storage Object Creator
   - Service Account User

## Quick Setup

### 1. Deploy the Workflows

```bash
# Make deploy script executable
chmod +x deploy.sh

# Deploy workflows (replace with your project ID)
./deploy.sh your-project-id us-central1
```

### 2. Test Star Wars Data Collection

```bash
# Collect Star Wars character data
gcloud workflows run star-wars-collector \
    --location=us-central1 \
    --data='{
        "endpoints": ["people"],
        "bucket": "star-wars-data-your-project-id"
    }'
```

### 3. Collect All Star Wars Data

```bash
# Get comprehensive Star Wars dataset
gcloud workflows run star-wars-collector \
    --location=us-central1 \
    --data='{
        "endpoints": ["people", "planets", "starships", "films", "species", "vehicles"],
        "bucket": "star-wars-data-your-project-id"
    }'
```

## Usage Examples

### Star Wars Characters Data

Collect detailed character information from the Star Wars universe:

```bash
gcloud workflows run star-wars-collector \
    --location=us-central1 \
    --data='{
        "endpoints": ["people"],
        "bucket": "star-wars-data-bucket"
    }'
```

### Planets and Starships Data

```bash
gcloud workflows run star-wars-collector \
    --location=us-central1 \
    --data='{
        "endpoints": ["planets", "starships"],
        "bucket": "star-wars-data-bucket"
    }'
```

### Complete Star Wars Dataset

Collect all available data from the Star Wars API:

```bash
gcloud workflows run star-wars-collector \
    --location=us-central1 \
    --data='{
        "endpoints": ["people", "planets", "starships", "films", "species", "vehicles"],
        "bucket": "star-wars-universe-data"
    }'
```

### Quick Testing with Examples Script

```bash
# Run comprehensive tests
./examples.sh your-project-id us-central1
```

## Input Parameters

### Star Wars Data Collector Parameters

```json
{
  "endpoints": ["people", "planets", "starships", "films", "species", "vehicles"],
  "bucket": "cloud-storage-bucket-name"
}
```

**Available Endpoints:**
- `people` - Characters (Luke Skywalker, Darth Vader, etc.)
- `planets` - Planets (Tatooine, Alderaan, etc.)  
- `starships` - Starships (Millennium Falcon, Star Destroyer, etc.)
- `films` - Movies (A New Hope, Empire Strikes Back, etc.)
- `species` - Species (Human, Wookiee, Droid, etc.)
- `vehicles` - Vehicles (AT-AT, Speeder Bike, etc.)

### Advanced Workflow Parameters

```json
{
  "endpoints": ["people", "planets"],
  "bucket": "star-wars-data-bucket", 
  "enrichment": true,
  "dataset": "bigquery-dataset-id",
  "table": "bigquery-table-id"
}
```

## Output Format

### Basic Scraper Output

```json
{
  "workflow_id": "execution-id",
  "execution_time": "2025-10-29T10:30:00Z",
  "total_urls": 3,
  "successful_scrapes": 2,
  "failed_scrapes": 1,
  "results": [
    {
      "url": "https://httpbin.org/json", 
      "status_code": 200,
      "content_type": "application/json",
      "data": {...},
      "scraped_at": "2025-10-29T10:30:15Z"
    }
  ],
  "errors": [
    {
      "url": "https://invalid-url.com",
      "error": "Connection timeout",
      "timestamp": "2025-10-29T10:30:20Z"
    }
  ]
}
```

### Advanced Scraper Output

```json
{
  "workflow_execution_id": "execution-id",
  "execution_timestamp": "2025-10-29T10:30:00Z",
  "scraping_summary": {
    "urls_requested": ["https://example.com"],
    "results_count": 1,
    "enrichment_enabled": true
  },
  "data": [
    {
      "id": "base64-url-hash",
      "url": "https://example.com",
      "domain": "example.com",
      "status_code": 200,
      "content_type": "text/html",
      "html_preview": "...",
      "size_bytes": 1234,
      "analysis": {
        "word_count": 150,
        "has_content": true,
        "category": "article"
      }
    }
  ]
}
```

## Monitoring and Management

### Check Workflow Executions

```bash
# List recent executions
gcloud workflows executions list \
    --workflow=web-scraper-workflow \
    --location=us-central1

# Get execution details
gcloud workflows executions describe EXECUTION_ID \
    --workflow=web-scraper-workflow \
    --location=us-central1
```

### View Stored Results

```bash
# List files in storage bucket
gsutil ls gs://your-bucket-name/

# Download results
gsutil cp gs://your-bucket-name/scrape_*.json .

# View file content
cat scrape_results_*.json | jq '.'
```

### Monitor Logs

```bash
# View workflow logs
gcloud logging read "resource.type=workflows.googleapis.com/Workflow" \
    --limit=50 \
    --format="table(timestamp, severity, textPayload)"
```

## Configuration Options

### Workflow Limits

- **Maximum URLs per execution**: 20 (configurable)
- **Request timeout**: 30 seconds
- **Content size limit**: 5KB preview for HTML
- **Delay between requests**: 0.5-1 seconds

### Storage Options

- **Cloud Storage**: Primary storage for all results
- **BigQuery**: Optional structured data storage (advanced workflow)
- **File Format**: JSON with structured metadata

## Security and Best Practices

### Service Account Permissions

The workflow uses a dedicated service account with minimal required permissions:

```bash
# Required IAM roles
- roles/storage.objectCreator
- roles/workflows.invoker
```

### Content Limits

- HTML content is truncated to prevent memory issues
- Request timeouts prevent hanging executions  
- Rate limiting protects target websites

### Error Handling

- Robust exception handling for network failures
- Detailed error logging for troubleshooting
- Graceful degradation on partial failures

## Cost Optimization

### Workflow Execution Costs

- **Basic scraping**: ~$0.0001 per URL
- **Advanced scraping**: ~$0.0002 per URL  
- **Storage costs**: Standard Cloud Storage rates

### Optimization Tips

1. **Batch URLs** in single execution
2. **Use appropriate regions** to minimize latency
3. **Configure timeouts** to prevent hanging
4. **Monitor execution frequency** to avoid unnecessary runs

## Troubleshooting

### Common Issues

1. **Permission Errors**
   ```bash
   # Check service account permissions
   gcloud iam service-accounts get-iam-policy workflow-scraper@PROJECT.iam.gserviceaccount.com
   ```

2. **Storage Access Errors**
   ```bash
   # Verify bucket exists and has correct permissions
   gsutil ls -L -b gs://your-bucket-name
   ```

3. **Workflow Execution Failures**
   ```bash
   # Check workflow logs
   gcloud workflows executions describe EXECUTION_ID --workflow=WORKFLOW_NAME --location=REGION
   ```

### Debug Mode

Enable detailed logging by modifying the workflow to include more `sys.log` calls:

```yaml
- debug_step:
    call: sys.log
    args:
      text: ${"Debug info: " + json.encode(variable)}
      severity: "DEBUG"
```

## Extensions and Customization

### Adding New Content Types

Modify the content processing logic to handle additional formats:

```yaml
- condition: ${text.match_regex(content_type, ".*xml.*")}
  steps:
    - parse_xml:
        # Add XML parsing logic
```

### Integration with Other Services

- **BigQuery**: Store structured data in tables
- **Pub/Sub**: Trigger workflows from messages  
- **Cloud Functions**: Post-process scraped data
- **Cloud Run**: Use custom scraping logic

This workflow provides a robust foundation for web scraping that can be extended and customized for specific use cases.
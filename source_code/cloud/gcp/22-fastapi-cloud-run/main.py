"""
Star Wars API Data Collector
Simple FastAPI app that fetches Star Wars data and stores it in Google Cloud Storage
"""

from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel
from typing import List
import datetime
import json
import os
import httpx
import asyncio
from google.cloud import storage

# Configuration
BUCKET_NAME = os.getenv("BUCKET_NAME", "star-wars-data-bucket")
SWAPI_BASE_URL = "https://www.swapi.tech/api"

# Initialize FastAPI app
app = FastAPI(title="Star Wars Data Collector", version="1.0.0")

# Initialize Cloud Storage
try:
    storage_client = storage.Client()
    bucket = storage_client.bucket(BUCKET_NAME)
    print(f"Connected to bucket: {BUCKET_NAME}")
except Exception as e:
    print(f"Storage not available: {e}")
    bucket = None

# Data Models
class StarWarsRequest(BaseModel):
    endpoints: List[str] = ["people", "planets"]
    max_items: int = 3

class StarWarsResponse(BaseModel):
    success: bool
    total_items: int
    storage_location: str

# Helper Functions
def get_timestamp():
    return datetime.datetime.now().isoformat()

def save_to_storage(data: dict, filename: str) -> bool:
    """Save data to Cloud Storage"""
    if not bucket:
        return False
    
    try:
        blob = bucket.blob(filename)
        blob.upload_from_string(json.dumps(data, indent=2))
        return True
    except Exception:
        return False

async def fetch_star_wars_data(endpoint: str, max_items: int = 3):
    """Fetch data from a single Star Wars API endpoint"""
    async with httpx.AsyncClient() as client:
        try:
            # Get list of items
            response = await client.get(f"{SWAPI_BASE_URL}/{endpoint}")
            response.raise_for_status()
            data = response.json()
            
            items = data["result"]["results"]
            collected_items = []
            
            # Get detailed data for first few items
            for i, item in enumerate(items[:max_items]):
                detail_response = await client.get(item["url"])
                if detail_response.status_code == 200:
                    collected_items.append(detail_response.json()["result"])
                
                # Small delay between requests
                await asyncio.sleep(0.1)
            
            return {
                "endpoint": endpoint,
                "total_available": data["result"]["total_records"],
                "items_collected": len(collected_items),
                "data": collected_items,
                "timestamp": get_timestamp()
            }
            
        except Exception as e:
            return {
                "endpoint": endpoint,
                "error": str(e),
                "timestamp": get_timestamp()
            }

# API Endpoints

@app.get("/")
async def root():
    """API information"""
    return {
        "name": "Star Wars Data Collector",
        "version": "1.0.0",
        "endpoints": {
            "collect": "/star-wars/collect",
            "quick": "/star-wars/{endpoint}",
            "health": "/health"
        },
        "storage_connected": bucket is not None
    }

@app.get("/health")
async def health():
    """Health check"""
    return {
        "status": "healthy",
        "timestamp": get_timestamp(),
        "storage": "connected" if bucket else "unavailable"
    }

@app.get("/star-wars/endpoints")
async def list_endpoints():
    """List available Star Wars data types"""
    return {
        "available_endpoints": [
            {"name": "people", "description": "Characters"},
            {"name": "planets", "description": "Planets"},
            {"name": "starships", "description": "Starships"},
            {"name": "films", "description": "Movies"},
            {"name": "species", "description": "Species"},
            {"name": "vehicles", "description": "Vehicles"}
        ]
    }

@app.get("/star-wars/{endpoint}")
async def quick_collect(endpoint: str, background_tasks: BackgroundTasks):
    """Quick collect from single endpoint"""
    valid_endpoints = ["people", "planets", "starships", "films", "species", "vehicles"]
    
    if endpoint not in valid_endpoints:
        raise HTTPException(status_code=400, detail="Invalid endpoint")
    
    # Collect data
    result = await fetch_star_wars_data(endpoint)
    
    # Save to storage in background
    filename = f"quick/{endpoint}_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    background_tasks.add_task(save_to_storage, result, filename)
    
    return {
        "success": True,
        "endpoint": endpoint,
        "items_collected": result.get("items_collected", 0),
        "storage_location": f"gs://{BUCKET_NAME}/{filename}" if bucket else "storage unavailable",
        "data_preview": result.get("data", [])[:2] if "data" in result else []
    }

@app.post("/star-wars/collect")
async def collect_multiple(request: StarWarsRequest, background_tasks: BackgroundTasks):
    """Collect data from multiple endpoints"""
    results = []
    total_items = 0
    
    # Collect from each endpoint
    for endpoint in request.endpoints:
        result = await fetch_star_wars_data(endpoint, request.max_items)
        results.append(result)
        total_items += result.get("items_collected", 0)
    
    # Prepare final dataset
    dataset = {
        "collection_info": {
            "collected_at": get_timestamp(),
            "endpoints_requested": request.endpoints,
            "total_items": total_items
        },
        "results": results
    }
    
    # Save to storage in background
    filename = f"collections/collection_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    background_tasks.add_task(save_to_storage, dataset, filename)
    
    return {
        "success": True,
        "endpoints_processed": len(request.endpoints),
        "total_items_collected": total_items,
        "storage_location": f"gs://{BUCKET_NAME}/{filename}" if bucket else "storage unavailable"
    }

@app.get("/storage/files")
async def list_files():
    """List stored files"""
    if not bucket:
        raise HTTPException(status_code=503, detail="Storage not available")
    
    try:
        files = []
        for blob in bucket.list_blobs(max_results=20):
            files.append({
                "name": blob.name,
                "size": blob.size,
                "created": blob.time_created.isoformat() if blob.time_created else None
            })
        
        return {"files": files, "total": len(files)}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Run the app
if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8080))
    uvicorn.run("main:app", host="0.0.0.0", port=port)
"""FastAPI DevOps System Information API main application."""

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime

from .models import APIInfo
from .routers import system

# Create FastAPI application
app = FastAPI(
    title="DevOps System Information API",
    description="""
    A modern FastAPI-based web API that provides system information endpoints.
    
    This API provides detailed information about:
    - CPU usage and timing statistics
    - Memory utilization and availability  
    - Disk partitions and mount points
    - Network interface statistics
    - Swap memory usage
    - Hardware temperature sensors
    
    Originally converted from a Click CLI application to demonstrate 
    how to modernize command-line tools into web APIs.
    """,
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(system.router)


@app.get("/", response_model=APIInfo, summary="API Information")
async def root():
    """
    Get API information and health check.
    
    Returns basic information about the API including:
    - API name and version
    - Description
    - Current timestamp
    
    This endpoint can be used as a health check to verify
    the API is running and responsive.
    """
    return APIInfo(
        name="DevOps System Information API",
        version="0.1.0", 
        description="FastAPI-based system information service",
        timestamp=datetime.now()
    )


@app.get("/health", summary="Health Check")
async def health_check():
    """
    Simple health check endpoint.
    
    Returns a simple status message to verify the API is running.
    This is useful for load balancers and monitoring systems.
    """
    return {"status": "healthy", "timestamp": datetime.now()}


def main():
    """Main entry point for the CLI command."""
    uvicorn.run(
        "devops_api.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )


if __name__ == "__main__":
    main()

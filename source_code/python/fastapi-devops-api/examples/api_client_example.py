#!/usr/bin/env python3
"""
Example client for the FastAPI DevOps System Information API.

This script demonstrates how to interact with the API programmatically.
"""

import asyncio
import json
from typing import Dict, Any
import httpx


class DevOpsAPIClient:
    """Client for interacting with the DevOps System Information API."""

    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url

    async def get_api_info(self) -> Dict[str, Any]:
        """Get API information."""
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{self.base_url}/")
            response.raise_for_status()
            return response.json()

    async def get_health(self) -> Dict[str, Any]:
        """Check API health."""
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{self.base_url}/health")
            response.raise_for_status()
            return response.json()

    async def get_cpu_info(self) -> Dict[str, Any]:
        """Get CPU information."""
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{self.base_url}/system/cpu")
            response.raise_for_status()
            return response.json()

    async def get_memory_info(self) -> Dict[str, Any]:
        """Get memory information."""
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{self.base_url}/system/memory")
            response.raise_for_status()
            return response.json()

    async def get_all_system_info(self) -> Dict[str, Any]:
        """Get all system information."""
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{self.base_url}/system/all")
            response.raise_for_status()
            return response.json()


async def main():
    """Main example function."""
    client = DevOpsAPIClient()

    try:
        print("=== DevOps API Client Example ===\n")

        # Check API health
        print("1. Checking API health...")
        health = await client.get_health()
        print(f"   Status: {health['status']}")
        print(f"   Timestamp: {health['timestamp']}\n")

        # Get API info
        print("2. Getting API information...")
        api_info = await client.get_api_info()
        print(f"   Name: {api_info['name']}")
        print(f"   Version: {api_info['version']}")
        print(f"   Description: {api_info['description']}\n")

        # Get CPU info
        print("3. Getting CPU information...")
        cpu_info = await client.get_cpu_info()
        print(f"   User time: {cpu_info['user']:.2f}s")
        print(f"   System time: {cpu_info['system']:.2f}s")
        print(f"   Idle time: {cpu_info['idle']:.2f}s\n")

        # Get memory info
        print("4. Getting memory information...")
        memory_info = await client.get_memory_info()
        total_gb = memory_info['total'] / (1024**3)
        used_gb = memory_info['used'] / (1024**3)
        print(f"   Total: {total_gb:.2f} GB")
        print(f"   Used: {used_gb:.2f} GB ({memory_info['percent']:.1f}%)")
        print(f"   Available: {memory_info['available'] / (1024**3):.2f} GB\n")

        # Get complete system info
        print("5. Getting complete system information...")
        system_info = await client.get_all_system_info()
        print(f"   Timestamp: {system_info['timestamp']}")
        print(f"   Disk partitions: {len(system_info['disk']['partitions'])}")
        print(f"   Network bytes sent: {system_info['network']['bytes_sent']:,}")
        print(f"   Swap usage: {system_info['swap']['percent']:.1f}%")
        
        # Print sensors if available
        sensors = system_info['sensors']['sensors']
        if sensors:
            print(f"   Temperature sensors: {len(sensors)} groups found")
            for sensor_group, entries in sensors.items():
                print(f"     {sensor_group}: {len(entries)} sensors")
        else:
            print("   Temperature sensors: Not available on this system")

        print("\n=== Example completed successfully! ===")

    except httpx.RequestError as e:
        print(f"Error connecting to API: {e}")
        print("Make sure the API is running at http://localhost:8000")
    except httpx.HTTPStatusError as e:
        print(f"HTTP error: {e.response.status_code} - {e.response.text}")
    except Exception as e:
        print(f"Unexpected error: {e}")


if __name__ == "__main__":
    print("FastAPI DevOps System Information API - Example Client")
    print("=" * 60)
    print("This example demonstrates how to interact with the API.")
    print("Make sure to start the API server first:")
    print("  python -m uvicorn src.devops_api.main:app --reload")
    print("Or use the CLI command:")
    print("  devops-api")
    print("=" * 60)
    print()
    
    asyncio.run(main())

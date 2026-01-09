"""Tests for system information endpoints."""

import pytest
from fastapi.testclient import TestClient
from src.devops_api.main import app

client = TestClient(app)


def test_cpu_endpoint():
    """Test the CPU information endpoint."""
    response = client.get("/system/cpu")
    assert response.status_code == 200
    data = response.json()
    assert "user" in data
    assert "system" in data
    assert "idle" in data
    assert isinstance(data["user"], (int, float))
    assert isinstance(data["system"], (int, float))
    assert isinstance(data["idle"], (int, float))


def test_memory_endpoint():
    """Test the memory information endpoint."""
    response = client.get("/system/memory")
    assert response.status_code == 200
    data = response.json()
    assert "total" in data
    assert "available" in data
    assert "percent" in data
    assert "used" in data
    assert "free" in data
    assert isinstance(data["total"], int)
    assert isinstance(data["percent"], (int, float))
    assert 0 <= data["percent"] <= 100


def test_disk_endpoint():
    """Test the disk information endpoint."""
    response = client.get("/system/disk")
    assert response.status_code == 200
    data = response.json()
    assert "partitions" in data
    assert isinstance(data["partitions"], list)
    if data["partitions"]:  # If there are partitions
        partition = data["partitions"][0]
        assert "device" in partition
        assert "mountpoint" in partition
        assert "fstype" in partition


def test_network_endpoint():
    """Test the network information endpoint."""
    response = client.get("/system/network")
    assert response.status_code == 200
    data = response.json()
    assert "bytes_sent" in data
    assert "bytes_recv" in data
    assert "packets_sent" in data
    assert "packets_recv" in data
    assert isinstance(data["bytes_sent"], int)
    assert isinstance(data["bytes_recv"], int)


def test_swap_endpoint():
    """Test the swap information endpoint."""
    response = client.get("/system/swap")
    assert response.status_code == 200
    data = response.json()
    assert "total" in data
    assert "used" in data
    assert "free" in data
    assert "percent" in data
    assert isinstance(data["total"], int)
    assert isinstance(data["percent"], (int, float))
    assert 0 <= data["percent"] <= 100


def test_sensors_endpoint():
    """Test the sensors information endpoint."""
    response = client.get("/system/sensors")
    assert response.status_code == 200
    data = response.json()
    assert "sensors" in data
    assert isinstance(data["sensors"], dict)
    # Sensors may be empty on some systems, so we don't assert content


def test_all_system_info_endpoint():
    """Test the complete system information endpoint."""
    response = client.get("/system/all")
    assert response.status_code == 200
    data = response.json()
    
    # Check that all major components are present
    assert "cpu" in data
    assert "memory" in data
    assert "disk" in data
    assert "network" in data
    assert "swap" in data
    assert "sensors" in data
    assert "timestamp" in data
    
    # Basic validation of nested objects
    assert "user" in data["cpu"]
    assert "total" in data["memory"]
    assert "partitions" in data["disk"]
    assert "bytes_sent" in data["network"]
    assert "total" in data["swap"]
    assert "sensors" in data["sensors"]

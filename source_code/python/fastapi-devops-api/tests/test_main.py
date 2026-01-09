"""Tests for the main FastAPI application."""

import pytest
from fastapi.testclient import TestClient
from src.devops_api.main import app

client = TestClient(app)


def test_root_endpoint():
    """Test the root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "DevOps System Information API"
    assert data["version"] == "0.1.0"
    assert "timestamp" in data


def test_health_check():
    """Test the health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "timestamp" in data


def test_docs_endpoint():
    """Test that the documentation endpoint is accessible."""
    response = client.get("/docs")
    assert response.status_code == 200


def test_redoc_endpoint():
    """Test that the ReDoc endpoint is accessible."""
    response = client.get("/redoc")
    assert response.status_code == 200

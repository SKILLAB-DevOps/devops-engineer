import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from cursbnr_api.main import app, BNRService


class TestBNRService:
    """Test cases for BNR Service"""
    
    @pytest.fixture
    def bnr_service(self):
        return BNRService()
    
    @pytest.fixture
    def sample_xml(self):
        return """<?xml version="1.0" encoding="utf-8"?>
<DataSet xmlns="http://www.bnr.ro/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <Body>
        <Subject>Reference rates</Subject>
        <PublishingDate>2024-01-15</PublishingDate>
        <Cube>
            <Rate currency="USD" multiplier="1">4.9250</Rate>
            <Rate currency="EUR" multiplier="1">5.3500</Rate>
            <Rate currency="GBP" multiplier="1">6.2100</Rate>
        </Cube>
    </Body>
</DataSet>"""
    
    def test_parse_xml(self, bnr_service, sample_xml):
        """Test XML parsing functionality"""
        rates = bnr_service._parse_xml(sample_xml)
        
        assert len(rates) == 3
        assert "USD" in rates
        assert "EUR" in rates
        assert "GBP" in rates
        
        usd_rate = rates["USD"]
        assert usd_rate.currency == "USD"
        assert usd_rate.rate == 4.9250
        assert usd_rate.multiplier == 1
        assert usd_rate.date == "2024-01-15"
    
    @pytest.mark.asyncio
    async def test_fetch_rates_success(self, bnr_service, sample_xml):
        """Test successful rate fetching"""
        with patch('httpx.AsyncClient') as mock_client:
            mock_response = AsyncMock()
            mock_response.text = sample_xml
            mock_response.raise_for_status = AsyncMock()
            
            mock_context = AsyncMock()
            mock_context.__aenter__.return_value.get.return_value = mock_response
            mock_client.return_value = mock_context
            
            rates = await bnr_service.fetch_rates()
            
            assert len(rates) == 3
            assert "USD" in rates
            assert rates["USD"].rate == 4.9250
    
    @pytest.mark.asyncio
    async def test_fetch_rates_http_error(self, bnr_service):
        """Test rate fetching with HTTP error"""
        with patch('httpx.AsyncClient') as mock_client:
            mock_context = AsyncMock()
            mock_context.__aenter__.return_value.get.side_effect = Exception("Network error")
            mock_client.return_value = mock_context
            
            with pytest.raises(Exception):
                await bnr_service.fetch_rates()


class TestAPI:
    """Test cases for FastAPI endpoints"""
    
    @pytest.fixture
    def client(self):
        return TestClient(app)
    
    @pytest.fixture
    def mock_rates(self):
        return {
            "USD": {
                "currency": "USD",
                "rate": 4.9250,
                "multiplier": 1,
                "date": "2024-01-15"
            },
            "EUR": {
                "currency": "EUR", 
                "rate": 5.3500,
                "multiplier": 1,
                "date": "2024-01-15"
            }
        }
    
    def test_root_endpoint(self, client):
        """Test root endpoint"""
        response = client.get("/")
        assert response.status_code == 200
        assert "Welcome to CURSBNR API" in response.json()["message"]
    
    def test_health_endpoint(self, client):
        """Test health check endpoint"""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "timestamp" in data
    
    @patch('cursbnr_api.main.bnr_service.fetch_rates')
    def test_get_all_rates(self, mock_fetch, client, mock_rates):
        """Test getting all rates"""
        mock_fetch.return_value = mock_rates
        
        response = client.get("/rates")
        assert response.status_code == 200
        data = response.json()
        assert "USD" in data
        assert "EUR" in data
        assert data["USD"]["rate"] == 4.9250
    
    @patch('cursbnr_api.main.bnr_service.fetch_rates')
    def test_get_specific_currency(self, mock_fetch, client, mock_rates):
        """Test getting specific currency rate"""
        mock_fetch.return_value = mock_rates
        
        response = client.get("/rates/USD")
        assert response.status_code == 200
        data = response.json()
        assert data["currency"] == "USD"
        assert data["rate"] == 4.9250
    
    @patch('cursbnr_api.main.bnr_service.fetch_rates')
    def test_get_nonexistent_currency(self, mock_fetch, client, mock_rates):
        """Test getting non-existent currency"""
        mock_fetch.return_value = mock_rates
        
        response = client.get("/rates/JPY")
        assert response.status_code == 404
        assert "not found" in response.json()["detail"]
    
    @patch('cursbnr_api.main.bnr_service.fetch_rates')
    def test_currency_case_insensitive(self, mock_fetch, client, mock_rates):
        """Test that currency lookup is case insensitive"""
        mock_fetch.return_value = mock_rates
        
        response = client.get("/rates/usd")
        assert response.status_code == 200
        data = response.json()
        assert data["currency"] == "USD"

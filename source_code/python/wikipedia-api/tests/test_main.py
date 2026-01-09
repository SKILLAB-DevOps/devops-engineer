import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from wikipedia_api.main import app, WikipediaService


# Create test client
client = TestClient(app)


class TestWikipediaAPI:
    """Test cases for Wikipedia API endpoints"""
    
    def test_root_endpoint(self):
        """Test the root endpoint"""
        response = client.get("/")
        assert response.status_code == 200
        assert "message" in response.json()
        assert "endpoints" in response.json()
    
    def test_health_endpoint(self):
        """Test the health check endpoint"""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "timestamp" in data
        assert data["service"] == "Wikipedia API"
    
    def test_search_missing_query(self):
        """Test search endpoint with missing query parameter"""
        response = client.get("/search")
        assert response.status_code == 422  # Validation error
    
    def test_search_empty_query(self):
        """Test search endpoint with empty query"""
        response = client.get("/search?q=")
        assert response.status_code == 400
        assert "Search query cannot be empty" in response.json()["detail"]
    
    def test_article_empty_title(self):
        """Test article endpoint with empty title"""
        response = client.get("/article/ ")
        assert response.status_code == 400
        assert "Article title cannot be empty" in response.json()["detail"]
    
    @patch('wikipedia_api.main.wiki_service.search_articles')
    def test_search_success(self, mock_search):
        """Test successful search"""
        from wikipedia_api.main import WikipediaSearchResult
        
        # Mock the search results
        mock_search.return_value = [
            WikipediaSearchResult(
                title="Python (programming language)",
                page_id=23862,
                snippet="Python is a high-level programming language"
            )
        ]
        
        response = client.get("/search?q=python&limit=1")
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["title"] == "Python (programming language)"
        assert data[0]["page_id"] == 23862
    
    @patch('wikipedia_api.main.wiki_service.get_article')
    def test_get_article_success(self, mock_get_article):
        """Test successful article retrieval"""
        from wikipedia_api.main import WikipediaArticle
        
        # Mock the article data
        mock_get_article.return_value = WikipediaArticle(
            title="Python (programming language)",
            extract="Python is a high-level, interpreted programming language...",
            url="https://en.wikipedia.org/wiki/Python_(programming_language)",
            page_id=23862
        )
        
        response = client.get("/article/Python")
        assert response.status_code == 200
        data = response.json()
        assert data["title"] == "Python (programming language)"
        assert data["page_id"] == 23862
        assert "extract" in data
        assert "url" in data


class TestWikipediaService:
    """Test cases for WikipediaService"""
    
    @pytest.fixture
    def service(self):
        """Create a WikipediaService instance"""
        return WikipediaService()
    
    @pytest.mark.asyncio
    async def test_search_articles_success(self, service):
        """Test successful article search"""
        # Mock successful API response
        mock_response_data = {
            "query": {
                "search": [
                    {
                        "title": "Python (programming language)",
                        "pageid": 23862,
                        "snippet": "Python is a high-level programming language"
                    }
                ]
            }
        }
        
        with patch('httpx.AsyncClient') as mock_client:
            mock_response = AsyncMock()
            mock_response.json.return_value = mock_response_data
            mock_response.raise_for_status.return_value = None
            
            mock_client.return_value.__aenter__.return_value.get.return_value = mock_response
            
            results = await service.search_articles("python", 1)
            
            assert len(results) == 1
            assert results[0].title == "Python (programming language)"
            assert results[0].page_id == 23862
    
    @pytest.mark.asyncio
    async def test_get_article_success(self, service):
        """Test successful article retrieval"""
        # Mock successful API response
        mock_response_data = {
            "query": {
                "pages": {
                    "23862": {
                        "pageid": 23862,
                        "title": "Python (programming language)",
                        "extract": "Python is a high-level, interpreted programming language...",
                        "fullurl": "https://en.wikipedia.org/wiki/Python_(programming_language)"
                    }
                }
            }
        }
        
        with patch('httpx.AsyncClient') as mock_client:
            mock_response = AsyncMock()
            mock_response.json.return_value = mock_response_data
            mock_response.raise_for_status.return_value = None
            
            mock_client.return_value.__aenter__.return_value.get.return_value = mock_response
            
            article = await service.get_article("Python")
            
            assert article.title == "Python (programming language)"
            assert article.page_id == 23862
            assert "Python is a high-level" in article.extract
    
    @pytest.mark.asyncio
    async def test_get_article_not_found(self, service):
        """Test article not found"""
        # Mock API response for missing article
        mock_response_data = {
            "query": {
                "pages": {
                    "-1": {
                        "missing": True,
                        "title": "NonExistentArticle"
                    }
                }
            }
        }
        
        with patch('httpx.AsyncClient') as mock_client:
            mock_response = AsyncMock()
            mock_response.json.return_value = mock_response_data
            mock_response.raise_for_status.return_value = None
            
            mock_client.return_value.__aenter__.return_value.get.return_value = mock_response
            
            with pytest.raises(Exception) as exc_info:
                await service.get_article("NonExistentArticle")
            
            assert "not found" in str(exc_info.value)
    
    @pytest.mark.asyncio
    async def test_search_network_error(self, service):
        """Test network error handling in search"""
        with patch('httpx.AsyncClient') as mock_client:
            mock_client.return_value.__aenter__.return_value.get.side_effect = Exception("Network error")
            
            with pytest.raises(Exception) as exc_info:
                await service.search_articles("test", 1)
            
            assert "Error processing Wikipedia data" in str(exc_info.value)

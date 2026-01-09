"""Test configuration and basic imports"""

def test_imports():
    """Test that main module can be imported"""
    try:
        from wikipedia_api.main import app, WikipediaService
        assert app is not None
        assert WikipediaService is not None
    except ImportError as e:
        assert False, f"Failed to import main module: {e}"

def test_service_initialization():
    """Test that WikipediaService can be initialized"""
    from wikipedia_api.main import WikipediaService
    
    service = WikipediaService()
    assert service.BASE_URL == "https://en.wikipedia.org/api/rest_v1"
    assert service.API_URL == "https://en.wikipedia.org/w/api.php"

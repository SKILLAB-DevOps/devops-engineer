# Wikipedia API

A simple FastAPI project that demonstrates how to build a REST API to fetch data from Wikipedia. This project is designed for educational purposes and showcases basic FastAPI concepts.

## Features

- 🔍 Search Wikipedia articles
- 📖 Fetch specific Wikipedia articles  
- 🏥 Health check endpoint
- ✅ Comprehensive test coverage
- 📝 Clean, documented code

## Project Structure

```
wikipedia-api/
├── wikipedia_api/
│   ├── __init__.py
│   └── main.py          # Main FastAPI application
├── tests/
│   ├── __init__.py
│   ├── test_main.py     # Main test suite
│   └── test_config.py   # Configuration tests
├── pyproject.toml       # Project configuration
└── README.md           # This file
```

## API Endpoints

- `GET /` - Welcome message and endpoint overview
- `GET /search?q={query}&limit={limit}` - Search Wikipedia articles
- `GET /article/{title}` - Get a specific Wikipedia article
- `GET /health` - Health check

## Installation

1. **Install the project**:
   ```bash
   pip install -e .
   ```

2. **Install development dependencies**:
   ```bash
   pip install -e ".[dev]"
   ```

## Usage

### Running the API

```bash
# Method 1: Using the installed script
wikipedia-api

# Method 2: Using Python module
python -m wikipedia_api.main

# Method 3: Using uvicorn directly
uvicorn wikipedia_api.main:app --reload
```

The API will be available at `http://localhost:8000`

### API Documentation

Once running, visit:
- `http://localhost:8000/docs` - Interactive Swagger UI
- `http://localhost:8000/redoc` - ReDoc documentation

### Example Usage

**Search for articles:**
```bash
curl "http://localhost:8000/search?q=python&limit=3"
```

**Get a specific article:**
```bash
curl "http://localhost:8000/article/Python_(programming_language)"
```

**Health check:**
```bash
curl "http://localhost:8000/health"
```

## Testing

Run the test suite:

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=wikipedia_api

# Run specific test file
pytest tests/test_main.py -v
```

## Key Learning Concepts

This project demonstrates:

1. **FastAPI Basics**: Creating a web API with automatic documentation
2. **Async Programming**: Using async/await for HTTP requests
3. **Data Models**: Using Pydantic for request/response validation
4. **Error Handling**: Proper HTTP exception handling
5. **External APIs**: Consuming third-party APIs (Wikipedia)
6. **Testing**: Unit and integration testing with pytest
7. **Project Structure**: Organizing a Python package

## Code Highlights

### Pydantic Models
```python
class WikipediaArticle(BaseModel):
    title: str
    extract: str
    url: str
    page_id: int
```

### Async Service Class
```python
class WikipediaService:
    async def get_article(self, title: str) -> WikipediaArticle:
        # Async HTTP request to Wikipedia API
        ...
```

### FastAPI Endpoints
```python
@app.get("/article/{title}", response_model=WikipediaArticle)
async def get_article(title: str):
    return await wiki_service.get_article(title)
```

## Dependencies

- **FastAPI**: Modern, fast web framework for building APIs
- **httpx**: Async HTTP client for API requests
- **uvicorn**: ASGI server for running the application
- **pydantic**: Data validation using Python type annotations
- **pytest**: Testing framework with async support

## Wikipedia API

This project uses the Wikipedia REST API and MediaWiki API:
- Search: `https://en.wikipedia.org/w/api.php`
- Articles: Wikipedia REST API v1

## Next Steps

Ideas for extending this project:
- Add caching (Redis)
- Add rate limiting
- Support multiple languages
- Add article summaries
- Implement user favorites
- Add authentication
- Deploy with Docker

## License

This project is for educational purposes.

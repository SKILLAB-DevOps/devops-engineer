# FastAPI DevOps System Information API

A modern FastAPI-based web API that provides system information endpoints, converted from the original Click CLI application.

## Features

- **System Information API**: Get CPU, memory, disk, network, swap, and sensor information via REST endpoints
- **Interactive Documentation**: Automatic OpenAPI/Swagger documentation
- **Type Safety**: Full Pydantic model validation
- **Modern Python**: Built with Python 3.10+ and latest FastAPI
- **Production Ready**: Includes proper error handling, logging, and CORS support

## API Endpoints

- `GET /` - API information and health check
- `GET /system/cpu` - CPU information and usage
- `GET /system/memory` - Memory usage statistics
- `GET /system/disk` - Disk partitions and usage
- `GET /system/network` - Network interface statistics
- `GET /system/swap` - Swap memory information
- `GET /system/sensors` - Temperature sensor data
- `GET /system/all` - Complete system information

## Quick Start

### Installation

1. Clone the repository and navigate to the project directory
2. Create a virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

3. Install dependencies:

```bash
pip install -e .
```

### Development Setup

Install development dependencies:

```bash
pip install -e ".[dev]"
```

### Running the API

#### Development Server

```bash
uvicorn src.devops_api.main:app --reload --host 0.0.0.0 --port 8000
```

#### Using the CLI command

```bash
devops-api
```

The API will be available at:
- **API**: http://localhost:8000
- **Interactive Docs (Swagger)**: http://localhost:8000/docs
- **Alternative Docs (ReDoc)**: http://localhost:8000/redoc

## Development

### Code Quality

Format code:
```bash
black src tests
```

Lint code:
```bash
ruff check src tests
```

Type checking:
```bash
mypy src tests
```

### Testing

Run tests:
```bash
pytest
```

Run tests with coverage:
```bash
pytest --cov=src --cov-report=html
```

## Docker Support

Build and run with Docker:

```bash
docker build -t fastapi-devops-api .
docker run -p 8000:8000 fastapi-devops-api
```

## Project Structure

```
fastapi-devops-api/
├── src/
│   └── devops_api/
│       ├── __init__.py
│       ├── main.py          # FastAPI application
│       ├── models.py        # Pydantic models
│       ├── services.py      # System information services
│       └── routers/
│           ├── __init__.py
│           └── system.py    # System information endpoints
├── tests/
│   ├── __init__.py
│   ├── test_main.py
│   └── test_system.py
├── pyproject.toml
├── README.md
└── Dockerfile
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

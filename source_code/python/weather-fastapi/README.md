# Weather API

A simple FastAPI application that fetches weather data for any location.

## Installation with uv

### Prerequisites

Install uv:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Setup

1. Create project directory:
```bash
mkdir weather-fastapi && cd weather-fastapi
```

2. Create virtual environment:
```bash
uv venv
source .venv/bin/activate
```

3. Install dependencies:
```bash
uv add fastapi uvicorn httpx
```

## Running the Application

```bash
uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## API Endpoints

- `GET /` - Root endpoint
- `GET /health` - Health check
- `GET /weather/{location}` - Get weather for location

## Example Usage

```bash
curl http://localhost:8000/weather/London
```
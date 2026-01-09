# CURSBNR FastAPI Project

A simple FastAPI project that fetches and serves Romanian National Bank (BNR) exchange rates.

## Features

- Fetch current exchange rates from BNR
- Get specific currency exchange rate
- Simple REST API endpoints
- Async/await implementation
- Comprehensive tests

## Installation

```bash
pip install -e .
```

## For development:

```bash
pip install -e ".[dev]"
```

## Running the application

```bash
uvicorn cursbnr_api.main:app --reload
```

The API will be available at `http://localhost:8000`

## API Endpoints

- `GET /` - Welcome message
- `GET /rates` - Get all current exchange rates
- `GET /rates/{currency}` - Get specific currency rate (e.g., USD, EUR)

## Testing

```bash
pytest
```

## Example Usage

```bash
# Get all rates
curl http://localhost:8000/rates

# Get USD rate
curl http://localhost:8000/rates/USD
```

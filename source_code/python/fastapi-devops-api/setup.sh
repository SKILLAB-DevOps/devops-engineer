#!/bin/bash

# FastAPI DevOps API - Setup Script
# This script helps set up the development environment

set -e

PROJECT_DIR="/home/devx/sandbox/devops/fastapi-devops-api"
VENV_DIR="$PROJECT_DIR/.venv"

echo "=== FastAPI DevOps System Information API Setup ==="
echo ""

# Check if we're in the right directory
if [[ ! -f "$PROJECT_DIR/pyproject.toml" ]]; then
    echo "❌ Error: pyproject.toml not found. Are you in the right directory?"
    exit 1
fi

cd "$PROJECT_DIR"

# Create virtual environment
echo "1. Creating virtual environment..."
if [[ ! -d "$VENV_DIR" ]]; then
    python3 -m venv "$VENV_DIR"
    echo "✅ Virtual environment created at $VENV_DIR"
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment
echo ""
echo "2. Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Upgrade pip
echo ""
echo "3. Upgrading pip..."
pip install --upgrade pip

# Install the package and dependencies
echo ""
echo "4. Installing package and dependencies..."
pip install -e ".[dev]"

echo ""
echo "✅ Setup completed successfully!"
echo ""
echo "=== Next Steps ==="
echo "1. Activate the virtual environment:"
echo "   source .venv/bin/activate"
echo ""
echo "2. Start the API server:"
echo "   devops-api"
echo "   # or"
echo "   uvicorn src.devops_api.main:app --reload"
echo ""
echo "3. Open your browser to:"
echo "   http://localhost:8000/docs (Interactive API documentation)"
echo "   http://localhost:8000/ (API info)"
echo ""
echo "4. Run tests:"
echo "   pytest"
echo ""
echo "5. Test the API:"
echo "   ./examples/test_api.sh"
echo ""
echo "6. Try the example client:"
echo "   python examples/api_client_example.py"
echo ""
echo "=== Development Commands ==="
echo "Format code:    black src tests"
echo "Lint code:      ruff check src tests"
echo "Type check:     mypy src tests"
echo "Run tests:      pytest -v --cov=src"
echo ""

# Create new project
mkdir weather-cli && cd weather-cli

# Initialize with uv (fast package manager)
uv init --app

# Add dependencies
uv add click rich requests

# Add development dependencies
uv add --dev pytest pytest-cov ruff mypy bandit pre-commit

# Install pre-commit hooks
uv run pre-commit install

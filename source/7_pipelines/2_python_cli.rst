###############
Python CLI Apps
###############

Build production-ready command-line applications with modern Python tools and comprehensive CI/CD pipelines.

============================
Modern CLI Development Stack
============================

**Essential Tools (2024):**

- **uv** - Ultra-fast package manager (10-100x faster than pip)
- **Typer** - Modern CLI framework with type hints and auto-validation
- **Rich** - Beautiful terminal output with colors and formatting  
- **pytest** - Comprehensive testing with fixtures and coverage
- **ruff** - Fast linting and formatting (replaces flake8/black/isort)
- **mypy** - Static type checking for catching bugs early

======================
Production CLI Example
======================

**Complete Weather CLI Application:**

.. literalinclude:: ../../source_code/pipelines/advanced/weather_cli.py
   :language: python
   :lines: 1-50
   :caption: Professional CLI with Typer, Rich, and proper error handling

**Project Setup:**

.. code-block:: bash

   # Initialize project with modern tooling
   uv init weather-cli --python 3.12
   cd weather-cli
   
   # Add dependencies
   uv add typer rich requests pydantic
   uv add --dev pytest pytest-cov ruff mypy bandit

**Modern Project Structure:**

.. code-block:: text

   weather-cli/
   ├── src/weather_cli/          # Source code (src layout)
   │   ├── __init__.py
   │   ├── main.py              # CLI entry point
   │   └── weather.py           # Core logic
   ├── tests/                   # Test suite
   ├── .github/workflows/       # CI/CD pipelines
   ├── pyproject.toml          # All configuration
   └── uv.lock                 # Dependency lockfile

===========================
Key Implementation Features
===========================

**Type-Safe CLI with Typer:**

.. code-block:: python

   from enum import Enum
   import typer
   from rich.console import Console

   class Units(str, Enum):
       celsius = "celsius"
       fahrenheit = "fahrenheit"

   @app.command()
   def current(
       city: str = typer.Argument(..., help="City name"),
       units: Units = typer.Option(Units.celsius),
       debug: bool = typer.Option(False)
   ) -> None:
       """Get current weather with type validation."""

**Error Handling Pattern:**

.. code-block:: python

   try:
       weather_data = service.get_current_weather(city)
   except WeatherError as e:
       console.print(f"❌ {e}", style="red")
       raise typer.Exit(1)  # Proper exit codes

=====================
Comprehensive Testing
=====================

**CLI Testing with Typer and pytest:**

.. literalinclude:: ../../source_code/pipelines/examples/test_comprehensive.py
   :language: python
   :lines: 150-200
   :caption: CLI testing patterns with mocking and fixtures

**Key Testing Patterns:**

- **CLI Runner** - Simulate command execution without subprocess overhead
- **Mock external APIs** - Isolate CLI logic from network dependencies  
- **Parameterized tests** - Test multiple scenarios efficiently
- **Fixture-based setup** - Reusable test data and configurations
- **Output validation** - Test both content and formatting

=========================
Production CI/CD Pipeline  
=========================

**Multi-Stage Pipeline with Security:**

.. literalinclude:: ../../source_code/pipelines/advanced/production_ci_cd.yml
   :language: yaml
   :lines: 10-60
   :caption: Complete pipeline with quality gates, testing, and security

**Pipeline Stages:**

1. **Quality checks** - Fast linting, formatting, type checking (<2 minutes)
2. **Matrix testing** - Python 3.11, 3.12, 3.13 across platforms  
3. **Security scanning** - Vulnerability detection with bandit and safety
4. **Package building** - Wheel and source distribution creation
5. **Deployment** - Staging and production environment promotion

======================
Automated Distribution
======================

**PyPI Release Pipeline:**

.. code-block:: yaml

   # Automated release on version tags
   on:
     push:
       tags: ['v*']
   
   jobs:
     release:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: astral-sh/setup-uv@v3
         - run: uv build
         - uses: pypa/gh-action-pypi-publish@release/v1

**User Installation:**

.. code-block:: bash

   # Install from PyPI
   pip install weather-cli
   
   # Use immediately 
   weather current London --units celsius

=================
Complete Examples
=================

**Full Source Code Available:**

- ``source_code/pipelines/advanced/weather_cli.py`` - Complete CLI implementation
- ``source_code/pipelines/templates/pyproject.toml`` - Modern project configuration
- ``source_code/pipelines/examples/test_comprehensive.py`` - Testing patterns
- ``source_code/pipelines/advanced/production_ci_cd.yml`` - Production pipeline

**Key Patterns:**

- Type-safe CLI interfaces with Typer
- Professional error handling and user experience  
- Comprehensive testing with mocking and fixtures
- Multi-stage CI/CD with security and deployment
- Modern Python tooling (uv, ruff, mypy, bandit)


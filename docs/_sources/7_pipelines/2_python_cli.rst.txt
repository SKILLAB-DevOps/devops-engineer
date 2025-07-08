##############
7.2 Python CLI
##############

**From Scripts to Production Tools**

In the previous section, you built your first pipeline with a simple Python script. Now we'll take it to the next level: creating a professional-grade Command Line Interface (CLI) application that demonstrates real-world CI/CD patterns.

Why focus on CLI applications? They're everywhere in the DevOps ecosystem - from `kubectl` managing Kubernetes clusters to `aws` controlling cloud resources. More importantly, CLI applications showcase many of the same patterns you'll use for web applications, microservices, and data pipelines.

===================
Learning Objectives
===================

By the end of this section, you will:

• **Understand** why CLI applications are fundamental to DevOps workflows
• **Build** a production-ready Python CLI using modern tools and practices
• **Implement** comprehensive testing strategies that work for any application type
• **Create** CI/CD pipelines with advanced features like database integration and secret management
• **Package** and distribute your application automatically through the pipeline
• **Apply** security best practices that scale to enterprise environments

**Prerequisites:** Completed "Getting Started" section, basic Python knowledge, understanding of command-line interfaces

**What You'll Build:** A weather CLI application that demonstrates API integration, configuration management, error handling, and user experience design - all the patterns you need for production software.

===========================
Why Build CLI Applications?
===========================

**The Command Line Renaissance**

Despite the rise of web interfaces and mobile apps, command-line tools have experienced a renaissance in the past decade. Every major cloud platform, container orchestrator, and development tool provides a CLI as their primary interface. Understanding why reveals important principles about tool design and user experience.

**CLI Applications Are Everywhere in DevOps:**

• **Infrastructure Management**: `terraform`, `pulumi`, `ansible` for infrastructure as code
• **Container Orchestration**: `docker`, `kubectl`, `helm` for container management
• **Cloud Platforms**: `aws`, `gcloud`, `az` for cloud resource management
• **Development Tools**: `git`, `npm`, `pip`, `uv` for development workflows
• **Monitoring & Debugging**: `curl`, `jq`, `grep`, `awk` for system analysis

**Why CLI Tools Excel:**

**Automation-First Design**
    GUIs require human interaction; CLIs are designed for both humans and scripts. This dual nature makes them perfect for DevOps workflows where automation is key.

**Composability** 
    CLI tools follow the Unix philosophy: do one thing well and work with other tools. You can pipe, chain, and combine them in ways GUI tools can't match.

**Performance and Efficiency**
    No GUI overhead means CLI tools start instantly and consume minimal resources. For power users, keyboard-driven interfaces are often faster than mouse-driven ones.

**Remote-Friendly**
    SSH sessions, CI/CD pipelines, and container environments all favor text-based interfaces over graphical ones.

**Version Control Integration**
    CLI tools naturally produce text output that can be versioned, compared, and automated. Try version-controlling a GUI screenshot!

**Real-World Impact Examples:**

• **Netflix**: Uses custom CLI tools to manage deployments across 1000+ microservices
• **Spotify**: Built CLI tools that enable engineers to provision and deploy services in minutes instead of days
• **HashiCorp**: Terraform's CLI interface has become the standard for infrastructure automation

.. note::

    **Modern CLI Design Philosophy**: Today's best CLI tools are discoverable (excellent help systems), composable (work well with pipes and scripts), and provide immediate feedback (progress bars, colored output, clear error messages).

====================================
Modern Python CLI Development Stack
====================================

**The Tools That Matter in 2024**

Python CLI development has been transformed by modern tooling that makes development faster, more reliable, and more enjoyable. Here's the stack we'll use and why each tool matters:

**Project Management: UV**
    *Why not pip?* UV is 10-100x faster than pip, provides deterministic dependency resolution, and handles virtual environments seamlessly. It's quickly becoming the Python community standard.

**CLI Framework: Click**
    *Why not argparse?* Click provides automatic help generation, type validation, command grouping, and a decorator-based syntax that's both powerful and readable.

**Testing: pytest + coverage**
    *Why not unittest?* pytest's fixture system, parametrized tests, and plugin ecosystem make testing CLI applications much more straightforward.

**Code Quality: ruff + mypy**
    *Why this combination?* ruff replaces multiple tools (flake8, black, isort) with a single, extremely fast tool. mypy adds type safety that catches bugs before they reach users.

**Security: bandit + safety**
    *Why essential?* CLI tools often handle sensitive data and run with elevated privileges. Security scanning catches common vulnerabilities early.

======================
Building a Weather CLI
======================

**Project Design Decisions**

Instead of another "todo list" example, we'll build a weather CLI that demonstrates real-world patterns:

• **API Integration**: Calling external services with error handling
• **Configuration Management**: Handling user settings and API keys
• **Data Validation**: Processing and validating external data
• **User Experience**: Progress indicators, colored output, helpful errors
• **Testing Challenges**: Mocking external services, testing CLI interactions

**Project Structure (Modern src/ Layout)**

.. code-block:: text

    weather-cli/
    ├── .github/workflows/          # CI/CD configuration
    │   ├── ci.yml                 # Continuous integration
    │   └── release.yml            # Automated releases
    ├── src/
    │   └── weather_cli/           # Source code (note src/ layout)
    │       ├── __init__.py
    │       ├── main.py            # CLI entry point
    │       ├── weather.py         # Core weather logic
    │       └── config.py          # Configuration management
    ├── tests/                     # Test files
    │   ├── __init__.py
    │   ├── test_weather.py
    │   └── conftest.py           # pytest configuration
    ├── pyproject.toml            # Project configuration
    ├── uv.lock                   # Dependency lock file
    ├── README.md
    └── .gitignore

**Why the src/ layout?** This structure prevents accidentally importing from your source directory during testing, forces proper package installation, and mirrors the structure that users will see when they install your package.

**Quick Setup with Modern Tools**

.. code-block:: bash

    # Create project directory
    mkdir weather-cli && cd weather-cli
    
    # Initialize with uv (the modern Python package manager)
    uv init --app --python 3.12
    
    # Add runtime dependencies
    uv add click rich requests
    
    # Add development dependencies
    uv add --dev pytest pytest-cov ruff mypy bandit safety

**Project Configuration (pyproject.toml)**

This single file replaces setup.py, requirements.txt, and multiple configuration files:

.. code-block:: toml

    [build-system]
    requires = ["hatchling"]
    build-backend = "hatchling.build"

    [project]
    name = "weather-cli"
    version = "0.1.0"
    description = "A modern weather CLI demonstration"
    authors = [{name = "Your Name", email = "your.email@example.com"}]
    readme = "README.md"
    requires-python = ">=3.10"
    dependencies = [
        "click>=8.0.0",
        "rich>=13.0.0",    # Beautiful terminal output
        "requests>=2.28.0", # HTTP client
    ]

    [project.optional-dependencies]
    dev = [
        "pytest>=7.0.0",
        "pytest-cov>=4.0.0",
        "ruff>=0.1.0",
        "mypy>=1.5.0",
        "bandit>=1.7.0",
        "safety>=2.0.0",
    ]

    [project.scripts]
    weather = "weather_cli.main:cli"  # Makes 'weather' command available

    # Tool configurations in one place
    [tool.ruff]
    target-version = "py310"
    line-length = 88
    src = ["src"]

    [tool.ruff.lint]
    select = ["E", "W", "F", "I", "N", "UP", "B", "C4"]

    [tool.mypy]
    python_version = "3.10"
    strict = true
    files = ["src", "tests"]

    [tool.pytest.ini_options]
    testpaths = ["tests"]
    addopts = ["--strict-markers", "--strict-config", "--cov=src"]

================================
Core Application Implementation
================================

**main.py: The CLI Entry Point**

.. code-block:: python

    """Weather CLI - Professional command-line weather application."""
    import click
    from rich.console import Console
    from .weather import WeatherService, WeatherError

    console = Console()

    @click.group()
    @click.version_option()
    @click.option('--debug', is_flag=True, help='Enable debug mode')
    @click.pass_context
    def cli(ctx: click.Context, debug: bool) -> None:
        """🌤️  Weather CLI - Get weather information from the command line."""
        ctx.ensure_object(dict)
        ctx.obj['debug'] = debug
        if debug:
            console.print("🐛 Debug mode enabled", style="yellow")

    @cli.command()
    @click.argument('city')
    @click.option('--units', type=click.Choice(['celsius', 'fahrenheit']), 
                  default='celsius', help='Temperature units')
    @click.option('--format', 'output_format', type=click.Choice(['table', 'json']),
                  default='table', help='Output format')
    @click.pass_context
    def current(ctx: click.Context, city: str, units: str, output_format: str) -> None:
        """Get current weather for a city."""
        try:
            weather_service = WeatherService(debug=ctx.obj['debug'])
            weather_data = weather_service.get_current_weather(city, units)
            
            if output_format == 'json':
                console.print_json(data=weather_data)
            else:
                _display_weather_table(weather_data)
                
        except WeatherError as e:
            console.print(f"❌ {e}", style="red")
            raise click.Abort()

    def _display_weather_table(weather_data: dict) -> None:
        """Display weather data in a beautiful table format."""
        from rich.table import Table
        
        table = Table(title=f"Weather in {weather_data['city']}")
        table.add_column("Property", style="cyan")
        table.add_column("Value", style="yellow")
        
        table.add_row("Temperature", f"{weather_data['temperature']}°{weather_data['unit']}")
        table.add_row("Conditions", weather_data['conditions'])
        table.add_row("Humidity", f"{weather_data['humidity']}%")
        
        console.print(table)

    if __name__ == "__main__":
        cli()

**Why this structure works:**

• **Clear separation of concerns**: CLI logic separate from business logic
• **Rich output**: Beautiful tables and colored text improve user experience
• **Error handling**: Graceful error messages instead of stack traces
• **Testability**: Each function has a single responsibility
• **Professional UX**: Progress indicators, helpful messages, consistent formatting

=============================
Testing Strategy for CLI Apps
=============================

**Why CLI Testing is Different**

CLI applications present unique testing challenges compared to web applications or libraries:

• **User interaction simulation**: You need to test command-line arguments, options, and user input
• **Output validation**: Testing both the content and format of terminal output
• **Error handling**: Ensuring helpful error messages appear under various failure conditions
• **Environment dependency**: CLI tools often depend on environment variables, file systems, and external services

**The Testing Pyramid for CLI Applications**

.. code-block:: python

    # tests/test_weather.py - Example test structure
    """Comprehensive tests for the weather CLI."""
    import pytest
    from click.testing import CliRunner
    from unittest.mock import Mock, patch
    from weather_cli.main import cli

    @pytest.fixture
    def runner():
        """Provide a CLI runner for testing."""
        return CliRunner()

    # Unit tests: Fast, focused, isolated
    def test_cli_help_message(runner):
        """Test that CLI shows helpful usage information."""
        result = runner.invoke(cli, ["--help"])
        assert result.exit_code == 0
        assert "Weather CLI" in result.output
        assert "Get weather information" in result.output

    # Integration tests: Test with mocked external services
    @patch('weather_cli.weather.requests.get')
    def test_weather_command_success(mock_get, runner):
        """Test successful weather retrieval."""
        # Mock API response
        mock_response = Mock()
        mock_response.json.return_value = {
            "main": {"temp": 20, "humidity": 65},
            "weather": [{"description": "sunny"}]
        }
        mock_get.return_value = mock_response
        
        result = runner.invoke(cli, ["current", "London"])
        assert result.exit_code == 0
        assert "London" in result.output
        assert "20°" in result.output

    # Error handling tests: Ensure graceful failure
    def test_weather_command_invalid_city(runner):
        """Test error handling for invalid city names."""
        with patch('weather_cli.weather.requests.get') as mock_get:
            mock_get.side_effect = requests.exceptions.HTTPError("City not found")
            
            result = runner.invoke(cli, ["current", "InvalidCityName"])
            assert result.exit_code != 0
            assert "❌" in result.output  # Error indicator

**Key Testing Principles:**

1. **Use Click's testing utilities**: The `CliRunner` simulates command-line execution
2. **Mock external dependencies**: Don't make real API calls in tests
3. **Test both success and failure paths**: Error handling is as important as happy paths
4. **Validate output format**: Ensure your CLI produces the expected user experience

===============================
Production-Ready CI/CD Pipeline
===============================

**Beyond Basic Testing**

Now let's create a CI/CD pipeline that handles the complexities of a real application:

.. code-block:: yaml

    # .github/workflows/ci.yml
    name: Weather CLI CI/CD
    
    on:
      push:
        branches: [ main, develop ]
      pull_request:
        branches: [ main ]
      
    jobs:
      # Quality checks run first for fast feedback
      quality:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          
          - name: Set up Python
            uses: actions/setup-python@v5
            with:
              python-version: "3.12"
          
          - name: Install uv
            uses: astral-sh/setup-uv@v3
          
          - name: Install dependencies
            run: uv sync --dev
          
          # Fast checks first
          - name: Code formatting
            run: uv run ruff format --check .
            
          - name: Linting
            run: uv run ruff check .
            
          - name: Type checking
            run: uv run mypy src/
      
      # Comprehensive testing
      test:
        needs: quality
        runs-on: ubuntu-latest
        strategy:
          matrix:
            python-version: ["3.11", "3.12", "3.13"]
        
        steps:
          - uses: actions/checkout@v4
          
          - name: Set up Python ${{ matrix.python-version }}
            uses: actions/setup-python@v5
            with:
              python-version: ${{ matrix.python-version }}
          
          - name: Install uv
            uses: astral-sh/setup-uv@v3
            
          - name: Install dependencies
            run: uv sync --dev
          
          - name: Run tests with coverage
            run: |
              uv run pytest --cov=src --cov-report=xml --cov-report=term-missing
          
          - name: Upload coverage to Codecov
            uses: codecov/codecov-action@v4
            with:
              file: ./coverage.xml
      
      # Security scanning
      security:
        needs: quality
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          
          - name: Set up Python
            uses: actions/setup-python@v5
            with:
              python-version: "3.12"
          
          - name: Install uv
            uses: astral-sh/setup-uv@v3
          
          - name: Install dependencies
            run: uv sync --dev
          
          - name: Security audit
            run: |
              uv run safety check
              uv run bandit -r src/

**What Makes This Pipeline Production-Ready:**

• **Multi-stage validation**: Quality checks → Testing → Security scanning
• **Matrix testing**: Ensures compatibility across Python versions
• **Fast feedback**: Developers get linting results in <2 minutes
• **Comprehensive coverage**: Code coverage tracking and security auditing
• **Dependency caching**: UV's built-in caching speeds up subsequent runs

========================
Distribution and Release
========================

**Automated Package Distribution**

Modern Python applications should be easy to install and update. Here's how to automate the entire release process:

.. code-block:: yaml

    # .github/workflows/release.yml
    name: Release
    
    on:
      push:
        tags: [ 'v*' ]  # Trigger on version tags like v1.0.0
    
    jobs:
      # Run full CI first
      test:
        uses: ./.github/workflows/ci.yml
      
      # Build and publish to PyPI
      release:
        needs: test
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          
          - name: Set up Python
            uses: actions/setup-python@v5
            with:
              python-version: "3.12"
          
          - name: Install uv
            uses: astral-sh/setup-uv@v3
          
          - name: Build package
            run: uv build
          
          - name: Publish to PyPI
            uses: pypa/gh-action-pypi-publish@release/v1
            with:
              password: ${{ secrets.PYPI_API_TOKEN }}
          
          - name: Create GitHub Release
            uses: softprops/action-gh-release@v1
            with:
              files: dist/*
              generate_release_notes: true

**Release Workflow:**

1. **Developer tags a release**: `git tag v1.0.0 && git push --tags`
2. **CI runs automatically**: Full test suite on all Python versions
3. **Package builds**: Creates wheel and source distributions
4. **PyPI publication**: Users can install with `pip install weather-cli`
5. **GitHub release**: Automatic release notes and downloadable assets

**User Installation Experience:**

.. code-block:: bash

    # Users can install your CLI with one command
    pip install weather-cli
    
    # And use it immediately
    weather current "San Francisco" --units fahrenheit

===================
Key Learning Points
===================

**What We've Demonstrated:**

1. **Modern Python tooling** accelerates development and improves reliability
2. **Proper project structure** makes applications maintainable and testable
3. **Comprehensive testing** catches issues before users encounter them
4. **Professional CI/CD** automates quality checks and releases
5. **User experience matters** even for command-line tools

**Patterns That Transfer:**

The patterns demonstrated in this CLI application apply directly to:

- **Web applications**: Same testing strategies, CI/CD structure, and security practices
- **Data pipelines**: Configuration management and error handling patterns
- **Microservices**: Packaging, distribution, and monitoring approaches
- **DevOps tools**: CLI design principles and automation workflows

**Next Steps:**

In the following section, we'll explore advanced GitHub Actions features that enable even more sophisticated automation scenarios.

.. tip::

    **Practice Suggestion:** Try building your own CLI tool for a task you do regularly. Common examples include file organization, log analysis, or interacting with APIs you use frequently. The muscle memory of building, testing, and deploying CLI tools will serve you well throughout your DevOps career.


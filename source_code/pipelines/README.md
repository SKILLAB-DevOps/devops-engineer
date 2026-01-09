# Pipeline Examples

This directory contains complete, production-ready examples referenced in the pipeline documentation.

## Directory Structure

### `/basic/`
Simple examples for getting started:
- `hello_world.py` - Minimal Python script for first pipeline
- `ci.yml` - Basic GitHub Actions workflow

### `/python-cli/`
Complete CLI application example:
- `pyproject.toml` - Modern Python project configuration
- `src/weather_cli/` - Source code using Typer framework
- Demonstrates testing, packaging, and distribution

### `/workflows/`
Production-ready GitHub Actions workflows:
- `ci.yml` - Comprehensive CI pipeline with quality checks, testing, and security
- `cd.yml` - Complete deployment pipeline with staging and production environments

## Usage

These examples are designed to be:
1. **Copy-paste ready** - Use them as starting points for your projects
2. **Educational** - Each file includes detailed comments explaining purpose
3. **Production-proven** - Based on patterns used by successful teams

## Getting Started

1. **Beginners**: Start with `/basic/` examples
2. **CLI Development**: Explore `/python-cli/` for modern Python CLI patterns
3. **Production Deployments**: Study `/workflows/` for enterprise-grade pipelines

## Key Technologies Demonstrated

- **Modern Python tooling**: uv, ruff, mypy, bandit
- **CLI frameworks**: Typer with Rich for beautiful output
- **Testing**: pytest with coverage reporting
- **Security**: Dependency scanning, static analysis
- **Deployment**: Multi-environment strategies with approval gates
- **Monitoring**: Pipeline metrics and health checks

## Best Practices Highlighted

- Type-safe code using Python type hints
- Comprehensive testing strategies (unit, integration, security)
- Modern dependency management with uv
- Production-ready error handling and user experience
- Security-first approach with automated scanning
- Infrastructure integration patterns
- Compliance and audit trail capabilities

Each example includes detailed comments explaining the "why" behind implementation decisions, making them valuable learning resources beyond just code templates.
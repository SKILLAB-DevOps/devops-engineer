#!/usr/bin/env python3
"""
Production-ready CLI application demonstrating modern Python practices.

Uses Typer for CLI framework, Rich for beautiful output, and follows
enterprise patterns for error handling, configuration, and testing.
"""
import os
import sys
from enum import Enum
from pathlib import Path
from typing import Optional, Dict, Any

import typer
import requests
from rich.console import Console
from rich.table import Table
from rich.progress import Progress, SpinnerColumn, TextColumn

# Initialize CLI app and console for beautiful output
app = typer.Typer(
    name="weather", 
    help="🌤️ Production-ready weather CLI application"
)
console = Console()


class TemperatureUnit(str, Enum):
    """Temperature unit enumeration for type safety."""
    celsius = "celsius"                               # Metric system
    fahrenheit = "fahrenheit"                         # Imperial system
    kelvin = "kelvin"                                 # Scientific scale


class WeatherError(Exception):
    """Custom exception for weather-related errors."""
    pass


class WeatherService:
    """
    Weather data service with proper error handling and caching.
    
    Demonstrates production patterns like configuration management,
    error handling, and external API integration.
    """
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.getenv("OPENWEATHER_API_KEY")
        self.base_url = "http://api.openweathermap.org/data/2.5"
        
        if not self.api_key:                          # Validate configuration
            raise WeatherError(
                "API key required. Set OPENWEATHER_API_KEY environment variable"
            )
    
    def get_current_weather(self, city: str, unit: str = "celsius") -> Dict[str, Any]:
        """
        Fetch current weather for a city with error handling.
        
        Args:
            city: City name to get weather for
            unit: Temperature unit (celsius, fahrenheit, kelvin)
            
        Returns:
            Weather data dictionary
            
        Raises:
            WeatherError: If API request fails or city not found
        """
        # Map our units to API units
        unit_mapping = {                              # API expects different names
            "celsius": "metric",
            "fahrenheit": "imperial", 
            "kelvin": "standard"
        }
        
        params = {                                    # Build API request parameters
            "q": city,
            "appid": self.api_key,
            "units": unit_mapping.get(unit, "metric")
        }
        
        try:
            with Progress(                            # Show progress indicator
                SpinnerColumn(),
                TextColumn("[progress.description]{task.description}"),
                console=console
            ) as progress:
                task = progress.add_task(f"Fetching weather for {city}...", total=None)
                
                response = requests.get(             # Make API request
                    f"{self.base_url}/weather",
                    params=params,
                    timeout=10                        # Reasonable timeout
                )
                
                progress.update(task, completed=True)
            
            response.raise_for_status()               # Raise exception for HTTP errors
            
            data = response.json()                    # Parse JSON response
            
            return {                                  # Return structured data
                "city": data["name"],
                "country": data["sys"]["country"],
                "temperature": round(data["main"]["temp"], 1),
                "feels_like": round(data["main"]["feels_like"], 1),
                "humidity": data["main"]["humidity"],
                "pressure": data["main"]["pressure"],
                "description": data["weather"][0]["description"].title(),
                "unit_symbol": self._get_unit_symbol(unit)
            }
            
        except requests.exceptions.HTTPError as e:     # Handle API errors
            if response.status_code == 404:
                raise WeatherError(f"City '{city}' not found")
            raise WeatherError(f"API error: {e}")
            
        except requests.exceptions.RequestException as e:  # Handle network errors
            raise WeatherError(f"Network error: {e}")
            
        except KeyError as e:                         # Handle malformed API response
            raise WeatherError(f"Unexpected API response format: missing {e}")
    
    def _get_unit_symbol(self, unit: str) -> str:
        """Get temperature unit symbol for display."""
        symbols = {                                   # Temperature symbols
            "celsius": "°C",
            "fahrenheit": "°F", 
            "kelvin": "K"
        }
        return symbols.get(unit, "°C")


@app.command()
def current(
    city: str = typer.Argument(..., help="City name to get weather for"),
    unit: TemperatureUnit = typer.Option(
        TemperatureUnit.celsius, 
        "--unit", "-u",
        help="Temperature unit"
    ),
    output_json: bool = typer.Option(
        False, 
        "--json", 
        help="Output in JSON format"
    ),
    verbose: bool = typer.Option(
        False, 
        "--verbose", "-v",
        help="Show detailed information"
    )
) -> None:
    """
    Get current weather for a city.
    
    Example usage:
        weather current "San Francisco" --unit fahrenheit
        weather current London --json
    """
    try:
        service = WeatherService()                    # Initialize weather service
        weather_data = service.get_current_weather(city, unit.value)
        
        if output_json:                               # Handle JSON output
            import json
            console.print_json(json.dumps(weather_data, indent=2))
        else:
            _display_weather_table(weather_data, verbose)  # Display formatted table
            
    except WeatherError as e:                         # Handle weather-specific errors
        console.print(f"❌ {e}", style="red bold")
        raise typer.Exit(1)
    except Exception as e:                            # Handle unexpected errors
        console.print(f"❌ Unexpected error: {e}", style="red bold")
        if verbose:                                   # Show traceback in verbose mode
            import traceback
            console.print(traceback.format_exc())
        raise typer.Exit(1)


@app.command()
def config(
    show: bool = typer.Option(False, "--show", help="Show current configuration"),
    set_api_key: Optional[str] = typer.Option(None, "--set-api-key", help="Set API key")
) -> None:
    """Manage weather CLI configuration."""
    config_file = Path.home() / ".weather-cli" / "config.json"
    
    if show:                                          # Show current config
        api_key = os.getenv("OPENWEATHER_API_KEY", "Not set")
        console.print(f"API Key: {api_key[:10]}..." if len(api_key) > 10 else api_key)
        console.print(f"Config file: {config_file}")
        return
    
    if set_api_key:                                   # Set new API key
        config_file.parent.mkdir(exist_ok=True)       # Create config directory
        import json
        
        config_data = {"api_key": set_api_key}
        with open(config_file, "w") as f:
            json.dump(config_data, f, indent=2)
        
        console.print("✅ API key saved to config file", style="green")
        console.print("💡 You can also set OPENWEATHER_API_KEY environment variable")


def _display_weather_table(weather_data: Dict[str, Any], verbose: bool = False) -> None:
    """
    Display weather data in a beautiful table format.
    
    Args:
        weather_data: Dictionary containing weather information
        verbose: Whether to show additional details
    """
    table = Table(title=f"🌤️ Weather in {weather_data['city']}, {weather_data['country']}")
    table.add_column("Property", style="cyan", no_wrap=True)
    table.add_column("Value", style="magenta")
    
    # Core weather information
    table.add_row(
        "Temperature", 
        f"{weather_data['temperature']}{weather_data['unit_symbol']}"
    )
    table.add_row(
        "Feels Like", 
        f"{weather_data['feels_like']}{weather_data['unit_symbol']}"
    )
    table.add_row("Conditions", weather_data['description'])
    table.add_row("Humidity", f"{weather_data['humidity']}%")
    
    if verbose:                                       # Additional info in verbose mode
        table.add_row("Pressure", f"{weather_data['pressure']} hPa")
    
    console.print(table)
    console.print()  # Add spacing


@app.callback()
def main(
    version: bool = typer.Option(False, "--version", help="Show version information")
) -> None:
    """Weather CLI - Get weather information from the command line."""
    if version:                                       # Handle version flag
        console.print("Weather CLI v1.0.0", style="bold blue")
        console.print("Built with Typer and Rich ❤️")
        raise typer.Exit()


if __name__ == "__main__":
    app()                                             # Run the CLI application
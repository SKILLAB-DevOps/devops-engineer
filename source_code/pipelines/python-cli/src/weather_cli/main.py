"""Weather CLI - Professional command-line weather application."""
from enum import Enum
from typing import Optional

import typer
from rich.console import Console
from rich.table import Table
from .weather import WeatherService, WeatherError

# Create Typer app instance                    
app = typer.Typer(help="🌤️ Weather CLI - Get weather information from the command line")
console = Console()                           # Rich console for beautiful output

class Units(str, Enum):                       # Type-safe enum for units
    celsius = "celsius"
    fahrenheit = "fahrenheit"

class OutputFormat(str, Enum):                # Type-safe enum for output format
    table = "table"
    json = "json"

@app.command()
def current(
    city: str = typer.Argument(..., help="City name to get weather for"),
    units: Units = typer.Option(Units.celsius, help="Temperature units"),
    output_format: OutputFormat = typer.Option(OutputFormat.table, "--format", help="Output format"),
    debug: bool = typer.Option(False, help="Enable debug mode")
) -> None:
    """Get current weather for a city."""
    if debug:                                 # Show debug info if enabled
        console.print("🐛 Debug mode enabled", style="yellow")
        
    try:
        weather_service = WeatherService(debug=debug)
        weather_data = weather_service.get_current_weather(city, units.value)
        
        if output_format == OutputFormat.json:
            console.print_json(data=weather_data)
        else:
            _display_weather_table(weather_data)
            
    except WeatherError as e:
        console.print(f"❌ {e}", style="red")
        raise typer.Exit(1)                   # Exit with error code

def _display_weather_table(weather_data: dict) -> None:
    """Display weather data in a beautiful table format."""
    table = Table(title=f"Weather in {weather_data['city']}")
    table.add_column("Property", style="cyan")
    table.add_column("Value", style="yellow")
    
    table.add_row("Temperature", f"{weather_data['temperature']}°{weather_data['unit']}")
    table.add_row("Conditions", weather_data['conditions'])
    table.add_row("Humidity", f"{weather_data['humidity']}%")
    
    console.print(table)

if __name__ == "__main__":
    app()                                     # Run the Typer app
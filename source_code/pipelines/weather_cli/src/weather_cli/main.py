"""Weather CLI - A simple command-line weather application."""

import random
import click
from typing import Optional


@click.group()
@click.version_option()
def cli() -> None:
    """Weather CLI - Get weather information from the command line."""
    pass


@cli.command()
@click.option(
    "--length",
    "-l",
    default=10,
    help="Length of the random string",
    type=click.IntRange(1, 100),
)
@click.option("--uppercase", "-u", is_flag=True, help="Generate uppercase string")
def random_string(length: int, uppercase: bool) -> None:
    """Generate a random string of specified length."""
    import string

    chars = string.ascii_letters + string.digits
    result = "".join(random.choices(chars, k=length))

    if uppercase:
        result = result.upper()

    click.echo(f"Random string: {click.style(result, fg='green', bold=True)}")


@cli.command()
@click.argument("city")
@click.option(
    "--units",
    "-u",
    type=click.Choice(["celsius", "fahrenheit"]),
    default="celsius",
    help="Temperature units",
)
def weather(city: str, units: str) -> None:
    """Get weather information for a city (mock implementation)."""
    # Mock weather data
    temp = random.randint(-10, 35) if units == "celsius" else random.randint(14, 95)
    conditions = random.choice(["sunny", "cloudy", "rainy", "snowy"])

    unit_symbol = "°C" if units == "celsius" else "°F"

    click.echo(f"\n  Weather in {click.style(city.title(), fg='blue', bold=True)}:")
    click.echo(f"   Temperature: {click.style(f'{temp}{unit_symbol}', fg='yellow')}")
    click.echo(f"   Conditions: {click.style(conditions.title(), fg='cyan')}")


if __name__ == "__main__":
    cli()

import click
from .cmds import (
    get_cpu_info,
    get_disk_info,
    get_memory_info,
    get_network_info,
    get_swap_info,
    get_sensors_info,
)

"""Simple command line tool to extract system information."""

# def get_wrong_type() -> list:
#     return "This should have been a list"


@click.group()
def cli():
    """Simple command line tool to extract system information."""


@cli.command("cpu", short_help="Show CPU")
def cpu():
    """Shows CPU Resources."""
    click.echo(get_cpu_info())


@cli.command("disk", short_help="Show Disk")
def disk():
    """Shows Disk Status."""
    click.echo(get_disk_info())


@cli.command("memory", short_help="Show Memory")
def memory():
    """Shows Memory Status."""
    click.echo(get_memory_info())


@cli.command("network", short_help="Show Network")
def network():
    """Shows Network Status."""
    click.echo(get_network_info())


@cli.command("swap", short_help="Show Swap")
def swap():
    """Shows Swap Status."""
    click.echo(get_swap_info())


@cli.command("sensors", short_help="Show Sensors")
def sensors():
    """Shows Sensors Information."""
    click.echo(get_sensors_info())


if __name__ == "__main__":
    cli()

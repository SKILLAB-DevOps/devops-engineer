"""
Simple program that generates a random string based on the selected length.
"""

import random
import string
import click


@click.command()
@click.option("--string_length", "-l", default=10, help="Number of characters.")
def random_string(string_length=10):
    """Simple function that generates a random string based on the selected length."""
    random_str = "".join(
        random.choices(string.ascii_letters + string.digits, k=string_length)
    )
    click.echo(random_str)


if __name__ == "__main__":
    random_string()

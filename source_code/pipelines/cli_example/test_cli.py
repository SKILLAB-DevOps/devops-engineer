from click.testing import CliRunner
from cli.random_string_cli import random_string

runner = CliRunner()


def test_random_string():
    result = runner.invoke(random_string)
    assert result.exit_code == 0
    assert len(result.output.strip()) == 10


def test_20_random_string():
    result = runner.invoke(random_string, "-l", "20")
    assert result.exit_code == 2
    assert len(result.output.strip()) > 10

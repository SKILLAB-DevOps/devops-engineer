from setuptools import setup, find_packages

setup(
    name="random_string_cli",
    version="0.0.1",
    packages=find_packages(),
    install_requires=[
        "click",
    ],
    entry_points={
        "console_scripts": [
            "random_string_cli = cli.random_string_cli:random_string",
        ],
    },
)

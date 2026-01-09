from setuptools import setup, find_packages

setup(
    name="devops_cli",
    version="0.0.1",
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        "Click",
    ],
    entry_points={
        "console_scripts": [
            "devops_cli = devops_cli.devops_cli:cli",
        ],
    },
)

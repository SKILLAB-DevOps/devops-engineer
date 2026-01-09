#!/usr/bin/env python3.11
"""Functions in Python."""


def hello_world():
    """Display a simple greeting."""
    print("Hello World!")


hello_world()


def hello_name(username):
    """Display a simple greeting with a parameter."""
    print(f"Hello World {username.upper()}!")


hello_name("skillab")


# Positional arguments
def hello_name(username, email):
    """Display a simple greeting with 2 parameters."""
    print(f"Hello World {username.upper()} with {email.upper()}!")


hello_name("skillab", "admin@skillab.com")


# Keyword arguments
def hello_name(username, email):
    """Display a simple greeting with 2 parameters."""
    print(f"Hello World {username.upper()} with {email.upper()}!")


hello_name(username="skillab", email="admin@skillab.com")
hello_name(email="admin@robotdreams.com", username="robotdreams")


# Default values
def hello_name(username="skillab", email="admin@skillab.com"):
    """Display a simple greeting with 2 parameters."""
    print(f"Hello World {username.upper()} with {email.upper()}!")


hello_name(email="admin@robotdreams.com", username="robotdreams")
hello_name(username="robotdreams")
hello_name()


def hello_name(username="skillab", email="admin@skillab.com"):
    """Display a simple greeting with 2 parameters."""
    return f"Hello World {username.upper()} with {email.upper()}!"


hello_world = hello_name()
print(hello_world)

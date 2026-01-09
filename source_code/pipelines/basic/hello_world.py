#!/usr/bin/env python3
"""
Basic Python script demonstrating CI/CD pipeline testing.

This simple example shows proper function structure, error handling,
and exit codes that work well with automated testing.
"""
import sys
from typing import Optional


def greet(name: str, greeting: str = "Hello") -> str:
    """
    Generate a greeting message.
    
    Args:
        name: The name to greet
        greeting: The greeting word (default: "Hello")
        
    Returns:
        Formatted greeting string
    """
    if not name or not name.strip():                  # Validate input
        raise ValueError("Name cannot be empty")
    
    return f"{greeting}, {name.strip()}!"             # Clean and format


def main() -> int:
    """
    Main function with proper exit codes for CI/CD.
    
    Returns:
        0 for success, 1 for error (standard Unix conventions)
    """
    try:
        # Get name from command line args or use default
        name: Optional[str] = sys.argv[1] if len(sys.argv) > 1 else "World"
        
        if name is None:                              # Handle None case
            print("Error: No name provided")
            return 1
        
        message = greet(name)                         # Generate greeting
        print(message)                                # Output result
        return 0                                      # Success exit code
        
    except ValueError as e:                           # Handle validation errors
        print(f"Error: {e}", file=sys.stderr)
        return 1
    except Exception as e:                            # Handle unexpected errors
        print(f"Unexpected error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())                                  # Proper exit code handling
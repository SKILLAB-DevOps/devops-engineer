#!/usr/bin/env python3
import sys
import requests


def main():
    if len(sys.argv) != 2:
        print("Usage: python weather.py <location>")
        print("Example: python weather.py London")
        return
    
    location = sys.argv[1]
    
    url = f"https://wttr.in/{location}"
    response = requests.get(url)
    
    print(response.text)


if __name__ == "__main__":
    main()

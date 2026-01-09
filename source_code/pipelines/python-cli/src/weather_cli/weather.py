"""Weather service module for API integration."""
import requests
from typing import Dict, Any


class WeatherError(Exception):
    """Custom exception for weather-related errors."""
    pass


class WeatherService:
    """Service for fetching weather data from external APIs."""
    
    def __init__(self, debug: bool = False):
        self.debug = debug                    # Store debug flag
        # In production, use environment variables for API keys
        self.api_key = "demo_key"            # Placeholder for demo purposes
        
    def get_current_weather(self, city: str, units: str = "celsius") -> Dict[str, Any]:
        """Get current weather for a specified city."""
        if self.debug:
            print(f"Fetching weather for {city} in {units}")
            
        # Simulate API call for demo purposes
        # In production, replace with actual weather API
        mock_weather_data = {
            "city": city,
            "temperature": 22,
            "conditions": "Partly cloudy",
            "humidity": 65,
            "unit": "C" if units == "celsius" else "F"
        }
        
        # Simulate potential API errors
        if city.lower() == "invalidcity":
            raise WeatherError(f"City '{city}' not found")
            
        return mock_weather_data
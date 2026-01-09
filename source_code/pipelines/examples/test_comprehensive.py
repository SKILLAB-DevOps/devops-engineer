#!/usr/bin/env python3
"""
Comprehensive test suite demonstrating modern Python testing practices.

Shows patterns for unit tests, integration tests, fixtures, mocking,
and parametrized tests using pytest and modern tooling.
"""
import json
import pytest
import requests
from unittest.mock import Mock, patch, MagicMock
from typer.testing import CliRunner

# Import our CLI application and components
from weather_cli.main import app, WeatherService, WeatherError


class TestWeatherService:
    """
    Test suite for WeatherService class.
    
    Demonstrates unit testing with mocking, error handling,
    and comprehensive test coverage patterns.
    """
    
    def test_init_with_api_key(self):
        """Test WeatherService initialization with API key."""
        service = WeatherService(api_key="test_key")     # Create service instance
        assert service.api_key == "test_key"             # Verify API key set
        assert service.base_url == "http://api.openweathermap.org/data/2.5"  # Verify URL
    
    def test_init_without_api_key_raises_error(self):
        """Test that missing API key raises appropriate error."""
        with patch.dict('os.environ', {}, clear=True):   # Clear environment
            with pytest.raises(WeatherError) as exc_info: # Expect WeatherError
                WeatherService()
        
        assert "API key required" in str(exc_info.value) # Verify error message
    
    @patch('weather_cli.main.os.getenv')
    def test_init_with_env_api_key(self, mock_getenv):
        """Test initialization using environment variable."""
        mock_getenv.return_value = "env_api_key"         # Mock environment variable
        
        service = WeatherService()                       # Create service
        assert service.api_key == "env_api_key"          # Verify env var used
        mock_getenv.assert_called_once_with("OPENWEATHER_API_KEY")
    
    @patch('weather_cli.main.requests.get')
    def test_successful_weather_request(self, mock_get):
        """Test successful API request with proper response handling."""
        # Mock successful API response
        mock_response = Mock()                           # Create mock response
        mock_response.json.return_value = {              # Mock JSON data
            "name": "London",
            "sys": {"country": "GB"},
            "main": {
                "temp": 20.5,
                "feels_like": 22.1, 
                "humidity": 65,
                "pressure": 1013
            },
            "weather": [{"description": "clear sky"}]
        }
        mock_response.raise_for_status.return_value = None  # No HTTP errors
        mock_get.return_value = mock_response            # Return mock response
        
        service = WeatherService(api_key="test_key")     # Create service
        result = service.get_current_weather("London")   # Get weather data
        
        # Verify returned data structure
        expected = {                                     # Expected result format
            "city": "London",
            "country": "GB", 
            "temperature": 20.5,
            "feels_like": 22.1,
            "humidity": 65,
            "pressure": 1013,
            "description": "Clear Sky",
            "unit_symbol": "°C"
        }
        assert result == expected                        # Verify result matches
        
        # Verify API was called correctly
        mock_get.assert_called_once()                    # Ensure API called once
        call_args = mock_get.call_args                   # Get call arguments
        assert "q=London" in call_args[1]["params"]     # Check city parameter
        assert "appid=test_key" in call_args[1]["params"]  # Check API key
    
    @patch('weather_cli.main.requests.get')
    def test_city_not_found_error(self, mock_get):
        """Test handling of 404 error when city not found."""
        mock_response = Mock()                           # Create error response
        mock_response.status_code = 404                  # Set 404 status
        mock_response.raise_for_status.side_effect = requests.exceptions.HTTPError()
        mock_get.return_value = mock_response            # Return error response
        
        service = WeatherService(api_key="test_key")
        
        with pytest.raises(WeatherError) as exc_info:    # Expect WeatherError
            service.get_current_weather("InvalidCity")
        
        assert "City 'InvalidCity' not found" in str(exc_info.value)
    
    @patch('weather_cli.main.requests.get')
    def test_network_error_handling(self, mock_get):
        """Test handling of network connectivity errors."""
        mock_get.side_effect = requests.exceptions.ConnectionError("Network unreachable")
        
        service = WeatherService(api_key="test_key")
        
        with pytest.raises(WeatherError) as exc_info:    # Expect WeatherError
            service.get_current_weather("London")
        
        assert "Network error" in str(exc_info.value)    # Verify error type
    
    @pytest.mark.parametrize("unit,expected_symbol", [   # Test multiple units
        ("celsius", "°C"),
        ("fahrenheit", "°F"),
        ("kelvin", "K")
    ])
    def test_unit_symbols(self, unit, expected_symbol):
        """Test temperature unit symbol mapping."""
        service = WeatherService(api_key="test_key")
        symbol = service._get_unit_symbol(unit)          # Get unit symbol
        assert symbol == expected_symbol                 # Verify correct symbol


class TestCLICommands:
    """
    Test suite for CLI command interface.
    
    Demonstrates CLI testing with Typer's testing utilities,
    output validation, and error handling.
    """
    
    @pytest.fixture
    def runner(self):
        """Provide CLI test runner."""
        return CliRunner()                               # Typer's test runner
    
    def test_cli_help_command(self, runner):
        """Test that CLI shows helpful usage information."""
        result = runner.invoke(app, ["--help"])          # Invoke help command
        
        assert result.exit_code == 0                     # Successful exit
        assert "Weather CLI" in result.stdout            # App name in output
        assert "current" in result.stdout                # Command listed
        assert "config" in result.stdout                 # Config command listed
    
    def test_version_flag(self, runner):
        """Test version information display."""
        result = runner.invoke(app, ["--version"])       # Check version flag
        
        assert result.exit_code == 0                     # Successful exit
        assert "Weather CLI v1.0.0" in result.stdout    # Version displayed
    
    @patch('weather_cli.main.WeatherService')
    def test_current_command_success(self, mock_service_class, runner):
        """Test successful weather retrieval via CLI."""
        # Mock the service instance and its method
        mock_service = Mock()                            # Create mock service
        mock_service.get_current_weather.return_value = { # Mock return data
            "city": "London",
            "country": "GB",
            "temperature": 20.0,
            "feels_like": 22.0,
            "humidity": 65,
            "pressure": 1013,
            "description": "Clear Sky",
            "unit_symbol": "°C"
        }
        mock_service_class.return_value = mock_service   # Return mock instance
        
        result = runner.invoke(app, ["current", "London"])  # Run current command
        
        assert result.exit_code == 0                     # Successful execution
        assert "London" in result.stdout                 # City in output
        assert "20.0°C" in result.stdout                 # Temperature displayed
        mock_service.get_current_weather.assert_called_once_with("London", "celsius")
    
    @patch('weather_cli.main.WeatherService')
    def test_current_command_with_units(self, mock_service_class, runner):
        """Test weather command with different temperature units."""
        mock_service = Mock()
        mock_service.get_current_weather.return_value = {
            "city": "New York", 
            "country": "US",
            "temperature": 68.0,
            "feels_like": 70.0,
            "humidity": 60,
            "pressure": 1015,
            "description": "Sunny",
            "unit_symbol": "°F"
        }
        mock_service_class.return_value = mock_service
        
        # Test fahrenheit unit
        result = runner.invoke(app, [
            "current", "New York", "--unit", "fahrenheit"
        ])
        
        assert result.exit_code == 0
        assert "68.0°F" in result.stdout                 # Fahrenheit displayed
        mock_service.get_current_weather.assert_called_with("New York", "fahrenheit")
    
    @patch('weather_cli.main.WeatherService')
    def test_current_command_json_output(self, mock_service_class, runner):
        """Test JSON output format."""
        mock_service = Mock()
        weather_data = {                                 # Test data structure
            "city": "Tokyo",
            "country": "JP", 
            "temperature": 25.0,
            "feels_like": 27.0,
            "humidity": 70,
            "pressure": 1008,
            "description": "Partly Cloudy",
            "unit_symbol": "°C"
        }
        mock_service.get_current_weather.return_value = weather_data
        mock_service_class.return_value = mock_service
        
        result = runner.invoke(app, ["current", "Tokyo", "--json"])
        
        assert result.exit_code == 0                     # Successful execution
        
        # Verify JSON output can be parsed
        try:
            output_data = json.loads(result.stdout.strip())  # Parse JSON output
            assert output_data == weather_data           # Verify data matches
        except json.JSONDecodeError:
            pytest.fail("CLI output is not valid JSON")  # Fail if invalid JSON
    
    @patch('weather_cli.main.WeatherService')
    def test_current_command_error_handling(self, mock_service_class, runner):
        """Test CLI error handling for weather service errors."""
        mock_service = Mock()
        mock_service.get_current_weather.side_effect = WeatherError("City not found")
        mock_service_class.return_value = mock_service
        
        result = runner.invoke(app, ["current", "InvalidCity"])
        
        assert result.exit_code == 1                     # Error exit code
        assert "❌ City not found" in result.stdout      # Error message displayed


class TestIntegrationPatterns:
    """
    Integration tests demonstrating real API interaction patterns.
    
    These tests show how to test external service integration
    while maintaining test reliability and speed.
    """
    
    @pytest.mark.integration                           # Mark as integration test
    @pytest.mark.skipif(                              # Skip if no API key
        not pytest.importorskip("os").getenv("OPENWEATHER_API_KEY"),
        reason="API key not available"
    )
    def test_real_api_integration(self):
        """
        Test actual API integration with real service.
        
        This test requires a real API key and network connectivity.
        Use sparingly to avoid rate limits and test instability.
        """
        import os
        api_key = os.getenv("OPENWEATHER_API_KEY")      # Get real API key
        
        service = WeatherService(api_key=api_key)       # Real service instance
        result = service.get_current_weather("London") # Real API call
        
        # Verify response structure without hardcoding values
        assert isinstance(result["temperature"], (int, float))  # Numeric temp
        assert isinstance(result["city"], str)           # String city name
        assert len(result["city"]) > 0                   # Non-empty city
        assert result["unit_symbol"] in ["°C", "°F", "K"]  # Valid unit


class TestFixturesAndUtilities:
    """
    Demonstrate pytest fixtures and testing utilities.
    
    Shows patterns for test data setup, cleanup, and reusable components.
    """
    
    @pytest.fixture
    def mock_weather_data(self):
        """Fixture providing consistent test weather data."""
        return {                                         # Reusable test data
            "name": "San Francisco",
            "sys": {"country": "US"},
            "main": {
                "temp": 18.5,
                "feels_like": 19.2,
                "humidity": 75,
                "pressure": 1018
            },
            "weather": [{"description": "foggy"}]
        }
    
    @pytest.fixture
    def weather_service(self):
        """Fixture providing configured WeatherService instance."""
        return WeatherService(api_key="test_api_key")   # Test service instance
    
    def test_with_fixtures(self, weather_service, mock_weather_data):
        """Test using multiple fixtures for clean test setup."""
        with patch('weather_cli.main.requests.get') as mock_get:
            mock_response = Mock()
            mock_response.json.return_value = mock_weather_data
            mock_response.raise_for_status.return_value = None
            mock_get.return_value = mock_response
            
            result = weather_service.get_current_weather("San Francisco")
            
            assert result["city"] == "San Francisco"     # Verify city
            assert result["temperature"] == 18.5         # Verify temperature
    
    @pytest.mark.parametrize("city,expected_calls", [   # Parametrized test
        ("London", 1),
        ("Paris", 1),
        ("Tokyo", 1),
    ])
    def test_api_call_count(self, weather_service, city, expected_calls):
        """Test that API is called correct number of times."""
        with patch('weather_cli.main.requests.get') as mock_get:
            mock_response = Mock()
            mock_response.json.return_value = {          # Minimal valid response
                "name": city,
                "sys": {"country": "XX"},
                "main": {"temp": 20, "feels_like": 20, "humidity": 50, "pressure": 1000},
                "weather": [{"description": "test"}]
            }
            mock_response.raise_for_status.return_value = None
            mock_get.return_value = mock_response
            
            weather_service.get_current_weather(city)   # Make API call
            assert mock_get.call_count == expected_calls # Verify call count


# Performance and stress testing examples
class TestPerformance:
    """
    Performance testing patterns for CI/CD pipelines.
    
    Shows how to test performance characteristics and catch regressions.
    """
    
    @pytest.mark.slow                                  # Mark as slow test
    def test_response_time_benchmark(self):
        """
        Benchmark response parsing performance.
        
        Ensures our code can handle typical API response sizes efficiently.
        """
        import time
        
        # Create large mock response similar to real API
        large_response = {                              # Realistic response size
            "name": "TestCity" * 100,
            "sys": {"country": "US"},
            "main": {
                "temp": 20.0,
                "feels_like": 22.0,
                "humidity": 65,
                "pressure": 1013
            },
            "weather": [{"description": "test conditions" * 50}]
        }
        
        service = WeatherService(api_key="test_key")
        
        with patch('weather_cli.main.requests.get') as mock_get:
            mock_response = Mock()
            mock_response.json.return_value = large_response
            mock_response.raise_for_status.return_value = None
            mock_get.return_value = mock_response
            
            start_time = time.time()                     # Start timing
            service.get_current_weather("TestCity")     # Process response
            end_time = time.time()                       # End timing
            
            processing_time = end_time - start_time      # Calculate duration
            assert processing_time < 0.1                 # Should be fast (<100ms)


# Configuration for pytest
if __name__ == "__main__":
    # Run tests when script is executed directly
    pytest.main([__file__, "-v"])                       # Verbose test output
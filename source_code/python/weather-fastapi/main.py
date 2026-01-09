from fastapi import FastAPI
import httpx

app = FastAPI(title="Weather API")

@app.get("/")
async def root():
    return {"message": "Weather API is running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/weather/{location}")
async def get_weather(location: str):
    async with httpx.AsyncClient() as client:
        # Get weather data
        weather_response = await client.get(f"https://wttr.in/{location}?format=j1")
        weather_data = weather_response.json()
        
        return {
            "location": location,
            "temperature": weather_data["current_condition"][0]["temp_C"] + "°C",
            "description": weather_data["current_condition"][0]["weatherDesc"][0]["value"]
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
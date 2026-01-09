import os
import socket
from fastapi import FastAPI
import httpx

app = FastAPI(title="Weather API - Kubernetes")

@app.get("/")
async def root():
    return {
        "message": "Weather API is running on Kubernetes", 
        "pod": socket.gethostname(),
        "container_orchestration": True
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy", 
        "deployment": "kubernetes-gke",
        "pod": socket.gethostname()
    }

@app.get("/weather/{location}")
async def get_weather(location: str):
    async with httpx.AsyncClient() as client:
        # Get weather data
        weather_response = await client.get(f"https://wttr.in/{location}?format=j1")
        weather_data = weather_response.json()
        
        return {
            "location": location,
            "temperature": weather_data["current_condition"][0]["temp_C"] + "°C",
            "description": weather_data["current_condition"][0]["weatherDesc"][0]["value"],
            "deployment": "kubernetes-gke",
            "pod": socket.gethostname(),
            "namespace": os.environ.get("NAMESPACE", "default")
        }

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
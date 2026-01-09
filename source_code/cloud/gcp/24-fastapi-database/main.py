"""
FastAPI Star Wars Database Collector
Collects Star Wars data from SWAPI and stores it in Cloud SQL PostgreSQL
"""
import os
import asyncio
from datetime import datetime, timezone
from typing import List, Dict, Any, Optional
import httpx
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, DateTime, JSON, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

# Database configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://starwars:password@localhost/starwars_db")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Database Models
class StarWarsCharacter(Base):
    __tablename__ = "characters"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    height = Column(String)
    mass = Column(String)
    hair_color = Column(String)
    skin_color = Column(String)
    eye_color = Column(String)
    birth_year = Column(String)
    gender = Column(String)
    homeworld = Column(String)
    raw_data = Column(JSON)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

class StarWarsPlanet(Base):
    __tablename__ = "planets"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    rotation_period = Column(String)
    orbital_period = Column(String)
    diameter = Column(String)
    climate = Column(String)
    gravity = Column(String)
    terrain = Column(String)
    surface_water = Column(String)
    population = Column(String)
    raw_data = Column(JSON)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

class StarWarsStarship(Base):
    __tablename__ = "starships"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    model = Column(String)
    manufacturer = Column(String)
    cost_in_credits = Column(String)
    length = Column(String)
    max_atmosphering_speed = Column(String)
    crew = Column(String)
    passengers = Column(String)
    cargo_capacity = Column(String)
    consumables = Column(String)
    hyperdrive_rating = Column(String)
    mglt = Column(String)
    starship_class = Column(String)
    raw_data = Column(JSON)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

class DataCollection(Base):
    __tablename__ = "collections"
    
    id = Column(Integer, primary_key=True, index=True)
    collection_name = Column(String, nullable=False)
    endpoints_collected = Column(JSON)
    total_items = Column(Integer)
    status = Column(String, default="completed")
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    notes = Column(Text)

# Create tables
Base.metadata.create_all(bind=engine)

# Pydantic models
class CollectionResponse(BaseModel):
    collection_id: int
    collection_name: str
    total_items: int
    endpoints: List[str]
    created_at: datetime

class CharacterResponse(BaseModel):
    id: int
    name: str
    height: Optional[str]
    gender: Optional[str]
    homeworld: Optional[str]
    created_at: datetime

class PlanetResponse(BaseModel):
    id: int
    name: str
    climate: Optional[str]
    terrain: Optional[str]
    population: Optional[str]
    created_at: datetime

class StarshipResponse(BaseModel):
    id: int
    name: str
    model: Optional[str]
    manufacturer: Optional[str]
    starship_class: Optional[str]
    created_at: datetime

# FastAPI app
app = FastAPI(
    title="Star Wars Database API",
    description="Collect and store Star Wars data in PostgreSQL database",
    version="1.0.0"
)

# Dependency to get database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Star Wars API configuration
SWAPI_BASE_URL = "https://www.swapi.tech/api"

async def fetch_star_wars_endpoint(endpoint: str, max_items: int = 10) -> List[Dict[str, Any]]:
    """Fetch data from Star Wars API endpoint"""
    async with httpx.AsyncClient() as client:
        items = []
        try:
            # Get list of items
            response = await client.get(f"{SWAPI_BASE_URL}/{endpoint}")
            response.raise_for_status()
            data = response.json()
            
            # Fetch individual items
            for item in data["results"][:max_items]:
                try:
                    detail_response = await client.get(item["url"])
                    detail_response.raise_for_status()
                    detail_data = detail_response.json()
                    items.append(detail_data["result"])
                except Exception as e:
                    print(f"Error fetching {item['url']}: {e}")
                    continue
                    
        except Exception as e:
            print(f"Error fetching {endpoint}: {e}")
            
        return items

def save_characters_to_db(characters: List[Dict], db: Session) -> int:
    """Save characters to database"""
    count = 0
    for char_data in characters:
        props = char_data.get("properties", {})
        character = StarWarsCharacter(
            name=props.get("name", "Unknown"),
            height=props.get("height"),
            mass=props.get("mass"),
            hair_color=props.get("hair_color"),
            skin_color=props.get("skin_color"),
            eye_color=props.get("eye_color"),
            birth_year=props.get("birth_year"),
            gender=props.get("gender"),
            homeworld=props.get("homeworld"),
            raw_data=char_data
        )
        db.add(character)
        count += 1
    return count

def save_planets_to_db(planets: List[Dict], db: Session) -> int:
    """Save planets to database"""
    count = 0
    for planet_data in planets:
        props = planet_data.get("properties", {})
        planet = StarWarsPlanet(
            name=props.get("name", "Unknown"),
            rotation_period=props.get("rotation_period"),
            orbital_period=props.get("orbital_period"),
            diameter=props.get("diameter"),
            climate=props.get("climate"),
            gravity=props.get("gravity"),
            terrain=props.get("terrain"),
            surface_water=props.get("surface_water"),
            population=props.get("population"),
            raw_data=planet_data
        )
        db.add(planet)
        count += 1
    return count

def save_starships_to_db(starships: List[Dict], db: Session) -> int:
    """Save starships to database"""
    count = 0
    for ship_data in starships:
        props = ship_data.get("properties", {})
        starship = StarWarsStarship(
            name=props.get("name", "Unknown"),
            model=props.get("model"),
            manufacturer=props.get("manufacturer"),
            cost_in_credits=props.get("cost_in_credits"),
            length=props.get("length"),
            max_atmosphering_speed=props.get("max_atmosphering_speed"),
            crew=props.get("crew"),
            passengers=props.get("passengers"),
            cargo_capacity=props.get("cargo_capacity"),
            consumables=props.get("consumables"),
            hyperdrive_rating=props.get("hyperdrive_rating"),
            mglt=props.get("MGLT"),
            starship_class=props.get("starship_class"),
            raw_data=ship_data
        )
        db.add(starship)
        count += 1
    return count

# API Routes
@app.get("/")
async def root():
    """Welcome endpoint"""
    return {
        "message": "Star Wars Database API",
        "description": "Collect and store Star Wars data in PostgreSQL",
        "endpoints": {
            "collect": "POST /collect - Collect Star Wars data",
            "characters": "GET /characters - List characters",
            "planets": "GET /planets - List planets", 
            "starships": "GET /starships - List starships",
            "collections": "GET /collections - List data collections",
            "health": "GET /health - Health check"
        }
    }

@app.get("/health")
async def health_check(db: Session = Depends(get_db)):
    """Health check with database connectivity"""
    try:
        # Test database connection
        db.execute("SELECT 1")
        return {"status": "healthy", "database": "connected", "timestamp": datetime.now(timezone.utc)}
    except Exception as e:
        return {"status": "unhealthy", "database": "disconnected", "error": str(e)}

@app.post("/collect")
async def collect_star_wars_data(
    endpoints: List[str] = ["people", "planets", "starships"],
    max_items_per_endpoint: int = 5,
    db: Session = Depends(get_db)
) -> CollectionResponse:
    """Collect Star Wars data and store in database"""
    
    collection_name = f"collection_{datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')}"
    total_items = 0
    
    for endpoint in endpoints:
        print(f"Collecting data from {endpoint}...")
        items = await fetch_star_wars_endpoint(endpoint, max_items_per_endpoint)
        
        if endpoint == "people":
            count = save_characters_to_db(items, db)
        elif endpoint == "planets":
            count = save_planets_to_db(items, db)
        elif endpoint == "starships":
            count = save_starships_to_db(items, db)
        else:
            count = 0
            
        total_items += count
        print(f"Saved {count} items from {endpoint}")
    
    # Save collection record
    collection = DataCollection(
        collection_name=collection_name,
        endpoints_collected=endpoints,
        total_items=total_items,
        notes=f"Collected {max_items_per_endpoint} items per endpoint"
    )
    db.add(collection)
    db.commit()
    db.refresh(collection)
    
    return CollectionResponse(
        collection_id=collection.id,
        collection_name=collection_name,
        total_items=total_items,
        endpoints=endpoints,
        created_at=collection.created_at
    )

@app.get("/characters", response_model=List[CharacterResponse])
async def get_characters(limit: int = 10, db: Session = Depends(get_db)):
    """Get stored characters"""
    characters = db.query(StarWarsCharacter).order_by(StarWarsCharacter.created_at.desc()).limit(limit).all()
    return characters

@app.get("/planets", response_model=List[PlanetResponse])
async def get_planets(limit: int = 10, db: Session = Depends(get_db)):
    """Get stored planets"""
    planets = db.query(StarWarsPlanet).order_by(StarWarsPlanet.created_at.desc()).limit(limit).all()
    return planets

@app.get("/starships", response_model=List[StarshipResponse])
async def get_starships(limit: int = 10, db: Session = Depends(get_db)):
    """Get stored starships"""
    starships = db.query(StarWarsStarship).order_by(StarWarsStarship.created_at.desc()).limit(limit).all()
    return starships

@app.get("/collections", response_model=List[CollectionResponse])
async def get_collections(db: Session = Depends(get_db)):
    """Get collection history"""
    collections = db.query(DataCollection).order_by(DataCollection.created_at.desc()).limit(10).all()
    return [
        CollectionResponse(
            collection_id=col.id,
            collection_name=col.collection_name,
            total_items=col.total_items,
            endpoints=col.endpoints_collected,
            created_at=col.created_at
        ) for col in collections
    ]

@app.get("/stats")
async def get_statistics(db: Session = Depends(get_db)):
    """Get database statistics"""
    stats = {
        "characters_count": db.query(StarWarsCharacter).count(),
        "planets_count": db.query(StarWarsPlanet).count(),
        "starships_count": db.query(StarWarsStarship).count(),
        "collections_count": db.query(DataCollection).count(),
        "last_collection": None
    }
    
    last_collection = db.query(DataCollection).order_by(DataCollection.created_at.desc()).first()
    if last_collection:
        stats["last_collection"] = {
            "name": last_collection.collection_name,
            "created_at": last_collection.created_at,
            "total_items": last_collection.total_items
        }
    
    return stats

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
from datetime import datetime
from typing import Dict, Optional, List
import json

import httpx
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel


class WikipediaArticle(BaseModel):
    """Wikipedia article model"""
    title: str
    extract: str
    url: str
    page_id: int


class WikipediaSearchResult(BaseModel):
    """Wikipedia search result model"""
    title: str
    page_id: int
    snippet: str


class WikipediaService:
    """Service to fetch data from Wikipedia API"""
    
    BASE_URL = "https://en.wikipedia.org/api/rest_v1"
    API_URL = "https://en.wikipedia.org/w/api.php"
    
    async def search_articles(self, query: str, limit: int = 5) -> List[WikipediaSearchResult]:
        """Search for Wikipedia articles"""
        params = {
            "action": "query",
            "format": "json",
            "list": "search",
            "srsearch": query,
            "srlimit": limit,
            "srprop": "snippet"
        }
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(self.API_URL, params=params, timeout=10.0)
                response.raise_for_status()
                data = response.json()
                
            results = []
            for item in data.get("query", {}).get("search", []):
                results.append(WikipediaSearchResult(
                    title=item["title"],
                    page_id=item["pageid"],
                    snippet=item["snippet"]
                ))
            
            return results
            
        except httpx.RequestError as e:
            raise HTTPException(status_code=503, detail=f"Error connecting to Wikipedia: {str(e)}")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error processing Wikipedia data: {str(e)}")
    
    async def get_article(self, title: str) -> WikipediaArticle:
        """Get a specific Wikipedia article"""
        # Clean the title for URL
        clean_title = title.replace(" ", "_")
        
        # First, get the page info
        params = {
            "action": "query",
            "format": "json",
            "titles": title,
            "prop": "extracts|info",
            "exintro": True,
            "explaintext": True,
            "exsectionformat": "plain",
            "inprop": "url"
        }
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(self.API_URL, params=params, timeout=10.0)
                response.raise_for_status()
                data = response.json()
                
            pages = data.get("query", {}).get("pages", {})
            
            if not pages:
                raise HTTPException(status_code=404, detail="Article not found")
            
            # Get the first (and should be only) page
            page_data = next(iter(pages.values()))
            
            if "missing" in page_data:
                raise HTTPException(status_code=404, detail=f"Article '{title}' not found")
            
            return WikipediaArticle(
                title=page_data["title"],
                extract=page_data.get("extract", "No extract available"),
                url=page_data.get("fullurl", f"https://en.wikipedia.org/wiki/{clean_title}"),
                page_id=page_data["pageid"]
            )
            
        except httpx.RequestError as e:
            raise HTTPException(status_code=503, detail=f"Error connecting to Wikipedia: {str(e)}")
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error processing Wikipedia data: {str(e)}")


# Initialize FastAPI app
app = FastAPI(
    title="Wikipedia API",
    description="A simple API to search and fetch Wikipedia articles",
    version="0.1.0"
)

# Initialize Wikipedia service
wiki_service = WikipediaService()


@app.get("/")
async def root():
    """Welcome endpoint"""
    return {
        "message": "Welcome to Wikipedia API",
        "endpoints": {
            "search": "/search?q=query&limit=5",
            "article": "/article/{title}",
            "health": "/health"
        }
    }


@app.get("/search", response_model=List[WikipediaSearchResult])
async def search_wikipedia(
    q: str = Query(..., description="Search query"),
    limit: int = Query(default=5, ge=1, le=10, description="Number of results to return")
):
    """Search Wikipedia articles"""
    if not q.strip():
        raise HTTPException(status_code=400, detail="Search query cannot be empty")
    
    results = await wiki_service.search_articles(q, limit)
    return results


@app.get("/article/{title}", response_model=WikipediaArticle)
async def get_article(title: str):
    """Get a specific Wikipedia article"""
    if not title.strip():
        raise HTTPException(status_code=400, detail="Article title cannot be empty")
    
    article = await wiki_service.get_article(title)
    return article


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy", 
        "timestamp": datetime.now().isoformat(),
        "service": "Wikipedia API"
    }


def main():
    """Main function to run the application"""
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)


if __name__ == "__main__":
    main()

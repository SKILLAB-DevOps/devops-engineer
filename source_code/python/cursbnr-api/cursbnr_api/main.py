from datetime import datetime
from typing import Dict, Optional
import xml.etree.ElementTree as ET

import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel


class ExchangeRate(BaseModel):
    """Exchange rate model"""
    currency: str
    rate: float
    multiplier: int = 1
    date: str


class BNRService:
    """Service to fetch data from Romanian National Bank"""
    
    BNR_URL = "https://www.bnr.ro/nbrfxrates.xml"
    
    async def fetch_rates(self) -> Dict[str, ExchangeRate]:
        """Fetch exchange rates from BNR"""
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(self.BNR_URL, timeout=10.0)
                response.raise_for_status()
                
            return self._parse_xml(response.text)
        except httpx.RequestError as e:
            raise HTTPException(status_code=503, detail=f"Error fetching data from BNR: {str(e)}")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error processing BNR data: {str(e)}")
    
    def _parse_xml(self, xml_data: str) -> Dict[str, ExchangeRate]:
        """Parse XML response from BNR"""
        try:
            root = ET.fromstring(xml_data)
            
            # Find the date
            date_elem = root.find(".//PublishingDate")
            date_str = date_elem.text if date_elem is not None else datetime.now().strftime("%Y-%m-%d")
            
            rates = {}
            
            # Parse each currency rate
            for rate_elem in root.findall(".//Rate"):
                currency = rate_elem.get("currency")
                multiplier = int(rate_elem.get("multiplier", 1))
                rate_value = float(rate_elem.text)
                
                if currency:
                    rates[currency] = ExchangeRate(
                        currency=currency,
                        rate=rate_value,
                        multiplier=multiplier,
                        date=date_str
                    )
            
            return rates
        except ET.ParseError as e:
            raise HTTPException(status_code=500, detail=f"Error parsing XML: {str(e)}")


# Initialize FastAPI app
app = FastAPI(
    title="CURSBNR API",
    description="A simple API to fetch Romanian National Bank exchange rates",
    version="0.1.0"
)

# Initialize BNR service
bnr_service = BNRService()


@app.get("/")
async def root():
    """Welcome endpoint"""
    return {"message": "Welcome to CURSBNR API - Romanian National Bank Exchange Rates"}


@app.get("/rates", response_model=Dict[str, ExchangeRate])
async def get_all_rates():
    """Get all current exchange rates"""
    rates = await bnr_service.fetch_rates()
    return rates


@app.get("/rates/{currency}", response_model=ExchangeRate)
async def get_currency_rate(currency: str):
    """Get exchange rate for a specific currency"""
    currency = currency.upper()
    rates = await bnr_service.fetch_rates()
    
    if currency not in rates:
        raise HTTPException(
            status_code=404, 
            detail=f"Currency {currency} not found. Available currencies: {list(rates.keys())}"
        )
    
    return rates[currency]


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

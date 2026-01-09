"""Module docstring"""

from fastapi import FastAPI
import psycopg2

app = FastAPI()


def connect_to_database():
    """Connect to the PostgreSQL database server and fetch data"""
    try:
        # Connect to the PostgreSQL database
        connection = psycopg2.connect(
            dbname="postgres",
            user="postgres",
            password="postgres",
            host="postgres",  # Use the service name as the hostname
            port="5432",
        )

        cursor = connection.cursor()

        cursor.execute("SELECT * FROM users")

        rows = cursor.fetchall()

        return rows  # Return the fetched data as a list of tuples

    except (Exception, psycopg2.Error) as error:
        print("Error while connecting to PostgreSQL:", error)
        return []  # Return an empty list in case of an error

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


@app.get("/")
async def read_root():
    """Return service name"""
    return {"service": "backend"}


@app.get("/data")
async def read_data():
    """Return data from the database"""
    data = connect_to_database()
    return {"data": data}


@app.get("/version")
async def read_version():
    """Get version of the application"""
    return {"version": "0.0.1"}


@app.get("/healthcheck")
async def read_healthcheck():
    """Documentation for healthcheck
    if application is correct you will get ready and 200"""
    return {"status": "ready", "status_code": 200}


@app.get("/data/{name}")
async def read_data_name(name):
    """Get data from api route"""
    return {"message": f"Hello World {name}"}

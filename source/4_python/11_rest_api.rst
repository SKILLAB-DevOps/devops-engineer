#############
4.11 REST API
#############

.. note::

    REST stands for Representational State Transfer, and API stands for Application Programming Interface. REST API is a set of guidelines and conventions for building and interacting with web services. It allows different software or systems to communicate with each other over HTTP, following REST principles. In REST API, resources (like data objects or services) are identified by URLs, and can be manipulated using standard HTTP methods like GET, POST, PUT, and DELETE.

=============================
Characteristics of REST APIs:
=============================

- **Stateless**: Each request from the client to the server must contain all the information needed to understand and process the request.
- **Client-Server Architecture**: The REST API divides the system into client and server, where the client is responsible for the user interface and user experience, and the server is responsible for the back-end and data storage.
- **Resource-Based**: In REST APIs, the focus is on "resources", which are identified by URLs. These resources can be manipulated using HTTP methods.
- **Scalable**: Because of the statelessness and client-server architecture, REST APIs are highly scalable.

========
Problems
========

1. **Rate Limiting**: Many REST APIs have limits on the number of requests you can make in a given time period.

    **Solution**: Use libraries like ``ratelimiter`` to control the rate of requests.

2. **Authentication**: Secure APIs require various forms of authentication.

    **Solution**: Libraries like requests in Python make it easier to deal with authentication mechanisms like Basic Auth, OAuth, etc.

3. **Error Handling**: APIs may return various error codes, and you need to handle these gracefully in your application.

    **Solution**: Use proper exception handling to catch and respond to different HTTP error codes.

4. **Complexity and Overhead**: Dealing with raw HTTP requests and responses can be cumbersome.

    **Solution**: Use higher-level libraries that abstract away some of the complexity. Python libraries like ``requests`` are excellent for this.

5. **Data Format**: Many REST APIs return data in JSON format, but your application might need to deal with other formats like XML.

    **Solution**: Use serialization libraries like json for JSON and xml.etree.ElementTree for XML to handle data transformation.

6. **Asynchronous Calls**: For more responsive applications, you may need to make API requests asynchronously.

    **Solution**: You can use Python's asyncio library along with httpx to make asynchronous API calls.

7. **Dependency on External Services**: If the API service is down, so is the part of your application that relies on it.

    **Solution**: aImplement a fallback mechanism or caching to provide limited functionality even when the API is unavailable.

===============================================
Libraries for Working with REST APIs in Python:
===============================================

1. ``requests``: The requests library is one of the most popular Python libraries for making HTTP requests. It abstracts the complexities of making requests behind a simple API, allowing you to send HTTP/1.1 requests.

.. code-block:: python

    import requests

    response = requests.get('https://jsonplaceholder.typicode.com/todos/1')
    print(response.json())

2. ``httpx``: A fully featured HTTP client for Python 3, which supports sync and async requests.

.. code-block:: python

    import httpx

    async with httpx.AsyncClient() as client:
        response = await client.get('https://jsonplaceholder.typicode.com/todos/1')
    print(response.json())

3. ``aiohttp``: This is an asynchronous HTTP client/server framework. It is particularly useful when you need high-performance, asynchronous capabilities.

.. code-block:: python

    import aiohttp
    import asyncio

    async def fetch(session, url):
        async with session.get(url) as response:
            return await response.json()

    async def main():
        async with aiohttp.ClientSession() as session:
            response = await fetch(session, 'https://jsonplaceholder.typicode.com/todos/1')
            print(response)

    asyncio.run(main())

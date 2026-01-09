# What is NGINX and where we use it?

## eli5

Imagine you're at a super busy candy store. There's only one worker (let's call them NGINX) who has to do everything: greet customers, find out what candy they want, and then fetch it from the shelves.

Now, this worker, NGINX, is really smart and super fast. Instead of helping one customer at a time, they can listen to lots of customers all at once. They take a little note of what each customer wants, and then quickly run around the store to get all the candies. They do this so fast that it seems like they're helping everyone at the same time!

Also, NGINX knows the store really well. If they see that many people are asking for the same type of candy, they keep a secret stash right at the counter. So, the next time someone asks for that candy, they can give it to them instantly without running to the shelves.

Sometimes, if the candy isn't in their store, NGINX knows which other store has it. They quickly run to the other store, get the candy, and bring it back to the customer.

And, NGINX is also really good at organizing. They make sure that the line of customers moves smoothly so that everyone gets their candy quickly and the store doesn't become too crowded.

So, NGINX is like the superhero of the candy store, making sure everyone gets what they want quickly and efficiently!

## What is NGINX and what can do

NGINX is a powerful and versatile piece of software primarily used as a web server and as a reverse proxy. It provides various functions and features that are essential for modern web infrastructure. Here's a breakdown of its main capabilities:

Web Server: NGINX can serve web content. It's designed to handle many concurrent connections efficiently, making it particularly good for serving static content (like HTML, CSS, JavaScript files) quickly. It's known for its high performance, stability, and low resource consumption compared to some other web servers.

Reverse Proxy: As a reverse proxy, NGINX can forward requests to other servers and services. This is useful for load balancing, where traffic is distributed across multiple servers, or for providing a single entry point to a web application composed of multiple services.

Load Balancer: NGINX can distribute incoming network traffic across multiple servers. This balances the load, preventing any single server from becoming a bottleneck, which increases the reliability and efficiency of the web application.

HTTP Cache: NGINX can store and deliver frequently requested web pages, reducing the load on application servers and improving response times for end-users.

Media Streaming: NGINX can also handle streaming of video and audio content. It supports progressive downloads and adaptive streaming, useful for serving large media files efficiently.

Security and Authentication: NGINX can handle various security tasks, like SSL/TLS termination (decrypting SSL/TLS traffic before passing it on to the internal network), and can integrate with various authentication mechanisms to control access to web content.

Web Application Firewall (WAF): With additional modules, NGINX can function as a WAF, protecting against common web exploits.

API Gateway: NGINX can act as an API gateway, managing API traffic and providing features like rate limiting and authentication.

Microservices Architecture: In a microservices architecture, NGINX can act as a service mesh layer, efficiently routing and balancing traffic between microservices.

#!/bin/bash

# Update system and install Apache
sudo apt update
sudo apt install -y apache2

# Start Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Create a simple webpage
echo "<h1>Hello from Google Cloud!</h1>" | sudo tee /var/www/html/index.html
echo "<p>Server: $(hostname)</p>" | sudo tee -a /var/www/html/index.html
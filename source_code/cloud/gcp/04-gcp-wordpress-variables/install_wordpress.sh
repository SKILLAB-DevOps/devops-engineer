#!/bin/bash

# Get password from metadata
DB_PASSWORD=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-password 2>/dev/null || echo "defaultpass")

# Install LAMP stack
sudo apt update
sudo apt install -y apache2 mysql-server php php-mysql wget

# Start services
sudo systemctl start apache2
sudo systemctl start mysql

# Setup database with variable password
sudo mysql -e "CREATE DATABASE wordpress;"
sudo mysql -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';"

# Download WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/
sudo rm /var/www/html/index.html

# Configure WordPress
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php
sudo sed -i 's/database_name_here/wordpress/' wp-config.php
sudo sed -i 's/username_here/wpuser/' wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" wp-config.php

# Set permissions
sudo chown -R www-data:www-data /var/www/html/

echo "WordPress installed with password from Terraform variable!"
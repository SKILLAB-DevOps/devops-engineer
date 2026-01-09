#!/bin/bash

# Update and install LAMP stack
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apache2 \
  mysql-server \
  php \
  libapache2-mod-php \
  php-mysql \
  wget

# Start services
sudo systemctl start apache2
sudo systemctl start mysql

# Setup database
sudo mysql -e "CREATE DATABASE wordpress;"
sudo mysql -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'password123';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Download WordPress
cd /tmp
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/
sudo rm -f /var/www/html/index.html

# Configure WordPress
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php
sudo sed -i 's/database_name_here/wordpress/' wp-config.php
sudo sed -i 's/username_here/wpuser/' wp-config.php
sudo sed -i 's/password_here/password123/' wp-config.php

# Set permissions
sudo chown -R www-data:www-data /var/www/html/

# Restart Apache
sudo systemctl restart apache2
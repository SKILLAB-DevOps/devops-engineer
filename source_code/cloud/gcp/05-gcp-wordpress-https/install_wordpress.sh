#!/bin/bash

# Install LAMP stack + SSL tools
sudo apt update
sudo apt install -y apache2 mysql-server php php-mysql wget openssl

# Start services
sudo systemctl start apache2
sudo systemctl start mysql

# Setup database
sudo mysql -e "CREATE DATABASE wordpress;"
sudo mysql -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'password123';"
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
sudo sed -i 's/password_here/password123/' wp-config.php

# Create self-signed SSL certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Configure Apache for SSL
sudo tee /etc/apache2/sites-available/wordpress-ssl.conf > /dev/null <<EOF
<VirtualHost *:80>
    Redirect permanent / https://$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)/
</VirtualHost>

<VirtualHost *:443>
    DocumentRoot /var/www/html
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
EOF

# Enable SSL
sudo a2enmod ssl
sudo a2ensite wordpress-ssl.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2

# Set permissions
sudo chown -R www-data:www-data /var/www/html/

echo "WordPress with HTTPS ready! (Self-signed certificate will show browser warning)"
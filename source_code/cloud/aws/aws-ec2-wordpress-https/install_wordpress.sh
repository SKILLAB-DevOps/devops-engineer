#!/bin/bash
sudo yum update -y
sudo yum install -y httpd php php-mysqlnd php-fpm php-json mariadb105-server wget mod_ssl

# Update PHP configuration to allow larger file uploads
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php.ini
sudo sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php.ini

sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB installation (you should customize this part)
sudo mysql_secure_installation <<EOF
y
password
password
y
y
y
y
EOF

# Create WordPress database and user
sudo mysql -e "CREATE DATABASE wordpress;"
sudo mysql -e "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Download WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/

# Configure WordPress
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php
sudo sed -i 's/database_name_here/wordpress/' wp-config.php
sudo sed -i 's/username_here/wordpressuser/' wp-config.php
sudo sed -i 's/password_here/password/' wp-config.php

# Generate self-signed SSL certificate (for testing purposes)
sudo mkdir -p /etc/ssl/private/
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -subj "/C=US/ST=State/L=City/O=Organization/CN=example.com"

# Configure Apache to use SSL
sudo cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak
sudo sed -i 's/SSLCertificateFile \/etc\/pki\/tls\/certs\/localhost.crt/SSLCertificateFile \/etc\/ssl\/certs\/apache-selfsigned.crt/' /etc/httpd/conf.d/ssl.conf
sudo sed -i 's/SSLCertificateKeyFile \/etc\/pki\/tls\/private\/localhost.key/SSLCertificateKeyFile \/etc\/ssl\/private\/apache-selfsigned.key/' /etc/httpd/conf.d/ssl.conf

# Adjust permissions
sudo chown -R apache:apache /var/www/html/
sudo systemctl restart httpd

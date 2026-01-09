#!/bin/bash
sudo yum update -y
sudo yum install -y httpd php php-mysqlnd php-fpm php-json mariadb105-server wget

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

# # Create WordPress database and user
sudo mysql -e "CREATE DATABASE wordpress;"
sudo mysql -e "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# # Download WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/

# # Configure WordPress
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php
sudo sed -i 's/database_name_here/wordpress/' wp-config.php
sudo sed -i 's/username_here/wordpressuser/' wp-config.php
sudo sed -i 's/password_here/password/' wp-config.php

# # Adjust permissions
sudo chown -R apache:apache /var/www/html/
sudo systemctl restart httpd


#!/bin/bash

# Get configuration from metadata
DB_NAME=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-name 2>/dev/null || echo "wordpress")
DB_USER=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-user 2>/dev/null || echo "wordpressuser")
DB_PASSWORD=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-password 2>/dev/null || echo "wordpresspassword")
DB_ROOT_PASSWORD=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db-root-password 2>/dev/null || echo "rootpassword")

# Log startup
echo "Starting WordPress installation with modules at $(date)" | sudo tee /var/log/wordpress-install.log

# Update system
sudo apt update -y
sudo apt upgrade -y

# Install Apache, MySQL, PHP and required extensions
sudo apt install -y apache2 mysql-server php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip wget unzip

# Start and enable services
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure MySQL installation with variables
sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_ROOT_PASSWORD';
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

echo "Database created: $DB_NAME with user: $DB_USER" | sudo tee -a /var/log/wordpress-install.log

# Download and install WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/
sudo rm /var/www/html/index.html

# Configure WordPress with variables
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sudo sed -i "s/username_here/$DB_USER/" wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" wp-config.php

# Generate WordPress salts
SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
SALTS_ESCAPED=$(printf '%s\n' "$SALTS" | sed 's/[[\.*^$()+?{|]/\\&/g')
sudo sed -i "/put your unique phrase here/c\\$SALTS_ESCAPED" wp-config.php

# Set proper permissions
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Configure Apache
sudo tee /etc/apache2/sites-available/wordpress.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Enable the site and required modules
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo a2dissite 000-default.conf
sudo systemctl restart apache2

# Create a detailed info page
sudo tee /var/www/html/info.php > /dev/null <<EOF
<?php
echo "<h1>WordPress Installation Complete with Terraform Modules!</h1>";
echo "<p>Visit your WordPress site at: <a href='http://" . \$_SERVER['HTTP_HOST'] . "'>http://" . \$_SERVER['HTTP_HOST'] . "</a></p>";
echo "<h2>Database Configuration:</h2>";
echo "<p><strong>Database:</strong> $DB_NAME</p>";
echo "<p><strong>User:</strong> $DB_USER</p>";
echo "<p><strong>Host:</strong> localhost</p>";
echo "<h2>Architecture:</h2>";
echo "<p>This deployment uses Terraform modules for:</p>";
echo "<ul>";
echo "<li><strong>Networking:</strong> VPC and Subnet management</li>";
echo "<li><strong>Firewall:</strong> Security rules management</li>";
echo "<li><strong>Compute:</strong> Instance and application deployment</li>";
echo "</ul>";
echo "<p>This info page: <a href='http://" . \$_SERVER['HTTP_HOST'] . "/info.php'>http://" . \$_SERVER['HTTP_HOST'] . "/info.php</a></p>";
echo "<h2>Server Information:</h2>";
phpinfo();
?>
EOF

sudo systemctl restart apache2

echo "WordPress installation completed at $(date)" | sudo tee -a /var/log/wordpress-install.log
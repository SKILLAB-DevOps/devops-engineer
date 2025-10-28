########################################
11.4 Compute Engine - Virtual Machines
########################################

.. note::

    Google Compute Engine provides scalable, high-performance virtual machines (VMs) running on Google's infrastructure. Compute Engine offers predefined machine types, custom machine types, and the ability to run containers directly on VMs. It's Google Cloud's IaaS offering, equivalent to AWS EC2.

=====================
Compute Engine Basics
=====================

**Key Features:**

- **Predefined Machine Types**: Pre-configured VM configurations for common workloads
- **Custom Machine Types**: Create VMs with custom CPU and memory configurations
- **Per-Second Billing**: Pay only for the compute time you use
- **Sustained Use Discounts**: Automatic discounts for running workloads
- **Committed Use Discounts**: Save up to 57% with 1-year or 3-year commitments
- **Preemptible VMs**: Low-cost, short-lived instances (up to 80% discount)
- **Spot VMs**: Similar to preemptible but with more features
- **Live Migration**: No downtime for hardware maintenance
- **Global Load Balancing**: Distribute traffic across regions

**Machine Families:**

1. **General Purpose** (E2, N2, N2D, N1):

   - Balanced CPU and memory
   - Best for web servers, small databases, development environments

2. **Compute Optimized** (C2, C2D):

   - High CPU-to-memory ratio
   - Best for compute-intensive workloads, gaming, HPC

3. **Memory Optimized** (M2, M1):

   - High memory-to-CPU ratio
   - Best for in-memory databases, SAP HANA

4. **Accelerator Optimized** (A2):

   - GPU-attached VMs
   - Best for ML training, HPC, graphics workloads

==========================================
Task 1: Create Instance from Cloud Console
==========================================

This section walks through creating a VM using the Google Cloud Console.

**Step 1: Access Compute Engine**

1. Open Google Cloud Console: https://console.cloud.google.com
2. Navigate to **Navigation menu (☰) → Compute Engine → VM instances**
3. Wait for the Compute Engine API to initialize (first-time setup may take a minute)

**Step 2: Create a New Instance**

1. Click **Create Instance** button
2. Configure the instance with following settings:

**Basic Configuration:**

+------------------+------------------------+--------------------------------------------------------+
| Field            | Value                  | Description                                            |
+==================+========================+========================================================+
| Name             | gcelab                 | Name for the VM instance                               |
+------------------+------------------------+--------------------------------------------------------+
| Region           | us-central1            | Geographic location for the instance                   |
+------------------+------------------------+--------------------------------------------------------+
| Zone             | us-central1-a          | Specific zone within the region                        |
+------------------+------------------------+--------------------------------------------------------+
| Machine family   | General-purpose        | Type of workload the VM is optimized for               |
+------------------+------------------------+--------------------------------------------------------+
| Series           | E2                     | Latest generation general-purpose series               |
+------------------+------------------------+--------------------------------------------------------+
| Machine type     | e2-medium              | 2 vCPUs, 4 GB memory (customizable)                    |
+------------------+------------------------+--------------------------------------------------------+

.. note::

    **About Regions and Zones:**
    
    - **Region**: Geographic location (e.g., us-central1, europe-west1)
    - **Zone**: Isolated location within a region (e.g., us-central1-a, us-central1-b)
    - Resources in different zones are isolated from failures in other zones
    - Network latency between zones in the same region is typically < 1ms

**Step 3: Configure Boot Disk**

1. Click **OS and storage** section
2. Click **Change** to configure boot disk:

+------------------+------------------------+
| Field            | Value                  |
+==================+========================+
| Operating system | Debian                 |
+------------------+------------------------+
| Version          | Debian GNU/Linux 12    |
|                  | (bookworm)             |
+------------------+------------------------+
| Boot disk type   | Balanced persistent    |
|                  | disk                   |
+------------------+------------------------+
| Size (GB)        | 10                     |
+------------------+------------------------+

**Available Operating Systems:**

- Debian, Ubuntu, CentOS, RHEL, Rocky Linux
- Windows Server (2012, 2016, 2019, 2022)
- Container-Optimized OS
- Custom images

**Boot Disk Types:**

- **Standard persistent disk**: Lower cost, lower performance (HDD)
- **Balanced persistent disk**: Balance of performance and cost (SSD)
- **SSD persistent disk**: High performance, higher cost
- **Extreme persistent disk**: Highest performance, highest cost

**Step 4: Configure Networking**

1. Expand **Networking** section
2. Under **Firewall**:
   - ☑ **Allow HTTP traffic**
   - ☐ Allow HTTPS traffic (optional)

.. note::

    Selecting "Allow HTTP traffic" automatically creates a firewall rule to allow traffic on port 80.

**Step 5: Advanced Options (Optional)**

You can configure additional options:

- **Management**: Startup scripts, metadata, availability policy
- **Security**: Shielded VM options, SSH keys
- **Disks**: Additional disks
- **Networking**: Multiple network interfaces, IP forwarding

**Step 6: Create the Instance**

1. Review your configuration
2. Click **Create** button
3. Wait approximately 1 minute for VM creation

**Step 7: Connect via SSH**

Once the instance is running:

1. In the VM instances list, find your instance **gcelab**
2. Click **SSH** button in the row
3. A browser-based SSH terminal will open

Expected SSH terminal output:

.. code-block:: text

    Linux gcelab 5.10.0-26-cloud-amd64 #1 SMP Debian 5.10.197-1 (2023-09-29) x86_64
    
    The programs included with the Debian GNU/Linux system are free software;
    the exact distribution terms for each program are described in the
    individual files in /usr/share/doc/*/copyright.
    
    Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
    permitted by applicable law.
    
    user@gcelab:~$

.. tip::

    **SSH Connection Methods:**
    
    - Browser-based SSH (no SSH client needed)
    - gcloud command: `gcloud compute ssh gcelab --zone=us-central1-a`
    - Standard SSH with SSH keys
    - SSH from Cloud Shell
    - Third-party SSH clients (PuTTY, MobaXterm, etc.)

================================
Task 2: Install NGINX Web Server
================================

Now you'll install NGINX, a popular web server, on your VM.

**Step 1: Update Package Lists**

.. code-block:: bash

    sudo apt-get update

Expected output:

.. code-block:: text

    Get:1 file:/etc/apt/mirrors/debian.list Mirrorlist [30 B]
    Get:5 file:/etc/apt/mirrors/debian-security.list Mirrorlist [39 B]
    Get:7 https://packages.cloud.google.com/apt google-compute-engine-bookworm-stable InRelease [1321 B]
    Get:2 https://deb.debian.org/debian bookworm InRelease [151 kB]                         
    Get:3 https://deb.debian.org/debian bookworm-updates InRelease [55.4 kB]
    Get:4 https://deb.debian.org/debian bookworm-backports InRelease [59.0 kB]
    Hit:8 https://packages.cloud.google.com/apt cloud-sdk-bookworm InRelease
    Hit:6 https://deb.debian.org/debian-security bookworm-security InRelease
    Fetched 267 kB in 1s (274 kB/s)
    Reading package lists... Done

**Step 2: Install NGINX**

.. code-block:: bash

    sudo apt-get install -y nginx

Expected output:

.. code-block:: text

    Reading package lists... Done
    Building dependency tree... Done
    Reading state information... Done
    The following additional packages will be installed:
      fontconfig-config fonts-dejavu-core libdeflate0 libfontconfig1 libgd3
      libjbig0 libjpeg62-turbo libnginx-mod-http-geoip2
      libnginx-mod-http-image-filter libnginx-mod-http-xslt-filter
      libnginx-mod-mail libnginx-mod-stream libnginx-mod-stream-geoip2 libtiff6
      libwebp7 libxslt1.1 nginx-common nginx-core
    Suggested packages:
      libgd-tools fcgiwrap nginx-doc ssl-cert
    The following NEW packages will be installed:
      fontconfig-config fonts-dejavu-core libdeflate0 libfontconfig1 libgd3
      libjbig0 libjpeg62-turbo libnginx-mod-http-geoip2
      libnginx-mod-http-image-filter libnginx-mod-http-xslt-filter
      libnginx-mod-mail libnginx-mod-stream libnginx-mod-stream-geoip2 libtiff6
      libwebp7 libxslt1.1 nginx nginx-common nginx-core
    0 upgraded, 19 newly installed, 0 to remove and 0 not upgraded.
    Need to get 3,192 kB of archives.
    After this operation, 10.2 MB of additional disk space will be used.
    ...
    Setting up nginx (1.22.1-9) ...

**Step 3: Verify NGINX is Running**

.. code-block:: bash

    ps auwx | grep nginx

Expected output:

.. code-block:: text

    root      2330  0.0  0.0 159532  1628 ?        Ss   14:06   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
    www-data  2331  0.0  0.0 159864  3204 ?        S    14:06   0:00 nginx: worker process
    www-data  2332  0.0  0.0 159864  3204 ?        S    14:06   0:00 nginx: worker process
    user      2342  0.0  0.0  12780   988 pts/0    S+   14:07   0:00 grep nginx

**Step 4: Check NGINX Service Status**

.. code-block:: bash

    sudo systemctl status nginx

Expected output:

.. code-block:: text

    ● nginx.service - A high performance web server and a reverse proxy server
         Loaded: loaded (/lib/systemd/system/nginx.service; enabled; preset: enabled)
         Active: active (running) since Wed 2024-01-10 14:06:23 UTC; 2min ago
           Docs: man:nginx(8)
        Process: 2315 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
        Process: 2316 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
       Main PID: 2330 (nginx)
          Tasks: 3 (limit: 4644)
         Memory: 3.2M
            CPU: 25ms
         CGroup: /system.slice/nginx.service
                 ├─2330 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
                 ├─2331 "nginx: worker process"
                 └─2332 "nginx: worker process"

**Step 5: Access the Web Server**

1. Return to the Cloud Console
2. In the VM instances list, find the **External IP** of your instance
3. Click on the External IP link, or open `http://EXTERNAL_IP` in a new browser tab

You should see the default NGINX welcome page:

.. code-block:: text

    Welcome to nginx!
    
    If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.
    
    For online documentation and support please refer to nginx.org.
    Commercial support is available at nginx.com.
    
    Thank you for using nginx.

**Step 6: Customize the Web Page (Optional)**

.. code-block:: bash

    # Create a custom index.html
    sudo bash -c 'cat > /var/www/html/index.html << EOF
    <!DOCTYPE html>
    <html>
    <head>
        <title>My GCE Web Server</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                max-width: 800px;
                margin: 50px auto;
                padding: 20px;
                text-align: center;
            }
            h1 { color: #4285f4; }
            .info {
                background: #f1f3f4;
                padding: 20px;
                border-radius: 8px;
                margin: 20px 0;
            }
        </style>
    </head>
    <body>
        <h1>Hello from Google Compute Engine!</h1>
        <div class="info">
            <p><strong>Hostname:</strong> $(hostname)</p>
            <p><strong>Internal IP:</strong> $(hostname -I)</p>
            <p><strong>Zone:</strong> $(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone | cut -d/ -f4)</p>
        </div>
        <p>This server is running NGINX on Debian GNU/Linux 12</p>
    </body>
    </html>
    EOF'
    
    # Restart NGINX
    sudo systemctl restart nginx

Now refresh your browser to see the customized page.

===========================================
Task 4: Install WordPress on Compute Engine
===========================================

This section guides you through installing WordPress, a popular content management system, on a Compute Engine VM with the LAMP stack (Linux, Apache, MySQL, PHP).

**Step 1: Create a VM for WordPress**

.. code-block:: bash

    # Create VM with appropriate resources for WordPress
    gcloud compute instances create wordpress-vm \
        --zone=us-central1-a \
        --machine-type=e2-medium \
        --tags=http-server,https-server \
        --image-family=debian-12 \
        --image-project=debian-cloud \
        --boot-disk-size=20GB

    # Create firewall rules if they don't exist
    gcloud compute firewall-rules create allow-http \
        --allow=tcp:80 \
        --target-tags=http-server \
        --description="Allow HTTP traffic"

    gcloud compute firewall-rules create allow-https \
        --allow=tcp:443 \
        --target-tags=https-server \
        --description="Allow HTTPS traffic"

**Step 2: Connect to the Instance**

.. code-block:: bash

    gcloud compute ssh wordpress-vm --zone=us-central1-a

**Step 3: Install Apache Web Server**

.. code-block:: bash

    # Update package lists
    sudo apt-get update

    # Install Apache
    sudo apt-get install -y apache2

    # Enable and start Apache
    sudo systemctl enable apache2
    sudo systemctl start apache2

    # Verify Apache is running
    sudo systemctl status apache2

**Expected Apache Status Output:**

.. code-block:: text

    ● apache2.service - The Apache HTTP Server
         Loaded: loaded (/lib/systemd/system/apache2.service; enabled; preset: enabled)
         Active: active (running) since Thu 2024-01-11 10:30:15 UTC; 5s ago
           Docs: https://httpd.apache.org/docs/2.4/
       Main PID: 1234 (apache2)
          Tasks: 55 (limit: 4644)
         Memory: 12.5M
            CPU: 85ms
         CGroup: /system.slice/apache2.service
                 ├─1234 /usr/sbin/apache2 -k start
                 ├─1235 /usr/sbin/apache2 -k start
                 └─1236 /usr/sbin/apache2 -k start

**Step 4: Install MySQL (MariaDB)**

.. code-block:: bash

    # Install MariaDB (MySQL-compatible database)
    sudo apt-get install -y mariadb-server mariadb-client

    # Start and enable MariaDB
    sudo systemctl enable mariadb
    sudo systemctl start mariadb

    # Secure MySQL installation
    sudo mysql_secure_installation

**MySQL Secure Installation Prompts:**

.. code-block:: text

    Enter current password for root (enter for none): [Press Enter]
    
    Switch to unix_socket authentication [Y/n]: n
    
    Change the root password? [Y/n]: Y
    New password: [Enter a strong password]
    Re-enter new password: [Re-enter password]
    
    Remove anonymous users? [Y/n]: Y
    
    Disallow root login remotely? [Y/n]: Y
    
    Remove test database and access to it? [Y/n]: Y
    
    Reload privilege tables now? [Y/n]: Y

.. warning::

    **Important:** Remember the MySQL root password you set. You'll need it for creating the WordPress database.

**Step 5: Create WordPress Database**

.. code-block:: bash

    # Log in to MySQL
    sudo mysql -u root -p

In the MySQL prompt, run the following commands:

.. code-block:: sql

    -- Create database for WordPress
    CREATE DATABASE wordpress_db;
    
    -- Create user for WordPress
    CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'strong_password_here';
    
    -- Grant privileges to the user
    GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';
    
    -- Flush privileges
    FLUSH PRIVILEGES;
    
    -- Verify database creation
    SHOW DATABASES;
    
    -- Exit MySQL
    EXIT;

**Expected Output:**

.. code-block:: text

    MariaDB [(none)]> CREATE DATABASE wordpress_db;
    Query OK, 1 row affected (0.001 sec)
    
    MariaDB [(none)]> CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'strong_password_here';
    Query OK, 0 rows affected (0.002 sec)
    
    MariaDB [(none)]> GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';
    Query OK, 0 rows affected (0.001 sec)
    
    MariaDB [(none)]> FLUSH PRIVILEGES;
    Query OK, 0 rows affected (0.001 sec)

.. note::

    Replace `'strong_password_here'` with a secure password. Save this password as you'll need it for WordPress configuration.

**Step 6: Install PHP and Required Extensions**

.. code-block:: bash

    # Install PHP and necessary extensions for WordPress
    sudo apt-get install -y php php-mysql php-curl php-gd php-xml php-mbstring php-xmlrpc php-zip php-soap php-intl

    # Verify PHP installation
    php -v

**Expected PHP Version Output:**

.. code-block:: text

    PHP 8.2.7 (cli) (built: Jun  9 2023 19:37:27) (NTS)
    Copyright (c) The PHP Group
    Zend Engine v4.2.7, Copyright (c) Zend Technologies
        with Zend OPcache v8.2.7, Copyright (c), by Zend Technologies

**Step 7: Configure PHP for Apache**

.. code-block:: bash

    # Restart Apache to load PHP module
    sudo systemctl restart apache2

    # Create a test PHP file
    echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

    # Test PHP by accessing http://EXTERNAL_IP/info.php in browser
    # You should see PHP configuration information

**Step 8: Download and Install WordPress**

.. code-block:: bash

    # Navigate to temporary directory
    cd /tmp

    # Download latest WordPress
    wget https://wordpress.org/latest.tar.gz

    # Extract WordPress
    tar -xzf latest.tar.gz

    # Copy WordPress files to web root
    sudo cp -r wordpress/* /var/www/html/

    # Remove default index.html
    sudo rm /var/www/html/index.html

    # Set proper ownership
    sudo chown -R www-data:www-data /var/www/html/

    # Set proper permissions
    sudo find /var/www/html/ -type d -exec chmod 755 {} \;
    sudo find /var/www/html/ -type f -exec chmod 644 {} \;

**Expected Output:**

.. code-block:: text

    --2024-01-11 10:35:22--  https://wordpress.org/latest.tar.gz
    Resolving wordpress.org (wordpress.org)... 198.143.164.252
    Connecting to wordpress.org (wordpress.org)|198.143.164.252|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 24123456 (23M) [application/octet-stream]
    Saving to: 'latest.tar.gz'
    
    latest.tar.gz       100%[===================>]  23.01M  50.2MB/s    in 0.5s
    
    2024-01-11 10:35:23 (50.2 MB/s) - 'latest.tar.gz' saved [24123456/24123456]

**Step 9: Configure WordPress**

.. code-block:: bash

    # Create WordPress configuration file from sample
    sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

    # Edit the configuration file
    sudo nano /var/www/html/wp-config.php

Update the following lines with your database credentials:

.. code-block:: php

    // ** Database settings ** //
    /** The name of the database for WordPress */
    define( 'DB_NAME', 'wordpress_db' );
    
    /** Database username */
    define( 'DB_USER', 'wordpress_user' );
    
    /** Database password */
    define( 'DB_PASSWORD', 'strong_password_here' );
    
    /** Database hostname */
    define( 'DB_HOST', 'localhost' );
    
    /** Database charset to use in creating database tables. */
    define( 'DB_CHARSET', 'utf8' );
    
    /** The database collate type. Don't change this if in doubt. */
    define( 'DB_COLLATE', '' );

**Step 10: Generate Security Keys**

.. code-block:: bash

    # Generate unique authentication keys
    curl -s https://api.wordpress.org/secret-key/1.1/salt/

Copy the output and replace the following section in `wp-config.php`:

.. code-block:: php

    define('AUTH_KEY',         'put your unique phrase here');
    define('SECURE_AUTH_KEY',  'put your unique phrase here');
    define('LOGGED_IN_KEY',    'put your unique phrase here');
    define('NONCE_KEY',        'put your unique phrase here');
    define('AUTH_SALT',        'put your unique phrase here');
    define('SECURE_AUTH_SALT', 'put your unique phrase here');
    define('LOGGED_IN_SALT',   'put your unique phrase here');
    define('NONCE_SALT',       'put your unique phrase here');

Save and close the file (Ctrl+X, then Y, then Enter).

**Step 11: Complete WordPress Installation via Web Interface**

1. Get your VM's external IP:

.. code-block:: bash

    # From Cloud Console, or run:
    gcloud compute instances describe wordpress-vm \
        --zone=us-central1-a \
        --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

2. Open your browser and navigate to: `http://EXTERNAL_IP`

3. You'll see the WordPress installation wizard. Fill in the details:

   - **Site Title**: Your website name
   - **Username**: Admin username (don't use 'admin')
   - **Password**: Strong password
   - **Your Email**: Your email address
   - Click **Install WordPress**

4. Once installation is complete, log in with your credentials.

**Step 12: Configure Apache Virtual Host (Optional but Recommended)**

.. code-block:: bash

    # Create virtual host configuration
    sudo nano /etc/apache2/sites-available/wordpress.conf

Add the following configuration:

.. code-block:: apache

    <VirtualHost *:80>
        ServerAdmin admin@example.com
        DocumentRoot /var/www/html
        ServerName your-domain.com
        ServerAlias www.your-domain.com
    
        <Directory /var/www/html/>
            Options FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
    
        ErrorLog ${APACHE_LOG_DIR}/wordpress_error.log
        CustomLog ${APACHE_LOG_DIR}/wordpress_access.log combined
    </VirtualHost>

.. code-block:: bash

    # Enable the site
    sudo a2ensite wordpress.conf
    
    # Enable Apache rewrite module (for permalinks)
    sudo a2enmod rewrite
    
    # Disable default site
    sudo a2dissite 000-default.conf
    
    # Test Apache configuration
    sudo apache2ctl configtest
    
    # Restart Apache
    sudo systemctl restart apache2

**Step 13: Configure WordPress Permalinks**

1. Log in to WordPress admin panel: `http://EXTERNAL_IP/wp-admin`
2. Go to **Settings → Permalinks**
3. Select **Post name** option
4. Click **Save Changes**

**Step 14: Install SSL Certificate (Optional - Using Let's Encrypt)**

.. code-block:: bash

    # Install Certbot
    sudo apt-get install -y certbot python3-certbot-apache
    
    # Obtain and install SSL certificate
    # Replace example.com with your actual domain
    sudo certbot --apache -d example.com -d www.example.com
    
    # Follow the prompts:
    # - Enter your email address
    # - Agree to terms of service
    # - Choose whether to redirect HTTP to HTTPS (recommended: Yes)
    
    # Test automatic renewal
    sudo certbot renew --dry-run

.. note::

    **Prerequisites for SSL:**
    
    - You must have a registered domain name
    - Domain must point to your VM's external IP address
    - Ports 80 and 443 must be open (firewall rules configured)

**Step 15: Optimize WordPress Performance (Optional)**

.. code-block:: bash

    # Install and enable PHP OPcache
    sudo apt-get install -y php-opcache
    
    # Edit PHP configuration
    sudo nano /etc/php/8.2/apache2/php.ini
    
    # Increase memory limit (find and modify)
    memory_limit = 256M
    upload_max_filesize = 64M
    post_max_size = 64M
    max_execution_time = 300
    
    # Restart Apache
    sudo systemctl restart apache2

**Install Popular WordPress Plugins via Command Line:**

.. code-block:: bash

    # Install WP-CLI (WordPress Command Line Interface)
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
    
    # Verify WP-CLI installation
    wp --info
    
    # Navigate to WordPress directory
    cd /var/www/html
    
    # Install and activate plugins (as www-data user)
    sudo -u www-data wp plugin install wordfence --activate
    sudo -u www-data wp plugin install updraftplus --activate
    sudo -u www-data wp plugin install wp-super-cache --activate
    
    # List installed plugins
    sudo -u www-data wp plugin list

**Create Automated Backup Script:**

.. code-block:: bash

    # Create backup directory
    sudo mkdir -p /backups/wordpress
    
    # Create backup script
    sudo nano /usr/local/bin/wordpress-backup.sh

Add the following content:

.. code-block:: bash

    #!/bin/bash
    
    # WordPress backup script
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_DIR="/backups/wordpress"
    WP_DIR="/var/www/html"
    
    # Database credentials
    DB_NAME="wordpress_db"
    DB_USER="wordpress_user"
    DB_PASS="strong_password_here"
    
    # Create backup directory for this backup
    mkdir -p ${BACKUP_DIR}/${TIMESTAMP}
    
    # Backup WordPress files
    echo "Backing up WordPress files..."
    tar -czf ${BACKUP_DIR}/${TIMESTAMP}/wordpress-files.tar.gz ${WP_DIR}
    
    # Backup database
    echo "Backing up WordPress database..."
    mysqldump -u ${DB_USER} -p${DB_PASS} ${DB_NAME} > ${BACKUP_DIR}/${TIMESTAMP}/wordpress-db.sql
    
    # Compress database backup
    gzip ${BACKUP_DIR}/${TIMESTAMP}/wordpress-db.sql
    
    # Delete backups older than 7 days
    find ${BACKUP_DIR} -type d -mtime +7 -exec rm -rf {} \;
    
    echo "Backup completed: ${BACKUP_DIR}/${TIMESTAMP}"

.. code-block:: bash

    # Make script executable
    sudo chmod +x /usr/local/bin/wordpress-backup.sh
    
    # Test the backup script
    sudo /usr/local/bin/wordpress-backup.sh
    
    # Schedule daily backups with cron
    sudo crontab -e
    
    # Add this line to run backup daily at 2 AM
    0 2 * * * /usr/local/bin/wordpress-backup.sh >> /var/log/wordpress-backup.log 2>&1

**WordPress Security Best Practices:**

.. code-block:: bash

    # 1. Change WordPress file permissions
    sudo find /var/www/html/ -type f -exec chmod 644 {} \;
    sudo find /var/www/html/ -type d -exec chmod 755 {} \;
    sudo chmod 600 /var/www/html/wp-config.php
    
    # 2. Disable file editing from WordPress admin
    sudo nano /var/www/html/wp-config.php
    # Add this line before "That's all, stop editing!"
    # define('DISALLOW_FILE_EDIT', true);
    
    # 3. Protect wp-config.php
    sudo nano /var/www/html/.htaccess

Add to `.htaccess`:

.. code-block:: apache

    # Protect wp-config.php
    <files wp-config.php>
    order allow,deny
    deny from all
    </files>

.. code-block:: bash

    # 4. Install fail2ban to prevent brute force attacks
    sudo apt-get install -y fail2ban
    
    # Create WordPress jail configuration
    sudo nano /etc/fail2ban/jail.local

Add:

.. code-block:: ini

    [wordpress]
    enabled = true
    filter = wordpress
    logpath = /var/log/apache2/wordpress_access.log
    maxretry = 3
    bantime = 3600

.. code-block:: bash

    # Create filter
    sudo nano /etc/fail2ban/filter.d/wordpress.conf

Add:

.. code-block:: ini

    [Definition]
    failregex = ^<HOST> .* "POST /wp-login.php
    ignoreregex =

.. code-block:: bash

    # Restart fail2ban
    sudo systemctl restart fail2ban

**Monitoring WordPress:**

.. code-block:: bash

    # Check Apache error logs
    sudo tail -f /var/log/apache2/wordpress_error.log
    
    # Check Apache access logs
    sudo tail -f /var/log/apache2/wordpress_access.log
    
    # Check MySQL error logs
    sudo tail -f /var/log/mysql/error.log
    
    # Check WordPress debug log (if enabled)
    sudo tail -f /var/www/html/wp-content/debug.log
    
    # Monitor system resources
    htop

**Troubleshooting Common WordPress Issues:**

**Issue 1: "Error establishing database connection"**

.. code-block:: bash

    # Check if MySQL is running
    sudo systemctl status mariadb
    
    # Verify database credentials in wp-config.php
    sudo grep "DB_" /var/www/html/wp-config.php
    
    # Test database connection
    mysql -u wordpress_user -p -e "SHOW DATABASES;"

**Issue 2: 413 Request Entity Too Large**

.. code-block:: bash

    # Increase upload size in PHP
    sudo nano /etc/php/8.2/apache2/php.ini
    # Modify:
    # upload_max_filesize = 64M
    # post_max_size = 64M
    
    # Restart Apache
    sudo systemctl restart apache2

**Issue 3: Permalinks not working (404 errors)**

.. code-block:: bash

    # Ensure mod_rewrite is enabled
    sudo a2enmod rewrite
    
    # Check .htaccess is writable
    sudo chown www-data:www-data /var/www/html/.htaccess
    
    # Restart Apache
    sudo systemctl restart apache2

**Issue 4: White screen of death**

.. code-block:: bash

    # Enable WordPress debug mode
    sudo nano /var/www/html/wp-config.php
    
    # Add before "That's all, stop editing!":
    # define('WP_DEBUG', true);
    # define('WP_DEBUG_LOG', true);
    # define('WP_DEBUG_DISPLAY', false);
    
    # Check debug log
    sudo tail -f /var/www/html/wp-content/debug.log

**Create a WordPress Instance Template (For Scaling):**

Once you have a working WordPress installation, you can create an image for easy replication:

.. code-block:: bash

    # Stop the instance
    gcloud compute instances stop wordpress-vm --zone=us-central1-a
    
    # Create custom image
    gcloud compute images create wordpress-image \
        --source-disk=wordpress-vm \
        --source-disk-zone=us-central1-a \
        --family=wordpress
    
    # Create instance template
    gcloud compute instance-templates create wordpress-template \
        --machine-type=e2-medium \
        --image=wordpress-image \
        --tags=http-server,https-server
    
    # Create managed instance group
    gcloud compute instance-groups managed create wordpress-group \
        --base-instance-name=wordpress \
        --template=wordpress-template \
        --size=2 \
        --zone=us-central1-a

.. tip::

    **WordPress Performance Tips:**
    
    - Use a CDN (Cloud CDN) for static assets
    - Install caching plugin (WP Super Cache, W3 Total Cache)
    - Optimize images before uploading
    - Use Cloud SQL instead of local MySQL for production
    - Enable Cloud Storage for media files
    - Use Cloud Load Balancer for high-traffic sites

**WordPress with Cloud SQL (Production Setup):**

For production environments, it's recommended to use Cloud SQL instead of local MySQL:

.. code-block:: bash

    # Create Cloud SQL instance
    gcloud sql instances create wordpress-db \
        --database-version=MYSQL_8_0 \
        --tier=db-n1-standard-1 \
        --region=us-central1
    
    # Set root password
    gcloud sql users set-password root \
        --host=% \
        --instance=wordpress-db \
        --password=STRONG_PASSWORD
    
    # Create WordPress database
    gcloud sql databases create wordpress_db \
        --instance=wordpress-db
    
    # Get Cloud SQL connection name
    gcloud sql instances describe wordpress-db \
        --format='value(connectionName)'
    
    # Install Cloud SQL proxy on VM
    wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
    chmod +x cloud_sql_proxy
    sudo mv cloud_sql_proxy /usr/local/bin/
    
    # Run Cloud SQL proxy
    cloud_sql_proxy -instances=PROJECT_ID:us-central1:wordpress-db=tcp:3306 &

Update `wp-config.php` to use Cloud SQL:

.. code-block:: php

    define('DB_HOST', '127.0.0.1:3306');

================================================
Task 3: Create Instance with gcloud Command Line
================================================

Instead of using the Cloud Console, you can create VMs using the `gcloud` command-line tool.

**Step 1: Set Default Zone (Optional)**

.. code-block:: bash

    # Set default zone to avoid specifying --zone every time
    gcloud config set compute/zone us-central1-a
    
    # Set default region
    gcloud config set compute/region us-central1
    
    # Verify configuration
    gcloud config list

**Step 2: Create a New VM Instance**

.. code-block:: bash

    gcloud compute instances create gcelab2 \
        --machine-type=e2-medium \
        --zone=us-central1-a

Expected output:

.. code-block:: text

    Created [https://www.googleapis.com/compute/v1/projects/PROJECT_ID/zones/us-central1-a/instances/gcelab2].
    NAME     ZONE           MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
    gcelab2  us-central1-a  e2-medium                  10.128.0.3   34.136.51.150  RUNNING

**Default Values:**

When you create an instance with minimal parameters, gcloud uses these defaults:

- **Image**: Latest Debian GNU/Linux image
- **Boot disk size**: 10 GB
- **Boot disk type**: Balanced persistent disk
- **Network**: default VPC network

**Step 3: View All Available Options**

.. code-block:: bash

    gcloud compute instances create --help

Key options:

.. code-block:: bash

    # Specify custom machine type
    gcloud compute instances create my-vm \
        --machine-type=n1-standard-4 \
        --zone=us-central1-a
    
    # Specify boot disk image and size
    gcloud compute instances create my-vm \
        --image-family=debian-12 \
        --image-project=debian-cloud \
        --boot-disk-size=20GB \
        --boot-disk-type=pd-ssd \
        --zone=us-central1-a
    
    # Add tags for firewall rules
    gcloud compute instances create my-vm \
        --tags=http-server,https-server \
        --zone=us-central1-a
    
    # Add startup script
    gcloud compute instances create my-vm \
        --metadata=startup-script='#!/bin/bash
    apt-get update
    apt-get install -y nginx' \
        --zone=us-central1-a
    
    # Specify network and subnet
    gcloud compute instances create my-vm \
        --network=my-vpc \
        --subnet=my-subnet \
        --zone=us-central1-a

**Step 4: Connect via SSH**

.. code-block:: bash

    # Connect to instance
    gcloud compute ssh gcelab2 --zone=us-central1-a

You'll be prompted to generate SSH keys:

.. code-block:: text

    WARNING: The private SSH key file for gcloud does not exist.
    WARNING: The public SSH key file for gcloud does not exist.
    WARNING: You do not have an SSH key for gcloud.
    WARNING: Creating a key pair now...
    Generating public/private rsa key pair.
    Enter passphrase (empty for no passphrase):

Press **Enter** to skip the passphrase (or set one for added security).

**Step 5: Exit SSH Session**

.. code-block:: bash

    exit

=============================
Advanced VM Creation Examples
=============================

**Create Preemptible VM (Up to 80% discount):**

.. code-block:: bash

    gcloud compute instances create preemptible-vm \
        --zone=us-central1-a \
        --machine-type=e2-medium \
        --preemptible \
        --maintenance-policy=TERMINATE

**Create Spot VM:**

.. code-block:: bash

    gcloud compute instances create spot-vm \
        --zone=us-central1-a \
        --machine-type=e2-medium \
        --provisioning-model=SPOT \
        --instance-termination-action=DELETE

**Create VM with Custom Machine Type:**

.. code-block:: bash

    # Custom machine: 4 vCPUs, 8 GB memory
    gcloud compute instances create custom-vm \
        --zone=us-central1-a \
        --custom-cpu=4 \
        --custom-memory=8GB

**Create VM with GPU:**

.. code-block:: bash

    gcloud compute instances create gpu-vm \
        --zone=us-central1-a \
        --machine-type=n1-standard-4 \
        --accelerator=type=nvidia-tesla-t4,count=1 \
        --maintenance-policy=TERMINATE

**Create VM from Custom Image:**

.. code-block:: bash

    gcloud compute instances create from-custom-image \
        --zone=us-central1-a \
        --image=my-custom-image \
        --image-project=my-project-id

**Create VM with Attached Disk:**

.. code-block:: bash

    # Create disk first
    gcloud compute disks create my-data-disk \
        --size=100GB \
        --zone=us-central1-a
    
    # Create VM with attached disk
    gcloud compute instances create vm-with-disk \
        --zone=us-central1-a \
        --disk=name=my-data-disk,mode=rw

**Create VM with Startup Script from File:**

.. code-block:: bash

    # Create startup script file
    cat > startup-script.sh << 'EOF'
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    
    cat > /var/www/html/index.html << 'HTML'
    <h1>Configured by startup script</h1>
    <p>Hostname: $(hostname)</p>
    HTML
    
    systemctl start nginx
    EOF
    
    # Create VM with script
    gcloud compute instances create scripted-vm \
        --zone=us-central1-a \
        --metadata-from-file=startup-script=startup-script.sh

========================
VM Management Operations
========================

**List Instances:**

.. code-block:: bash

    # List all instances
    gcloud compute instances list
    
    # List instances in specific zone
    gcloud compute instances list --filter="zone:us-central1-a"
    
    # List with custom format
    gcloud compute instances list \
        --format="table(name,zone,machineType,status,networkInterfaces[0].accessConfigs[0].natIP:label=EXTERNAL_IP)"

**Get Instance Details:**

.. code-block:: bash

    gcloud compute instances describe gcelab --zone=us-central1-a

**Stop Instance:**

.. code-block:: bash

    gcloud compute instances stop gcelab --zone=us-central1-a

**Start Instance:**

.. code-block:: bash

    gcloud compute instances start gcelab --zone=us-central1-a

**Reset Instance (Hard reboot):**

.. code-block:: bash

    gcloud compute instances reset gcelab --zone=us-central1-a

**Delete Instance:**

.. code-block:: bash

    gcloud compute instances delete gcelab --zone=us-central1-a

**Delete Multiple Instances:**

.. code-block:: bash

    gcloud compute instances delete gcelab gcelab2 --zone=us-central1-a

================================
Instance Metadata and Attributes
================================

**Set Instance Metadata:**

.. code-block:: bash

    # Set metadata
    gcloud compute instances add-metadata gcelab \
        --zone=us-central1-a \
        --metadata=environment=production,owner=alice

**Access Metadata from Instance:**

.. code-block:: bash

    # SSH into instance and query metadata server
    curl -H "Metadata-Flavor: Google" \
        http://metadata.google.internal/computeMetadata/v1/instance/
    
    # Get specific metadata
    curl -H "Metadata-Flavor: Google" \
        http://metadata.google.internal/computeMetadata/v1/instance/name
    
    curl -H "Metadata-Flavor: Google" \
        http://metadata.google.internal/computeMetadata/v1/instance/zone
    
    curl -H "Metadata-Flavor: Google" \
        http://metadata.google.internal/computeMetadata/v1/instance/attributes/environment

**Add Network Tags:**

.. code-block:: bash

    gcloud compute instances add-tags gcelab \
        --zone=us-central1-a \
        --tags=web-server,production

**Set Instance Labels:**

.. code-block:: bash

    gcloud compute instances add-labels gcelab \
        --zone=us-central1-a \
        --labels=env=prod,team=backend

===============
Disk Management
===============

**Create Additional Disk:**

.. code-block:: bash

    gcloud compute disks create data-disk \
        --size=100GB \
        --type=pd-ssd \
        --zone=us-central1-a

**Attach Disk to Instance:**

.. code-block:: bash

    gcloud compute instances attach-disk gcelab \
        --disk=data-disk \
        --zone=us-central1-a

**Mount Disk (From Within Instance):**

.. code-block:: bash

    # List disks
    sudo lsblk
    
    # Format disk (only needed first time)
    sudo mkfs.ext4 -F /dev/sdb
    
    # Create mount point
    sudo mkdir -p /mnt/data
    
    # Mount disk
    sudo mount /dev/sdb /mnt/data
    
    # Make permanent (add to /etc/fstab)
    echo "/dev/sdb /mnt/data ext4 defaults 0 0" | sudo tee -a /etc/fstab

**Detach Disk:**

.. code-block:: bash

    # Must stop instance first (or unmount disk)
    gcloud compute instances detach-disk gcelab \
        --disk=data-disk \
        --zone=us-central1-a

**Create Disk Snapshot:**

.. code-block:: bash

    gcloud compute disks snapshot data-disk \
        --zone=us-central1-a \
        --snapshot-names=data-disk-snapshot-$(date +%Y%m%d)

**Create Disk from Snapshot:**

.. code-block:: bash

    gcloud compute disks create restored-disk \
        --source-snapshot=data-disk-snapshot-20240110 \
        --zone=us-central1-a

=============================
Instance Templates and Groups
=============================

**Create Instance Template:**

.. code-block:: bash

    gcloud compute instance-templates create web-server-template \
        --machine-type=e2-medium \
        --image-family=debian-12 \
        --image-project=debian-cloud \
        --tags=http-server \
        --metadata=startup-script='#!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx'

**Create Managed Instance Group:**

.. code-block:: bash

    gcloud compute instance-groups managed create web-server-group \
        --base-instance-name=web-server \
        --template=web-server-template \
        --size=3 \
        --zone=us-central1-a

**Set Autoscaling:**

.. code-block:: bash

    gcloud compute instance-groups managed set-autoscaling web-server-group \
        --zone=us-central1-a \
        --max-num-replicas=10 \
        --min-num-replicas=2 \
        --target-cpu-utilization=0.75

==============
Best Practices
==============

**1. Use Appropriate Machine Types:**

- Start small and scale up based on metrics
- Use custom machine types for specific requirements
- Consider preemptible/spot VMs for fault-tolerant workloads

**2. Implement Proper Backup Strategy:**

.. code-block:: bash

    # Create regular snapshots
    gcloud compute disks snapshot DISK_NAME \
        --zone=ZONE \
        --snapshot-names=backup-$(date +%Y%m%d-%H%M%S)

**3. Use Startup Scripts:**

.. code-block:: bash

    # Automate configuration with startup scripts
    gcloud compute instances create my-vm \
        --metadata=startup-script='#!/bin/bash
    # Your automation here'

**4. Tag and Label Resources:**

.. code-block:: bash

    # Use tags for firewall rules
    # Use labels for billing and organization
    gcloud compute instances create my-vm \
        --tags=web-server,production \
        --labels=env=prod,team=backend,cost-center=engineering

**5. Monitor Your Instances:**

.. code-block:: bash

    # Enable OS Login for better audit trails
    gcloud compute project-info add-metadata \
        --metadata=enable-oslogin=TRUE
    
    # Enable guest attributes
    gcloud compute instances add-metadata INSTANCE_NAME \
        --metadata=enable-guest-attributes=TRUE

===============
Troubleshooting
===============

**Cannot SSH to Instance:**

.. code-block:: bash

    # Check firewall rules
    gcloud compute firewall-rules list --filter="targetTags:ssh-access"
    
    # Check if instance is running
    gcloud compute instances describe INSTANCE_NAME --zone=ZONE
    
    # Reset SSH keys
    gcloud compute config-ssh

**Instance Not Starting:**

.. code-block:: bash

    # Check serial port output for boot errors
    gcloud compute instances get-serial-port-output INSTANCE_NAME \
        --zone=ZONE

**Disk Space Issues:**

.. code-block:: bash

    # Check disk usage
    df -h
    
    # Find large files
    sudo du -h --max-depth=1 / | sort -hr | head -20

=======
Cleanup
=======

.. code-block:: bash

    # Delete instances
    gcloud compute instances delete gcelab gcelab2 --zone=us-central1-a --quiet
    
    # Delete disks
    gcloud compute disks delete data-disk --zone=us-central1-a --quiet
    
    # Delete instance template
    gcloud compute instance-templates delete web-server-template --quiet
    
    # Delete instance group
    gcloud compute instance-groups managed delete web-server-group --zone=us-central1-a --quiet

====================
Additional Resources
====================

- Compute Engine Documentation: https://cloud.google.com/compute/docs
- Machine Types: https://cloud.google.com/compute/docs/machine-types
- Images: https://cloud.google.com/compute/docs/images
- Instance Templates: https://cloud.google.com/compute/docs/instance-templates
- Managed Instance Groups: https://cloud.google.com/compute/docs/instance-groups

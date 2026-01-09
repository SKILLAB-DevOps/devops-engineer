# WordPress Deployment with Ansible

This directory contains a complete Ansible playbook to install and configure WordPress with NGINX, PHP-FPM, and MySQL on Ubuntu systems.

## What This Playbook Installs

- **NGINX** - Web server wiThis represents the culmination of all Ansible concepts covered in the previous examples!

## Learning Objectives Achieved

This WordPress deployment demonstrates:

- **Complex multi-service deployment**
- **Template usage for dynamic configurations**
- **Variable management and security**
- **Service orchestration and dependencies**
- **Error handling and validation**
- **Security hardening best practices**
- **Backup and maintenance automation**
- **Production-ready configurations**

This represents the culmination of all Ansible concepts covered in the previous examples!dPress configuration
- **PHP 8.1-FPM** - PHP processor with WordPress-specific settings
- **MySQL** - Database server with WordPress database and user
- **WordPress** - Latest version with security hardening
- **Additional tools** - fail2ban for security, backup scripts

## Files Included

### Main Playbooks
- `wordpress-install.yml` - Complete WordPress installation
- `wordpress-security.yml` - Security hardening and fail2ban setup
- `wordpress-backup.yml` - Backup creation and scheduling

### Templates
- `wp-config.php.j2` - WordPress configuration with security settings
- `wordpress-nginx.conf.j2` - NGINX virtual host optimized for WordPress
- `wordpress-php-fpm.conf.j2` - PHP-FPM pool configuration

## Prerequisites

- Ubuntu 20.04 or 22.04 (target system)
- Ansible installed on control machine
- SSH access with sudo privileges
- At least 1GB RAM and 10GB disk space

## Quick Start

### 1. Basic Installation

```bash
# Install WordPress with default settings
ansible-playbook -i ../01-basic-setup/inventory.yml wordpress-install.yml

# Or run on localhost for testing
ansible-playbook -i localhost, wordpress-install.yml --connection=local
```

### 2. Custom Configuration

```bash
# Install with custom settings
ansible-playbook -i localhost, wordpress-install.yml --connection=local \
  -e "wordpress_site_title='My Custom Site'" \
  -e "wordpress_admin_user='myadmin'" \
  -e "wordpress_admin_password='MySecurePassword123!'" \
  -e "wordpress_admin_email='admin@mysite.com'"
```

### 3. Complete Setup with Security

```bash
# Install WordPress
ansible-playbook -i localhost, wordpress-install.yml --connection=local

# Apply security hardening
ansible-playbook -i localhost, wordpress-security.yml --connection=local

# Setup backups
ansible-playbook -i localhost, wordpress-backup.yml --connection=local
```

## Default Credentials

**Important**: Change these in production!

- **WordPress Admin User**: `admin`
- **WordPress Admin Password**: `SecurePassword123!`
- **MySQL Root Password**: `RootPassword123!`
- **WordPress DB Password**: `WPPassword123!`

## Configuration Variables

You can customize the installation by setting these variables:

```yaml
# WordPress settings
wordpress_site_title: "My WordPress Site"
wordpress_admin_user: "admin"
wordpress_admin_password: "SecurePassword123!"
wordpress_admin_email: "admin@example.com"

# Database settings
mysql_root_password: "RootPassword123!"
wordpress_db_name: "wordpress"
wordpress_db_user: "wp_user"
wordpress_db_password: "WPPassword123!"

# Server settings
php_version: "8.1"
web_root: "/var/www/html"
```

## Testing Your Installation

### 1. Check Services
```bash
# Verify all services are running
ansible all -i localhost, -m command -a "systemctl status nginx" --connection=local
ansible all -i localhost, -m command -a "systemctl status mysql" --connection=local
ansible all -i localhost, -m command -a "systemctl status php8.1-fpm" --connection=local
```

### 2. Test WordPress
```bash
# Check if WordPress is accessible
curl -I http://localhost

# Test database connection
mysql -u wp_user -p -e "SHOW DATABASES;"
```

### 3. Access WordPress
- Open `http://your-server-ip` in a browser
- Complete the WordPress setup wizard
- Login with your admin credentials

## Security Features

### Built-in Security
- Secure file permissions (755 for directories, 644 for files)
- wp-config.php protection (600 permissions)
- NGINX security headers
- PHP security settings
- MySQL security (removes test DB, anonymous users)
- Disabled file editing in WordPress admin

### Additional Security (wordpress-security.yml)
- fail2ban integration for brute force protection
- WordPress-specific fail2ban filters
- Enhanced file permission hardening

### Security Best Practices Applied
- Blocks access to sensitive files (.htaccess, wp-config.php)
- Disables XML-RPC (common attack vector)
- Prevents PHP execution in uploads directory
- Implements proper NGINX security headers

## Backup System

The backup playbook (`wordpress-backup.yml`) provides:

- **Files backup**: Complete WordPress directory archive
- **Database backup**: MySQL dump of WordPress database
- **Automated cleanup**: Removes backups older than 7 days
- **Cron-ready script**: Easy scheduling for automatic backups

### Manual Backup
```bash
# Create immediate backup
ansible-playbook -i localhost, wordpress-backup.yml --connection=local
```

### Schedule Automatic Backups
```bash
# Add to crontab for daily backups at 2 AM
echo "0 2 * * * /usr/local/bin/wordpress-backup.sh" | crontab -
```

## Troubleshooting

### Common Issues

1. **Permission Errors**
   ```bash
   # Fix WordPress permissions
   sudo /usr/local/bin/wp-security-hardening.sh
   ```

2. **PHP Errors**
   ```bash
   # Check PHP-FPM logs
   sudo tail -f /var/log/php8.1-fpm-wordpress.log
   ```

3. **NGINX Errors**
   ```bash
   # Test NGINX configuration
   sudo nginx -t
   
   # Check NGINX logs
   sudo tail -f /var/log/nginx/wordpress-error.log
   ```

4. **MySQL Connection Issues**
   ```bash
   # Test database connection
   mysql -u wp_user -pWPPassword123! wordpress -e "SHOW TABLES;"
   ```

### Service Management
```bash
# Restart services if needed
sudo systemctl restart nginx
sudo systemctl restart php8.1-fpm
sudo systemctl restart mysql
```

## Performance Optimization

The playbook includes several performance optimizations:

- **NGINX**: Gzip compression, static file caching, optimized buffers
- **PHP-FPM**: Dynamic process management, memory limits
- **MySQL**: Optimized for WordPress workload
- **WordPress**: Memory limit increases, caching headers

## Production Considerations

Before deploying to production:

1. **Change all default passwords**
2. **Configure SSL/TLS certificates**
3. **Set up proper domain names**
4. **Configure email settings**
5. **Enable automatic updates**
6. **Set up monitoring and logging**
7. **Configure firewall rules**
8. **Schedule regular backups**

## Next Steps

After successful installation:

1. **WordPress Setup**: Complete the WordPress installation wizard
2. **SSL Setup**: Configure HTTPS with Let's Encrypt
3. **Themes and Plugins**: Install required themes and plugins
4. **Content Import**: Import existing content if migrating
5. **Performance Testing**: Test site performance and optimize
6. **Monitoring**: Set up uptime and performance monitoring

## Learning Objectives Achieved

This WordPress deployment demonstrates:

- **Complex multi-service deployment**
- **Template usage for dynamic configurations**
- **Variable management and security**
- **Service orchestration and dependencies**
- **Error handling and validation**
- **Security hardening best practices**
- **Backup and maintenance automation**
- **Production-ready configurations**

This represents the culmination of all Ansible concepts covered in the previous examples!
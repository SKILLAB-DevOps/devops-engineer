#######
Answers
#######

===============
Quick Questions
===============

**1. Which command shows all running processes with their resource usage in real-time?**

`htop` provides an interactive, real-time view of processes with resource usage. Alternative options:
- `top` - Classic process monitor  
- `btop` - Modern resource monitor with better visualization
- `glances` - All-in-one system monitor
- `ps aux` - Static snapshot of all processes

**2. How do you make a script executable for the owner only while keeping it readable by the group?**

`chmod 750 script.sh` sets permissions to rwxr-x--- (owner: read/write/execute, group: read/execute, others: no access)

**3. What's the difference between apt, snap, and container-based package management?**

- **apt**: Traditional package manager using shared libraries, system-wide installation
- **snap**: Containerized packages with bundled dependencies, sandboxed execution
- **Container packages**: Docker/Podman images with complete runtime environments

**4. Which command shows real-time system resource usage including CPU, memory, and I/O?**

`htop` for processes, `iotop` for disk I/O, `nethogs` for network usage. Modern alternative: `btop` combines all metrics.

**5. How do you create a service user for a web application with no shell access?**

`sudo useradd -r -s /usr/sbin/nologin -d /var/lib/webapp webapp` creates a system user without shell access.

**6. What does /etc/fstab contain and why is it critical for system boot?**

Mount point definitions that specify which filesystems to mount at boot, their options, and mount order. Critical for system startup.

**7. How do you follow logs from multiple services simultaneously?**

`journalctl -f -u nginx -u postgres` or `tail -f /var/log/{nginx,postgres}/*` for multiple log files.

**8. Which command identifies which process is using a specific network port?**

`lsof -i :PORT` or `ss -tulpn | grep PORT` shows processes using specific ports.

**9. What's the difference between systemctl enable and systemctl start?**

- `systemctl start`: Starts service immediately (current session)
- `systemctl enable`: Configures service to start automatically at boot

**10. How do you securely store secrets in configuration files with proper permissions?**

Store in separate files with `chmod 600` (owner read/write only), use environment variables, or dedicated secret management tools like HashiCorp Vault.

==============
Task Solutions
==============

**Task 1: User Management Automation**

.. code-block:: python

    #!/usr/bin/env python3
    # user_manager.py
    import subprocess
    import sys
    
    def create_user(username, groups=None, home_dir=True):
        """Create a new user with optional groups"""
        cmd = ['sudo', 'useradd']
        if home_dir:
            cmd.append('-m')
        if groups:
            cmd.extend(['-G', ','.join(groups)])
        cmd.append(username)
        
        try:
            subprocess.run(cmd, check=True)
            print(f"User {username} created successfully")
        except subprocess.CalledProcessError as e:
            print(f"Error creating user: {e}")
    
    def add_to_group(username, group):
        """Add user to a group"""
        try:
            subprocess.run(['sudo', 'usermod', '-a', '-G', group, username], check=True)
            print(f"Added {username} to group {group}")
        except subprocess.CalledProcessError as e:
            print(f"Error adding to group: {e}")
    
    if __name__ == "__main__":
        create_user("serviceuser", groups=["docker", "sudo"], home_dir=True)

**Task 2: System Monitoring Dashboard**

.. code-block:: python

    #!/usr/bin/env python3
    # system_monitor.py
    import psutil
    import time
    import os
    
    def display_system_info():
        """Display real-time system metrics"""
        while True:
            os.system('clear')
            
            # CPU usage
            cpu_percent = psutil.cpu_percent(interval=1)
            print(f"CPU Usage: {cpu_percent}%")
            
            # Memory usage
            memory = psutil.virtual_memory()
            print(f"Memory: {memory.percent}% ({memory.used/1024/1024/1024:.1f}GB / {memory.total/1024/1024/1024:.1f}GB)")
            
            # Disk usage
            disk = psutil.disk_usage('/')
            print(f"Disk: {disk.percent}% ({disk.used/1024/1024/1024:.1f}GB / {disk.total/1024/1024/1024:.1f}GB)")
            
            # Network
            net_io = psutil.net_io_counters()
            print(f"Network: {net_io.bytes_sent/1024/1024:.1f}MB sent, {net_io.bytes_recv/1024/1024:.1f}MB received")
            
            # Top processes
            print("\nTop 5 CPU processes:")
            for proc in psutil.process_iter(['pid', 'name', 'cpu_percent']):
                try:
                    if proc.info['cpu_percent'] > 0:
                        print(f"  {proc.info['pid']}: {proc.info['name']} ({proc.info['cpu_percent']}%)")
                except (psutil.NoSuchProcess, psutil.AccessDenied):
                    pass
            
            time.sleep(5)
    
    if __name__ == "__main__":
        display_system_info()

**Task 3: Log Analysis Tool**

.. code-block:: python

    #!/usr/bin/env python3
    # log_analyzer.py
    import re
    import sys
    from collections import defaultdict
    from datetime import datetime
    
    def analyze_logs(log_file):
        """Analyze log files for patterns and issues"""
        error_count = 0
        warning_count = 0
        ip_addresses = defaultdict(int)
        error_messages = []
        
        try:
            with open(log_file, 'r') as f:
                for line in f:
                    # Count errors and warnings
                    if 'ERROR' in line.upper():
                        error_count += 1
                        error_messages.append(line.strip())
                    elif 'WARNING' in line.upper():
                        warning_count += 1
                    
                    # Extract IP addresses
                    ip_pattern = r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b'
                    ips = re.findall(ip_pattern, line)
                    for ip in ips:
                        ip_addresses[ip] += 1
        
        except FileNotFoundError:
            print(f"Log file {log_file} not found")
            return
        
        print(f"Log Analysis for {log_file}")
        print(f"Errors: {error_count}")
        print(f"Warnings: {warning_count}")
        print(f"Top IP addresses:")
        for ip, count in sorted(ip_addresses.items(), key=lambda x: x[1], reverse=True)[:5]:
            print(f"  {ip}: {count} occurrences")
        
        if error_messages:
            print(f"\nRecent errors:")
            for error in error_messages[-3:]:
                print(f"  {error}")
    
    if __name__ == "__main__":
        log_file = sys.argv[1] if len(sys.argv) > 1 else "/var/log/syslog"
        analyze_logs(log_file)

**Task 4: Automated Backup System**

.. code-block:: python

    #!/usr/bin/env python3
    # backup_system.py
    import os
    import tarfile
    import datetime
    import shutil
    
    def create_backup(source_dirs, backup_dir="/backup"):
        """Create compressed backup of specified directories"""
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_name = f"system_backup_{timestamp}.tar.gz"
        backup_path = os.path.join(backup_dir, backup_name)
        
        # Ensure backup directory exists
        os.makedirs(backup_dir, exist_ok=True)
        
        try:
            with tarfile.open(backup_path, "w:gz") as tar:
                for source_dir in source_dirs:
                    if os.path.exists(source_dir):
                        tar.add(source_dir, arcname=os.path.basename(source_dir))
                        print(f"Added {source_dir} to backup")
            
            print(f"Backup created: {backup_path}")
            
            # Cleanup old backups (keep last 5)
            cleanup_old_backups(backup_dir, keep=5)
            
        except Exception as e:
            print(f"Backup failed: {e}")
    
    def cleanup_old_backups(backup_dir, keep=5):
        """Remove old backup files, keeping only the most recent ones"""
        backups = [f for f in os.listdir(backup_dir) if f.startswith("system_backup_")]
        backups.sort(reverse=True)
        
        for old_backup in backups[keep:]:
            os.remove(os.path.join(backup_dir, old_backup))
            print(f"Removed old backup: {old_backup}")
    
    if __name__ == "__main__":
        important_dirs = ["/etc", "/home", "/var/log"]
        create_backup(important_dirs)

**Task 5: Process Management Utility**

.. code-block:: python

    #!/usr/bin/env python3
    # process_manager.py
    import psutil
    import signal
    import sys
    
    def find_processes(name_pattern):
        """Find processes matching a name pattern"""
        matching_procs = []
        for proc in psutil.process_iter(['pid', 'name', 'memory_percent', 'cpu_percent']):
            try:
                if name_pattern.lower() in proc.info['name'].lower():
                    matching_procs.append(proc)
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
        return matching_procs
    
    def terminate_process(pid, force=False):
        """Safely terminate a process"""
        try:
            proc = psutil.Process(pid)
            if force:
                proc.kill()
                print(f"Forcefully killed process {pid}")
            else:
                proc.terminate()
                print(f"Terminated process {pid}")
        except psutil.NoSuchProcess:
            print(f"Process {pid} not found")
        except psutil.AccessDenied:
            print(f"Access denied to process {pid}")
    
    def monitor_process(pid):
        """Monitor a specific process"""
        try:
            proc = psutil.Process(pid)
            print(f"Process {pid} ({proc.name()}):")
            print(f"  CPU: {proc.cpu_percent()}%")
            print(f"  Memory: {proc.memory_percent():.1f}%")
            print(f"  Status: {proc.status()}")
        except psutil.NoSuchProcess:
            print(f"Process {pid} not found")
    
    if __name__ == "__main__":
        if len(sys.argv) < 2:
            print("Usage: python3 process_manager.py <process_name>")
            sys.exit(1)
        
        processes = find_processes(sys.argv[1])
        for proc in processes:
            monitor_process(proc.info['pid'])

**Task 6: Service Health Monitor**

.. code-block:: python

    #!/usr/bin/env python3
    # service_monitor.py
    import subprocess
    import time
    import smtplib
    from email.mime.text import MIMEText
    
    def check_service_status(service_name):
        """Check if a systemd service is active"""
        try:
            result = subprocess.run(['systemctl', 'is-active', service_name], 
                                  capture_output=True, text=True)
            return result.stdout.strip() == 'active'
        except Exception:
            return False
    
    def restart_service(service_name):
        """Restart a systemd service"""
        try:
            subprocess.run(['sudo', 'systemctl', 'restart', service_name], check=True)
            print(f"Restarted service: {service_name}")
            return True
        except subprocess.CalledProcessError:
            print(f"Failed to restart service: {service_name}")
            return False
    
    def send_alert(service_name, status):
        """Send email alert for service status"""
        # Configure your SMTP settings here
        smtp_server = "localhost"
        from_email = "admin@localhost"
        to_email = "alerts@localhost"
        
        subject = f"Service Alert: {service_name}"
        body = f"Service {service_name} is {status}"
        
        try:
            msg = MIMEText(body)
            msg['Subject'] = subject
            msg['From'] = from_email
            msg['To'] = to_email
            
            with smtplib.SMTP(smtp_server) as server:
                server.send_message(msg)
            print(f"Alert sent for {service_name}")
        except Exception as e:
            print(f"Failed to send alert: {e}")
    
    def monitor_services(services):
        """Monitor a list of critical services"""
        while True:
            for service in services:
                if not check_service_status(service):
                    print(f"Service {service} is down, attempting restart...")
                    if restart_service(service):
                        send_alert(service, "restarted")
                    else:
                        send_alert(service, "failed to restart")
                else:
                    print(f"Service {service} is running")
            
            time.sleep(60)  # Check every minute
    
    if __name__ == "__main__":
        critical_services = ["nginx", "docker", "sshd"]
        monitor_services(critical_services)

**Task 7: Disk Space Management**

.. code-block:: python

    #!/usr/bin/env python3
    # disk_manager.py
    import os
    import shutil
    import sys
    from pathlib import Path
    
    def get_directory_size(path):
        """Calculate total size of a directory"""
        total_size = 0
        try:
            for dirpath, dirnames, filenames in os.walk(path):
                for filename in filenames:
                    filepath = os.path.join(dirpath, filename)
                    try:
                        total_size += os.path.getsize(filepath)
                    except OSError:
                        pass
        except OSError:
            pass
        return total_size
    
    def find_large_files(path, min_size_mb=100):
        """Find files larger than specified size"""
        large_files = []
        min_size_bytes = min_size_mb * 1024 * 1024
        
        try:
            for root, dirs, files in os.walk(path):
                for file in files:
                    filepath = os.path.join(root, file)
                    try:
                        size = os.path.getsize(filepath)
                        if size > min_size_bytes:
                            large_files.append((filepath, size))
                    except OSError:
                        pass
        except OSError:
            pass
        
        return sorted(large_files, key=lambda x: x[1], reverse=True)
    
    def analyze_disk_usage(path="/"):
        """Analyze disk usage and provide recommendations"""
        total, used, free = shutil.disk_usage(path)
        usage_percent = (used / total) * 100
        
        print(f"Disk Usage Analysis for {path}")
        print(f"Total: {total/1024/1024/1024:.1f} GB")
        print(f"Used: {used/1024/1024/1024:.1f} GB ({usage_percent:.1f}%)")
        print(f"Free: {free/1024/1024/1024:.1f} GB")
        
        if usage_percent > 90:
            print("WARNING: Disk usage above 90%!")
            
            # Find largest directories
            print("\nLargest directories:")
            dirs_to_check = ["/var/log", "/tmp", "/home", "/var/cache"]
            for dir_path in dirs_to_check:
                if os.path.exists(dir_path):
                    size = get_directory_size(dir_path)
                    print(f"  {dir_path}: {size/1024/1024:.1f} MB")
            
            # Find large files
            print(f"\nLarge files (>100MB):")
            large_files = find_large_files(path, min_size_mb=100)
            for filepath, size in large_files[:10]:
                print(f"  {filepath}: {size/1024/1024:.1f} MB")
    
    def cleanup_temp_files():
        """Clean up temporary files"""
        temp_dirs = ["/tmp", "/var/tmp"]
        cleaned_size = 0
        
        for temp_dir in temp_dirs:
            if os.path.exists(temp_dir):
                for item in os.listdir(temp_dir):
                    item_path = os.path.join(temp_dir, item)
                    try:
                        if os.path.isfile(item_path):
                            size = os.path.getsize(item_path)
                            os.remove(item_path)
                            cleaned_size += size
                    except OSError:
                        pass
        
        print(f"Cleaned {cleaned_size/1024/1024:.1f} MB of temporary files")
    
    if __name__ == "__main__":
        analyze_disk_usage()
        cleanup_temp_files()

**Task 8: Network Configuration Manager**

.. code-block:: python

    #!/usr/bin/env python3
    # network_manager.py
    import subprocess
    import socket
    import re
    
    def get_network_interfaces():
        """Get all network interfaces and their status"""
        try:
            result = subprocess.run(['ip', 'addr', 'show'], capture_output=True, text=True)
            interfaces = {}
            
            current_interface = None
            for line in result.stdout.split('\n'):
                # Match interface line
                interface_match = re.match(r'^\d+: ([^:]+):', line)
                if interface_match:
                    current_interface = interface_match.group(1)
                    interfaces[current_interface] = {'ip': None, 'status': 'down'}
                
                # Match IP address
                if current_interface and 'inet ' in line:
                    ip_match = re.search(r'inet ([^/]+)', line)
                    if ip_match:
                        interfaces[current_interface]['ip'] = ip_match.group(1)
                
                # Check if interface is up
                if current_interface and 'state UP' in line:
                    interfaces[current_interface]['status'] = 'up'
            
            return interfaces
        except Exception as e:
            print(f"Error getting network interfaces: {e}")
            return {}
    
    def test_connectivity(host="8.8.8.8", port=53, timeout=5):
        """Test network connectivity to a host"""
        try:
            socket.setdefaulttimeout(timeout)
            socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((host, port))
            return True
        except socket.error:
            return False
    
    def check_dns_resolution(domain="google.com"):
        """Test DNS resolution"""
        try:
            socket.gethostbyname(domain)
            return True
        except socket.gaierror:
            return False
    
    def network_diagnostics():
        """Run comprehensive network diagnostics"""
        print("Network Diagnostics Report")
        print("=" * 30)
        
        # Check interfaces
        print("Network Interfaces:")
        interfaces = get_network_interfaces()
        for interface, info in interfaces.items():
            print(f"  {interface}: {info['status']} - {info['ip'] or 'No IP'}")
        
        # Test connectivity
        print(f"\nConnectivity Tests:")
        print(f"  Internet (8.8.8.8): {'✓' if test_connectivity() else '✗'}")
        print(f"  DNS Resolution: {'✓' if check_dns_resolution() else '✗'}")
        
        # Check routing
        try:
            result = subprocess.run(['ip', 'route', 'show', 'default'], 
                                  capture_output=True, text=True)
            if result.stdout:
                print(f"  Default Gateway: {result.stdout.strip()}")
            else:
                print("  Default Gateway: Not configured")
        except Exception:
            print("  Default Gateway: Unable to check")
    
    if __name__ == "__main__":
        network_diagnostics()

**Task 9: Package Management Automation**

.. code-block:: python

    #!/usr/bin/env python3
    # package_manager.py
    import subprocess
    import sys
    import platform
    
    class PackageManager:
        def __init__(self):
            self.detect_package_manager()
        
        def detect_package_manager(self):
            """Detect the available package manager"""
            managers = {
                'apt': ['apt', 'apt-get'],
                'dnf': ['dnf'],
                'yum': ['yum'],
                'pacman': ['pacman'],
                'snap': ['snap']
            }
            
            self.available_managers = {}
            for manager, commands in managers.items():
                for cmd in commands:
                    if self.command_exists(cmd):
                        self.available_managers[manager] = cmd
                        break
        
        def command_exists(self, command):
            """Check if a command exists in PATH"""
            try:
                subprocess.run(['which', command], check=True, 
                             capture_output=True, text=True)
                return True
            except subprocess.CalledProcessError:
                return False
        
        def update_package_list(self):
            """Update package list/cache"""
            if 'apt' in self.available_managers:
                return self.run_command(['sudo', 'apt', 'update'])
            elif 'dnf' in self.available_managers:
                return self.run_command(['sudo', 'dnf', 'check-update'])
            elif 'yum' in self.available_managers:
                return self.run_command(['sudo', 'yum', 'check-update'])
            return False
        
        def install_package(self, package_name):
            """Install a package using the appropriate manager"""
            if 'apt' in self.available_managers:
                return self.run_command(['sudo', 'apt', 'install', '-y', package_name])
            elif 'dnf' in self.available_managers:
                return self.run_command(['sudo', 'dnf', 'install', '-y', package_name])
            elif 'yum' in self.available_managers:
                return self.run_command(['sudo', 'yum', 'install', '-y', package_name])
            elif 'snap' in self.available_managers:
                return self.run_command(['sudo', 'snap', 'install', package_name])
            return False
        
        def remove_package(self, package_name):
            """Remove a package"""
            if 'apt' in self.available_managers:
                return self.run_command(['sudo', 'apt', 'remove', '-y', package_name])
            elif 'dnf' in self.available_managers:
                return self.run_command(['sudo', 'dnf', 'remove', '-y', package_name])
            elif 'yum' in self.available_managers:
                return self.run_command(['sudo', 'yum', 'remove', '-y', package_name])
            return False
        
        def run_command(self, command):
            """Execute a command and return success status"""
            try:
                result = subprocess.run(command, check=True, capture_output=True, text=True)
                print(f"Command successful: {' '.join(command)}")
                return True
            except subprocess.CalledProcessError as e:
                print(f"Command failed: {' '.join(command)}")
                print(f"Error: {e.stderr}")
                return False
    
    if __name__ == "__main__":
        pm = PackageManager()
        print(f"Available package managers: {list(pm.available_managers.keys())}")
        
        if len(sys.argv) > 2:
            action = sys.argv[1]
            package = sys.argv[2]
            
            if action == "install":
                pm.update_package_list()
                pm.install_package(package)
            elif action == "remove":
                pm.remove_package(package)
        else:
            print("Usage: python3 package_manager.py [install|remove] <package_name>")

**Task 10: System Security Auditor**

.. code-block:: python

    #!/usr/bin/env python3
    # security_auditor.py
    import os
    import subprocess
    import pwd
    import grp
    import stat
    
    def check_user_permissions():
        """Audit user accounts and permissions"""
        print("User Security Audit")
        print("-" * 20)
        
        # Check for users with UID 0 (root privileges)
        root_users = []
        for user in pwd.getpwall():
            if user.pw_uid == 0:
                root_users.append(user.pw_name)
        
        print(f"Users with root privileges: {root_users}")
        
        # Check for users with empty passwords
        try:
            with open('/etc/shadow', 'r') as f:
                empty_passwords = []
                for line in f:
                    fields = line.strip().split(':')
                    if len(fields) > 1 and fields[1] == '':
                        empty_passwords.append(fields[0])
                print(f"Users with empty passwords: {empty_passwords}")
        except PermissionError:
            print("Cannot check password file (insufficient permissions)")
    
    def check_file_permissions():
        """Check critical file permissions"""
        print("\nFile Permission Audit")
        print("-" * 22)
        
        critical_files = {
            '/etc/passwd': 0o644,
            '/etc/shadow': 0o640,
            '/etc/group': 0o644,
            '/etc/sudoers': 0o440,
            '/etc/ssh/sshd_config': 0o644
        }
        
        for filepath, expected_perms in critical_files.items():
            if os.path.exists(filepath):
                current_perms = stat.S_IMODE(os.stat(filepath).st_mode)
                if current_perms != expected_perms:
                    print(f"WARNING: {filepath} has permissions {oct(current_perms)}, expected {oct(expected_perms)}")
                else:
                    print(f"OK: {filepath} permissions correct")
            else:
                print(f"INFO: {filepath} not found")
    
    def check_open_ports():
        """Check for open network ports"""
        print("\nOpen Ports Audit")
        print("-" * 17)
        
        try:
            result = subprocess.run(['ss', '-tuln'], capture_output=True, text=True)
            listening_ports = []
            
            for line in result.stdout.split('\n'):
                if 'LISTEN' in line:
                    parts = line.split()
                    if len(parts) >= 5:
                        address = parts[4]
                        if ':' in address:
                            port = address.split(':')[-1]
                            listening_ports.append(port)
            
            print(f"Listening ports: {sorted(set(listening_ports))}")
            
            # Check for potentially dangerous ports
            dangerous_ports = ['23', '21', '69', '135', '139', '445']
            open_dangerous = [port for port in listening_ports if port in dangerous_ports]
            if open_dangerous:
                print(f"WARNING: Potentially dangerous ports open: {open_dangerous}")
            
        except Exception as e:
            print(f"Error checking ports: {e}")
    
    def check_ssh_config():
        """Check SSH configuration security"""
        print("\nSSH Configuration Audit")
        print("-" * 24)
        
        ssh_config = '/etc/ssh/sshd_config'
        if not os.path.exists(ssh_config):
            print("SSH config not found")
            return
        
        security_checks = {
            'PermitRootLogin': 'no',
            'PasswordAuthentication': 'no',
            'PermitEmptyPasswords': 'no',
            'X11Forwarding': 'no'
        }
        
        try:
            with open(ssh_config, 'r') as f:
                config_content = f.read()
                
                for setting, secure_value in security_checks.items():
                    if f"{setting} {secure_value}" in config_content:
                        print(f"OK: {setting} is securely configured")
                    else:
                        print(f"WARNING: {setting} may not be securely configured")
        
        except PermissionError:
            print("Cannot read SSH config (insufficient permissions)")
    
    def security_recommendations():
        """Provide security recommendations"""
        print("\nSecurity Recommendations")
        print("-" * 25)
        print("1. Regularly update system packages")
        print("2. Use strong passwords and consider key-based SSH authentication")
        print("3. Configure firewall (ufw/iptables) to restrict access")
        print("4. Monitor system logs for suspicious activity")
        print("5. Disable unnecessary services")
        print("6. Regular security audits and penetration testing")
        print("7. Implement intrusion detection system (fail2ban)")
        print("8. Keep backups and test recovery procedures")
    
    if __name__ == "__main__":
        print("Linux Security Audit Report")
        print("=" * 30)
        
        check_user_permissions()
        check_file_permissions()
        check_open_ports()
        check_ssh_config()
        security_recommendations()

=================
Discussion Topics
=================

**1. Linux distribution selection strategy**

Consider these factors when choosing distributions:

- **Stability vs Features**: Ubuntu LTS/RHEL for production stability, Fedora/Ubuntu latest for newer features
- **Package Management**: apt (Debian-based) vs yum/dnf (Red Hat-based) vs pacman (Arch)
- **Support Lifecycle**: Enterprise distributions offer 5-10 year support cycles
- **Container Optimization**: Alpine Linux for minimal container images, CoreOS for container-focused infrastructure
- **Development vs Production**: Different requirements for development flexibility vs production reliability

**2. System hardening and security practices**

Comprehensive security strategy should include:

- **Access Control**: Principle of least privilege, regular user audit, strong authentication
- **Network Security**: Firewall configuration, VPN access, network segmentation
- **System Monitoring**: Log analysis, intrusion detection, file integrity monitoring
- **Regular Updates**: Automated security patches, vulnerability scanning
- **Backup Strategy**: Regular backups, tested recovery procedures, offline backup storage

**3. Performance optimization methodology**

Systematic approach to performance issues:

1. **Baseline Measurement**: Establish performance metrics before optimization
2. **Bottleneck Identification**: CPU, memory, disk I/O, network analysis
3. **Tool Selection**: htop, iotop, nethogs, perf, strace for different scenarios
4. **Incremental Changes**: Make one change at a time, measure impact
5. **Monitoring**: Continuous monitoring to catch performance degradation

**4. Automation vs manual administration**

Automation decision framework:

- **Automate First**: Repetitive tasks, routine maintenance, deployment procedures
- **Manual for**: Complex troubleshooting, one-time configuration changes, emergency response
- **ROI Calculation**: Time investment vs time saved, error reduction benefits
- **Start Small**: Begin with simple scripts, expand to configuration management tools
- **Documentation**: Maintain runbooks for both automated and manual procedures

**5. Disaster recovery and business continuity**

Comprehensive disaster recovery planning:

- **Risk Assessment**: Identify critical systems, acceptable downtime (RTO/RPO)
- **Backup Strategy**: Multiple backup types (full, incremental, differential), offsite storage
- **Recovery Testing**: Regular disaster recovery drills, documented procedures
- **Infrastructure Redundancy**: High availability, geographic distribution, failover mechanisms
- **Communication Plan**: Incident response team, stakeholder notification, status updates

##################
2.6 System Logging
##################

=========================
Understanding System Logs
=========================

Linux logging is the foundation of observability in DevOps environments. Modern systems combine **systemd journald** with traditional log files, container logs, and centralized logging solutions.

**Critical Log Categories:**

.. code-block:: bash

    # System logs
    /var/log/messages         # General system messages (RHEL/CentOS)
    /var/log/syslog          # System logs (Debian/Ubuntu)
    /var/log/kern.log        # Kernel messages
    /var/log/dmesg           # Boot messages
    
    # Security logs
    /var/log/secure          # Authentication logs (RHEL/CentOS)
    /var/log/auth.log        # Authentication logs (Debian/Ubuntu)
    /var/log/faillog         # Failed login attempts
    /var/log/lastlog         # Last login information
    
    # Service logs
    /var/log/cron            # Cron job execution
    /var/log/mail.log        # Mail server logs
    /var/log/apache2/        # Apache web server logs
    /var/log/nginx/          # Nginx web server logs
    
    # Application logs
    /var/log/myapp/          # Custom application logs
    /opt/app/logs/           # Application-specific directories

**DevOps Logging Context:**

Modern logging involves multiple layers:

- **System Logs**: Traditional syslog and journald
- **Container Logs**: Docker and Kubernetes container output
- **Application Logs**: Structured logging (JSON, structured text)
- **Centralized Logging**: ELK Stack, Splunk, CloudWatch
- **Metrics Integration**: Prometheus, Grafana, DataDog

=========================
journalctl (systemd logs)
=========================

**Advanced journalctl Usage:**

.. code-block:: bash

    # Basic log viewing
    journalctl                           # All logs (paginated)
    journalctl --no-pager               # All logs without pager
    journalctl -n 50                    # Last 50 entries
    journalctl -f                       # Follow logs in real-time
    
    # Service-specific logs
    journalctl -u nginx                 # Nginx service logs
    journalctl -u docker                # Docker daemon logs
    journalctl -u kubelet               # Kubernetes kubelet logs
    journalctl -u ssh.service           # SSH service logs
    
    # Time-based filtering
    journalctl --since today            # Today's logs
    journalctl --since yesterday        # Yesterday's logs
    journalctl --since "2025-01-01"     # From specific date
    journalctl --since "1 hour ago"     # Last hour
    journalctl --since "30 min ago"     # Last 30 minutes
    journalctl --until "2025-01-01 12:00" # Until specific time
    
    # Priority-based filtering
    journalctl -p emerg                 # Emergency messages
    journalctl -p alert                 # Alert messages
    journalctl -p crit                  # Critical messages
    journalctl -p err                   # Error messages
    journalctl -p warning               # Warning and above
    journalctl -p notice                # Notice and above
    journalctl -p info                  # Info and above
    journalctl -p debug                 # All messages
    
    # Boot-specific logs
    journalctl --list-boots             # List all boots
    journalctl -b                       # Current boot
    journalctl -b -1                    # Previous boot
    journalctl -b -2                    # Two boots ago
    
    # Kernel and hardware logs
    journalctl -k                       # Kernel messages
    journalctl -k -b                    # Kernel messages from current boot
    
    # Advanced filtering
    journalctl _PID=1234                # Logs from specific PID
    journalctl _UID=1000                # Logs from specific user
    journalctl _COMM=nginx              # Logs from specific command
    journalctl SYSLOG_FACILITY=10       # Logs from specific facility
    
    # Output formatting
    journalctl -o json                  # JSON format
    journalctl -o json-pretty           # Pretty JSON format
    journalctl -o cat                   # Only message content
    journalctl -o short-iso             # ISO timestamp format
    
    # Disk usage and maintenance
    journalctl --disk-usage             # Show journal disk usage
    journalctl --vacuum-size=100M       # Keep only 100MB of logs
    journalctl --vacuum-time=2weeks     # Keep only 2 weeks of logs
    journalctl --rotate                 # Force log rotation

=====================
Traditional Log Tools
=====================

**Advanced Log File Analysis:**

.. code-block:: bash

    # Real-time log monitoring
    tail -f /var/log/syslog              # Follow single log
    tail -f /var/log/{syslog,auth.log}   # Follow multiple logs
    multitail /var/log/syslog /var/log/auth.log  # Side-by-side monitoring
    
    # Log content analysis
    less /var/log/syslog                 # Paginated viewing
    zless /var/log/syslog.1.gz           # View compressed logs
    head -n 100 /var/log/messages        # First 100 lines
    tail -n 500 /var/log/auth.log        # Last 500 lines
    
    # Searching and filtering
    grep -i "error" /var/log/syslog      # Case-insensitive search
    grep -n "failed" /var/log/auth.log   # Show line numbers
    grep -A 5 -B 5 "error" /var/log/syslog  # Show context lines
    grep -r "pattern" /var/log/          # Recursive search
    zgrep "pattern" /var/log/*.gz        # Search compressed logs
    
    # Modern search tools
    rg "error" /var/log/                 # ripgrep (faster than grep)
    ag "pattern" /var/log/               # silver searcher
    
    # Log statistics and analysis
    awk '{print $1}' /var/log/access.log | sort | uniq -c  # Count by first field
    cut -d' ' -f1 /var/log/auth.log | sort | uniq -c       # Extract and count IPs
    
    # Date-based log analysis
    sed -n '/Jan 10/,/Jan 11/p' /var/log/syslog  # Extract date range
    awk '/2025-01-10/' /var/log/syslog            # Filter by date pattern

**Log Rotation Management:**

.. code-block:: bash

    # Log rotation configuration
    cat /etc/logrotate.conf              # Main configuration
    ls /etc/logrotate.d/                 # Service-specific configs
    
    # Manual log rotation
    logrotate -d /etc/logrotate.conf     # Dry run (debug mode)
    logrotate -f /etc/logrotate.conf     # Force rotation
    logrotate -v /etc/logrotate.conf     # Verbose output
    
    # Check rotation status
    cat /var/lib/logrotate/status        # Last rotation times
    ls -la /var/log/ | grep -E "\.(gz|bz2)$"  # Rotated log files
    
    # Custom log rotation example
    cat > /etc/logrotate.d/myapp << 'EOF'
    /var/log/myapp/*.log {
        daily
        missingok
        rotate 30
        compress
        delaycompress
        notifempty
        create 644 myapp myapp
        postrotate
            systemctl reload myapp
        endscript
    }
    EOF

**Container and Cloud Logging:**

.. code-block:: bash

    # Docker container logs
    docker logs container_name           # View container logs
    docker logs -f container_name        # Follow container logs
    docker logs --since 1h container_name  # Last hour of logs
    docker logs --tail 100 container_name  # Last 100 lines
    
    # Kubernetes pod logs
    kubectl logs pod_name                # Pod logs
    kubectl logs -f pod_name             # Follow pod logs
    kubectl logs pod_name -c container   # Specific container in pod
    kubectl logs --previous pod_name     # Previous container instance
    
    # Cloud logging (AWS CloudWatch example)
    aws logs describe-log-groups         # List log groups
    aws logs tail /aws/lambda/function   # Tail CloudWatch logs
    
    # Centralized logging setup
    # Filebeat configuration for ELK stack
    cat > /etc/filebeat/filebeat.yml << 'EOF'
    filebeat.inputs:
    - type: log
      enabled: true
      paths:
        - /var/log/*.log
        - /var/log/myapp/*.log
    
    output.elasticsearch:
      hosts: ["elasticsearch:9200"]
    
    processors:
    - add_host_metadata:
        when.not.contains.tags: forwarded
    EOF

===================
Python Log Analysis
===================

**Production-Ready Log Analysis Framework:**

.. code-block:: python

    #!/usr/bin/env python3
    # advanced_log_analyzer.py - DevOps log analysis
    import re
    import json
    import subprocess
    import gzip
    import logging
    from datetime import datetime, timedelta
    from collections import defaultdict, Counter
    from pathlib import Path
    from typing import Dict, List, Optional, Tuple
    import ipaddress
    
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    
    class LogAnalyzer:
        """Advanced log analysis for DevOps environments"""
        
        def __init__(self):
            self.patterns = {
                # SSH patterns
                'ssh_failed': r'Failed password for (?:invalid user )?(\w+) from (\d+\.\d+\.\d+\.\d+)',
                'ssh_success': r'Accepted (?:password|publickey) for (\w+) from (\d+\.\d+\.\d+\.\d+)',
                'ssh_disconnect': r'Disconnected from (\d+\.\d+\.\d+\.\d+)',
                
                # Web server patterns
                'nginx_error': r'(\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}) \[(\w+)\] .* client: (\d+\.\d+\.\d+\.\d+)',
                'apache_error': r'\[([^\]]+)\] \[(\w+)\] .* client (\d+\.\d+\.\d+\.\d+)',
                'http_404': r'(\d+\.\d+\.\d+\.\d+) .* "(?:GET|POST|PUT|DELETE) ([^"]*)" 404',
                
                # System patterns
                'oom_killer': r'Out of memory: Kill process (\d+) \(([^)]+)\)',
                'segfault': r'segfault at ([0-9a-f]+) .* in ([^\[]+)',
                'kernel_error': r'kernel: \[([\d.]+)\] (.+)',
                
                # Security patterns
                'sudo_usage': r'(\w+) : TTY=([^;]*) ; PWD=([^;]*) ; USER=([^;]*) ; COMMAND=(.+)',
                'failed_su': r'FAILED SU \(to (\w+)\) (\w+) on (\w+)',
                
                # General patterns
                'timestamp': r'(\w{3}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2})',
                'ip_address': r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})',
                'error_levels': r'(ERROR|WARN|INFO|DEBUG|FATAL|CRITICAL)',
            }
        
        def analyze_security_logs(self, log_files: List[str]) -> Dict:
            """Comprehensive security log analysis"""
            results = {
                'failed_logins': defaultdict(int),
                'successful_logins': [],
                'suspicious_ips': set(),
                'brute_force_attempts': {},
                'privilege_escalations': [],
                'geographic_analysis': defaultdict(int)
            }
            
            for log_file in log_files:
                try:
                    self._process_security_log_file(log_file, results)
                except Exception as e:
                    logger.error(f"Error processing {log_file}: {e}")
            
            # Analyze brute force patterns
            results['brute_force_attempts'] = self._detect_brute_force(results['failed_logins'])
            
            # Identify suspicious IPs
            results['suspicious_ips'] = self._identify_suspicious_ips(results['failed_logins'])
            
            return results
        
        def _process_security_log_file(self, log_file: str, results: Dict):
            """Process individual security log file"""
            open_func = gzip.open if log_file.endswith('.gz') else open
            mode = 'rt' if log_file.endswith('.gz') else 'r'
            
            with open_func(log_file, mode, errors='ignore') as f:
                for line_num, line in enumerate(f, 1):
                    try:
                        # Failed SSH attempts
                        match = re.search(self.patterns['ssh_failed'], line)
                        if match:
                            user, ip = match.groups()
                            results['failed_logins'][ip] += 1
                            if self._is_suspicious_login_attempt(user, ip):
                                results['suspicious_ips'].add(ip)
                        
                        # Successful SSH logins
                        match = re.search(self.patterns['ssh_success'], line)
                        if match:
                            user, ip = match.groups()
                            timestamp = self._extract_timestamp(line)
                            results['successful_logins'].append({
                                'user': user,
                                'ip': ip,
                                'timestamp': timestamp,
                                'line_number': line_num
                            })
                        
                        # Sudo usage
                        match = re.search(self.patterns['sudo_usage'], line)
                        if match:
                            user, tty, pwd, target_user, command = match.groups()
                            results['privilege_escalations'].append({
                                'user': user,
                                'target_user': target_user,
                                'command': command,
                                'timestamp': self._extract_timestamp(line)
                            })
                    
                    except Exception as e:
                        logger.warning(f"Error processing line {line_num} in {log_file}: {e}")
        
        def analyze_application_logs(self, log_dir: str, app_name: str) -> Dict:
            """Analyze application-specific logs"""
            log_path = Path(log_dir)
            results = {
                'error_count': 0,
                'warning_count': 0,
                'error_patterns': Counter(),
                'performance_issues': [],
                'timeline': defaultdict(int)
            }
            
            # Find application log files
            log_files = list(log_path.glob(f"{app_name}*.log*"))
            
            for log_file in log_files:
                try:
                    self._analyze_app_log_file(str(log_file), results)
                except Exception as e:
                    logger.error(f"Error analyzing {log_file}: {e}")
            
            return results
        
        def _analyze_app_log_file(self, log_file: str, results: Dict):
            """Analyze individual application log file"""
            open_func = gzip.open if log_file.endswith('.gz') else open
            mode = 'rt' if log_file.endswith('.gz') else 'r'
            
            with open_func(log_file, mode, errors='ignore') as f:
                for line in f:
                    # Count error levels
                    if re.search(r'ERROR|error', line, re.IGNORECASE):
                        results['error_count'] += 1
                        # Extract error pattern
                        error_msg = self._extract_error_message(line)
                        if error_msg:
                            results['error_patterns'][error_msg] += 1
                    
                    elif re.search(r'WARN|warning', line, re.IGNORECASE):
                        results['warning_count'] += 1
                    
                    # Performance issues
                    if self._is_performance_issue(line):
                        results['performance_issues'].append({
                            'line': line.strip(),
                            'timestamp': self._extract_timestamp(line)
                        })
                    
                    # Timeline analysis
                    timestamp = self._extract_timestamp(line)
                    if timestamp:
                        hour = timestamp.split(':')[0] if ':' in timestamp else timestamp
                        results['timeline'][hour] += 1
        
        def generate_security_report(self, analysis_results: Dict) -> str:
            """Generate comprehensive security report"""
            report = []
            report.append("SECURITY ANALYSIS REPORT")
            report.append("=" * 50)
            report.append(f"Generated: {datetime.now().isoformat()}\n")
            
            # Failed login summary
            total_failures = sum(analysis_results['failed_logins'].values())
            report.append(f"Total Failed Login Attempts: {total_failures}")
            report.append(f"Unique IPs with Failed Attempts: {len(analysis_results['failed_logins'])}")
            
            # Top attacking IPs
            if analysis_results['failed_logins']:
                report.append("\nTop 10 Attacking IPs:")
                sorted_ips = sorted(analysis_results['failed_logins'].items(), 
                                  key=lambda x: x[1], reverse=True)[:10]
                for ip, count in sorted_ips:
                    report.append(f"  {ip}: {count} attempts")
            
            # Brute force detection
            if analysis_results['brute_force_attempts']:
                report.append("\nBrute Force Attacks Detected:")
                for ip, data in analysis_results['brute_force_attempts'].items():
                    report.append(f"  {ip}: {data['attempts']} attempts in {data['timespan']}")
            
            # Successful logins
            report.append(f"\nSuccessful Logins: {len(analysis_results['successful_logins'])}")
            
            # Privilege escalations
            report.append(f"Sudo Commands Executed: {len(analysis_results['privilege_escalations'])}")
            
            return '\n'.join(report)
        
        def export_to_json(self, analysis_results: Dict, output_file: str):
            """Export analysis results to JSON"""
            # Convert sets to lists for JSON serialization
            json_results = {}
            for key, value in analysis_results.items():
                if isinstance(value, set):
                    json_results[key] = list(value)
                elif isinstance(value, defaultdict):
                    json_results[key] = dict(value)
                else:
                    json_results[key] = value
            
            with open(output_file, 'w') as f:
                json.dump(json_results, f, indent=2, default=str)
        
        def _detect_brute_force(self, failed_logins: Dict, threshold: int = 20) -> Dict:
            """Detect brute force attacks"""
            brute_force = {}
            for ip, count in failed_logins.items():
                if count >= threshold:
                    brute_force[ip] = {
                        'attempts': count,
                        'timespan': 'unknown',  # Would need timestamp analysis
                        'severity': 'high' if count > 100 else 'medium'
                    }
            return brute_force
        
        def _identify_suspicious_ips(self, failed_logins: Dict) -> set:
            """Identify suspicious IP addresses"""
            suspicious = set()
            for ip, count in failed_logins.items():
                try:
                    ip_obj = ipaddress.ip_address(ip)
                    # Flag high-frequency attempts
                    if count > 50:
                        suspicious.add(ip)
                    # Flag private IPs attempting external access
                    if ip_obj.is_private and count > 10:
                        suspicious.add(ip)
                except ValueError:
                    continue
            return suspicious
        
        def _is_suspicious_login_attempt(self, user: str, ip: str) -> bool:
            """Determine if login attempt is suspicious"""
            suspicious_users = ['root', 'admin', 'administrator', 'test', 'oracle']
            return user.lower() in suspicious_users
        
        def _extract_timestamp(self, line: str) -> Optional[str]:
            """Extract timestamp from log line"""
            match = re.search(self.patterns['timestamp'], line)
            return match.group(1) if match else None
        
        def _extract_error_message(self, line: str) -> Optional[str]:
            """Extract error message pattern"""
            # Simple extraction - could be enhanced based on log format
            parts = line.split()
            for i, part in enumerate(parts):
                if 'error' in part.lower():
                    return ' '.join(parts[i:i+5])  # Get context around error
            return None
        
        def _is_performance_issue(self, line: str) -> bool:
            """Detect performance-related issues"""
            performance_keywords = [
                'timeout', 'slow', 'performance', 'latency',
                'memory', 'cpu', 'disk', 'connection pool'
            ]
            return any(keyword in line.lower() for keyword in performance_keywords)
    
    def main():
        """Example usage"""
        analyzer = LogAnalyzer()
        
        # Analyze security logs
        security_logs = ['/var/log/auth.log', '/var/log/secure']
        existing_logs = [log for log in security_logs if Path(log).exists()]
        
        if existing_logs:
            results = analyzer.analyze_security_logs(existing_logs)
            report = analyzer.generate_security_report(results)
            print(report)
            
            # Export to JSON
            analyzer.export_to_json(results, 'security_analysis.json')
        else:
            print("No security log files found")
    
    if __name__ == "__main__":
        main()
    import time
    import re
    
    def monitor_failed_logins():
        """Monitor for failed SSH login attempts"""
        
        # Start following auth log
        proc = subprocess.Popen([
            'journalctl', '-u', 'ssh', '-f', '--no-pager'
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        
        failed_pattern = re.compile(r'Failed password.*from (\d+\.\d+\.\d+\.\d+)')
        
        print("Monitoring failed SSH attempts...")
        
        try:
            for line in iter(proc.stdout.readline, ''):
                if failed_pattern.search(line):
                    ip_match = failed_pattern.search(line)
                    if ip_match:
                        ip = ip_match.group(1)
                        timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
                        print(f"[{timestamp}] FAILED LOGIN from {ip}")
        except KeyboardInterrupt:
            proc.terminate()

**Log Rotation Management:**

.. code-block:: python

    # log_rotation.py
    import os
    import gzip
    import shutil
    from datetime import datetime
    
    def rotate_custom_log(log_file, max_size_mb=100, keep_rotations=5):
        """Simple log rotation for custom applications"""
        
        if not os.path.exists(log_file):
            return
        
        # Check file size
        size_mb = os.path.getsize(log_file) / (1024 * 1024)
        
        if size_mb > max_size_mb:
            # Create rotated filename
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            rotated_file = f"{log_file}.{timestamp}.gz"
            
            # Compress and rotate
            with open(log_file, 'rb') as f_in:
                with gzip.open(rotated_file, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            
            # Clear original log
            open(log_file, 'w').close()
            
            print(f"Rotated {log_file} to {rotated_file}")
            
            # Clean up old rotations
            cleanup_old_logs(log_file, keep_rotations)

=============================
Log Monitoring Best Practices
=============================

**Essential Monitoring:**

.. code-block:: bash

    # Monitor disk usage (logs can fill disk)
    df -h /var/log
    
    # Find large log files
    find /var/log -type f -size +100M -exec ls -lh {} \;
    
    # Monitor log growth
    watch -n 5 'ls -lah /var/log/syslog'

**Security Monitoring:**

.. code-block:: bash

    # Monitor failed login attempts
    journalctl -u ssh --since today | grep "Failed password"
    
    # Check for privilege escalation
    journalctl --since today | grep -i sudo
    
    # Monitor file system events
    journalctl -k --since today | grep -i "filesystem\|mount"

.. note::

    **DevOps Tip**: Set up centralized logging with tools like ELK stack (Elasticsearch, Logstash, Kibana) or use cloud logging services for production environments.

===========
Cheat sheet
===========

.. code-block:: bash

    # print last 100 lines
    tail -n 100 /var/log/messages

    # follow log
    tail -f /var/log/secure

    # every journal entry that is in the system will be displayed
    journalctl

    # journal entries collected since the most recent reboot
    journalctl -b

    # display only kernel messages
    journalctl -k

    # display the last 20 messages
    journalctl -n 20

    # actively follow the logs as they are being written
    journalctl -f

    # filter messages by priority
    journalctl -p err

    # filter messages by the service unit
    journalctl -u sshd

    journalctl -u crond --since today

    # show listing of last logged-in users
    last                  

    # show a listing of users logged in since the last boot
    lastb

.. warning::

    The only problem with troubleshooting is that sometimes trouble shoots back.

=========
Questions
=========

1. What is the name of the daemon that controls log files in RHEL?

   a. ``rsyslogd``
   b. ``syslogd``
   c. ``logd``
   d. ``logrotate``

2. Which of the following log files contains information about emails relayed by the local mail server?

   a. ``/var/log/messages``
   b. ``/var/log/secure``
   c. ``/var/log/cron``
   d. ``/var/log/maillog``

3. Which of the following commands can be used to display the last 20 messages from the journal?

   a. ``journalctl -n 20``
   b. ``journalctl -f``
   c. ``journalctl -p err``
   d. ``journalctl -u sshd``

4. Which of the following commands can be used to display the last 20 lines of the ``/var/log/messages`` file?

   a. ``tail -n 20 /var/log/messages``
   b. ``tail -f /var/log/messages``
   c. ``tail -n 20 /var/log/messages``
   d. ``tail -n 20 /var/log/messages``

=======
Answers
=======

1. a
2. d
3. a
4. c

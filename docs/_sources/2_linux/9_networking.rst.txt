#####################
2.9 Linux Networking
#####################

#####################
2.9 Linux Networking
#####################

==================
Essential Concepts
==================

**Network Fundamentals for DevOps**

Modern DevOps networking spans from traditional server networking to container orchestration and cloud-native architectures.

**Network Types and Contexts:**

- **Host Networking**: Traditional server-to-server communication
- **Container Networking**: Docker networks, Kubernetes CNI
- **Cloud Networking**: VPCs, subnets, load balancers, CDNs
- **Service Mesh**: Istio, Linkerd for microservices communication
- **Overlay Networks**: VXLAN, Flannel, Calico for container orchestration

**Critical Protocols for DevOps:**

- **TCP**: Reliable transport for web services, databases, APIs
- **UDP**: Fast transport for DNS, monitoring, real-time data
- **HTTP/HTTPS**: Web services, REST APIs, webhooks (ports 80/443)
- **SSH**: Secure remote access and automation (port 22)
- **DNS**: Service discovery, load balancing (port 53)
- **ICMP**: Network diagnostics, health checks

**DevOps Networking Tools:**

.. code-block:: bash

    # Modern network interface management
    ip addr show                         # Show all interfaces and IPs
    ip route show                        # Display routing table
    ip link show                         # Show link layer information
    
    # Legacy tools (still useful)
    ifconfig                             # Interface configuration
    route -n                             # Routing table (numeric)
    
    # Connection monitoring
    ss -tuln                             # Socket statistics (modern netstat)
    ss -tulpn                            # Include process information
    netstat -tuln                        # Legacy connection listing
    lsof -i                              # List open network files
    lsof -i :80                          # Processes using port 80
    
    # Connectivity testing
    ping -c 4 google.com                 # ICMP connectivity test
    nc -zv hostname 22                   # Test TCP port connectivity
    telnet hostname 80                   # Interactive TCP connection
    curl -I https://example.com          # HTTP connectivity test
    
    # DNS resolution and testing
    nslookup example.com                 # Basic DNS lookup
    dig example.com                      # Detailed DNS information
    dig @8.8.8.8 example.com             # Query specific DNS server
    host example.com                     # Simple hostname lookup
    
    # Network discovery and scanning
    nmap -sn 192.168.1.0/24             # Network discovery scan
    nmap -p 22,80,443 hostname          # Port scanning
    arp -a                               # ARP table (MAC addresses)

**Container and Cloud Networking:**

.. code-block:: bash

    # Docker networking
    docker network ls                    # List Docker networks
    docker network inspect bridge       # Inspect network details
    docker run --network=host nginx     # Use host networking
    
    # Kubernetes networking
    kubectl get nodes -o wide           # Node IP addresses
    kubectl get services                 # Service endpoints
    kubectl get ingress                  # Ingress controllers
    
    # Cloud CLI examples
    aws ec2 describe-vpc                 # AWS VPC information
    gcloud compute networks list        # GCP network listing
    az network vnet list                 # Azure virtual networks

**Network Configuration Files and Management:**

.. code-block:: bash

    # Critical configuration files
    /etc/hosts                           # Local hostname resolution
    /etc/resolv.conf                     # DNS server configuration
    /etc/nsswitch.conf                   # Name service switch configuration
    /etc/network/interfaces              # Debian/Ubuntu interface config
    /etc/sysconfig/network-scripts/      # RHEL/CentOS network scripts
    /etc/netplan/*.yaml                  # Ubuntu 18+ network configuration

    # Systemd network management
    /etc/systemd/network/                # systemd-networkd configuration
    /etc/NetworkManager/                 # NetworkManager configuration

**Advanced Network Diagnostics:**

.. code-block:: bash

    # Traffic analysis
    tcpdump -i eth0 port 80              # Capture HTTP traffic
    tcpdump -i any -w capture.pcap       # Save packet capture
    wireshark                            # GUI packet analyzer
    
    # Bandwidth and performance
    iftop                                # Interface bandwidth usage
    nethogs                              # Per-process network usage
    iperf3 -s                            # Network performance server
    iperf3 -c server_ip                  # Network performance client
    
    # Network configuration and routing
    ip route add 192.168.2.0/24 via 192.168.1.1  # Add static route
    ip addr add 192.168.1.100/24 dev eth0         # Add IP address
    ip link set eth0 up                           # Bring interface up
    
    # Firewall and security
    iptables -L                          # List firewall rules
    ufw status                           # Ubuntu firewall status
    firewall-cmd --list-all              # RHEL/CentOS firewall

**DevOps Network Troubleshooting Methodology:**

1. **Layer 1 (Physical)**: Check cables, interface status, link lights
2. **Layer 2 (Data Link)**: Verify MAC addresses, switch configuration
3. **Layer 3 (Network)**: Test IP connectivity, routing, subnets
4. **Layer 4 (Transport)**: Check port accessibility, firewall rules
5. **Layer 7 (Application)**: Verify service functionality, DNS resolution

**Container Networking Concepts:**

.. code-block:: bash

    # Docker networking modes
    --network=bridge           # Default bridged networking
    --network=host             # Use host networking stack
    --network=none             # No networking
    --network=container:name   # Share another container's network
    
    # Kubernetes networking
    kubectl get pods -o wide   # Pod IP addresses
    kubectl get endpoints      # Service endpoints
    kubectl describe service myapp  # Service networking details

.. note::

    **Cloud-Native Networking**: Modern DevOps requires understanding of overlay networks, service meshes, and cloud networking constructs. Container networking differs significantly from traditional host networking.

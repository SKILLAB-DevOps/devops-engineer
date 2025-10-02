##########################
11.8.2 VPC and Networking
##########################

.. note::

    Google Cloud Virtual Private Cloud (VPC) provides networking functionality for your cloud-based resources and services. VPC networks are global resources that consist of regional subnets, connected by a global wide area network. GCP's network infrastructure is one of the largest and most advanced in the world, offering high performance, reliability, and security.

=======================
VPC Core Concepts
=======================

**VPC Network**

A VPC network is a virtual version of a physical network within Google Cloud. It provides:

- Global scope spanning all GCP regions
- No IP subnet limitations
- Built-in security with firewall rules
- Automatic or custom subnet modes

**Subnets**

Subnets are regional resources. Each subnet is associated with a region and has a contiguous private IP address range.

**Key Characteristics:**

- **Regional**: Subnets exist in a single region
- **Expandable**: Can expand IP ranges without recreation
- **Private Google Access**: Access Google services without external IP
- **Flow Logs**: Monitor network traffic

**IP Addressing**

- **Internal IP**: Private IP address for communication within the VPC
- **External IP**: Public IP address for internet communication
- **IP Ranges**: RFC 1918 private address spaces

=======================
Creating a VPC Network
=======================

**Auto Mode VPC (Default):**

.. code-block:: bash

    # Create auto-mode VPC (automatically creates subnets in all regions)
    gcloud compute networks create my-auto-vpc \
        --subnet-mode=auto \
        --bgp-routing-mode=regional \
        --mtu=1460
    
    # List all networks
    gcloud compute networks list
    
    # Describe network
    gcloud compute networks describe my-auto-vpc

Auto mode networks automatically create one subnet per region with predefined IP ranges:

- 10.128.0.0/20 in us-west1
- 10.138.0.0/20 in us-central1
- 10.148.0.0/20 in us-east1
- And so on...

**Custom Mode VPC (Recommended for Production):**

.. code-block:: bash

    # Create custom-mode VPC
    gcloud compute networks create my-custom-vpc \
        --subnet-mode=custom \
        --bgp-routing-mode=global \
        --mtu=1460
    
    # Create custom subnets
    gcloud compute networks subnets create my-subnet-us-central1 \
        --network=my-custom-vpc \
        --region=us-central1 \
        --range=10.0.1.0/24 \
        --enable-private-ip-google-access \
        --enable-flow-logs
    
    gcloud compute networks subnets create my-subnet-us-east1 \
        --network=my-custom-vpc \
        --region=us-east1 \
        --range=10.0.2.0/24 \
        --enable-private-ip-google-access \
        --enable-flow-logs
    
    # Create subnet with secondary ranges (for GKE)
    gcloud compute networks subnets create gke-subnet \
        --network=my-custom-vpc \
        --region=us-central1 \
        --range=10.0.10.0/24 \
        --secondary-range pods=10.1.0.0/16,services=10.2.0.0/20 \
        --enable-private-ip-google-access

**List and Describe Subnets:**

.. code-block:: bash

    # List all subnets
    gcloud compute networks subnets list
    
    # List subnets in specific network
    gcloud compute networks subnets list --network=my-custom-vpc
    
    # Describe subnet
    gcloud compute networks subnets describe my-subnet-us-central1 \
        --region=us-central1

**Expand Subnet Range:**

.. code-block:: bash

    # Expand subnet IP range (can only expand, not shrink)
    gcloud compute networks subnets expand-ip-range my-subnet-us-central1 \
        --region=us-central1 \
        --prefix-length=23  # Changes from /24 to /23

==============
Firewall Rules
==============

Firewall rules control traffic to and from instances in your VPC.

**Firewall Rule Components:**

- **Priority**: 0-65535 (lower number = higher priority)
- **Direction**: INGRESS (incoming) or EGRESS (outgoing)
- **Action**: ALLOW or DENY
- **Targets**: All instances, specific instances, or instances with tags
- **Source/Destination**: IP ranges, tags, or service accounts
- **Protocols and Ports**: TCP, UDP, ICMP, etc.

**Create Firewall Rules:**

.. code-block:: bash

    # Allow HTTP traffic
    gcloud compute firewall-rules create allow-http \
        --network=my-custom-vpc \
        --direction=INGRESS \
        --priority=1000 \
        --action=ALLOW \
        --rules=tcp:80 \
        --source-ranges=0.0.0.0/0 \
        --target-tags=http-server
    
    # Allow HTTPS traffic
    gcloud compute firewall-rules create allow-https \
        --network=my-custom-vpc \
        --direction=INGRESS \
        --priority=1000 \
        --action=ALLOW \
        --rules=tcp:443 \
        --source-ranges=0.0.0.0/0 \
        --target-tags=https-server
    
    # Allow SSH from specific IP range
    gcloud compute firewall-rules create allow-ssh \
        --network=my-custom-vpc \
        --direction=INGRESS \
        --priority=1000 \
        --action=ALLOW \
        --rules=tcp:22 \
        --source-ranges=203.0.113.0/24 \
        --target-tags=ssh-access
    
    # Allow internal communication between instances
    gcloud compute firewall-rules create allow-internal \
        --network=my-custom-vpc \
        --direction=INGRESS \
        --priority=1000 \
        --action=ALLOW \
        --rules=tcp:0-65535,udp:0-65535,icmp \
        --source-ranges=10.0.0.0/8
    
    # Allow health checks from Google load balancers
    gcloud compute firewall-rules create allow-health-checks \
        --network=my-custom-vpc \
        --direction=INGRESS \
        --priority=1000 \
        --action=ALLOW \
        --rules=tcp:80,tcp:443 \
        --source-ranges=35.191.0.0/16,130.211.0.0/22 \
        --target-tags=lb-backend

**Deny Rules (Higher Priority):**

.. code-block:: bash

    # Deny SSH from everywhere except office IP
    gcloud compute firewall-rules create deny-ssh-except-office \
        --network=my-custom-vpc \
        --direction=INGRESS \
        --priority=900 \
        --action=DENY \
        --rules=tcp:22 \
        --source-ranges=0.0.0.0/0 \
        --target-tags=production

**Service Account Based Rules:**

.. code-block:: bash

    # Allow traffic from specific service account
    gcloud compute firewall-rules create allow-from-sa \
        --network=my-custom-vpc \
        --direction=INGRESS \
        --priority=1000 \
        --action=ALLOW \
        --rules=tcp:3306 \
        --source-service-accounts=webapp@PROJECT_ID.iam.gserviceaccount.com \
        --target-tags=database

**List and Manage Firewall Rules:**

.. code-block:: bash

    # List all firewall rules
    gcloud compute firewall-rules list
    
    # List rules for specific network
    gcloud compute firewall-rules list --filter="network:my-custom-vpc"
    
    # Describe firewall rule
    gcloud compute firewall-rules describe allow-http
    
    # Update firewall rule
    gcloud compute firewall-rules update allow-http \
        --source-ranges=0.0.0.0/0,10.0.0.0/8
    
    # Delete firewall rule
    gcloud compute firewall-rules delete allow-http

=========
Cloud NAT
=========

Cloud NAT (Network Address Translation) allows instances without external IP addresses to access the internet.

**Create Cloud Router:**

.. code-block:: bash

    # Cloud Router is required for Cloud NAT
    gcloud compute routers create my-router \
        --network=my-custom-vpc \
        --region=us-central1 \
        --asn=65001

**Create Cloud NAT:**

.. code-block:: bash

    # Create NAT configuration
    gcloud compute routers nats create my-nat \
        --router=my-router \
        --region=us-central1 \
        --nat-all-subnet-ip-ranges \
        --auto-allocate-nat-external-ips
    
    # Create NAT with specific IP addresses
    gcloud compute addresses create nat-ip-1 --region=us-central1
    gcloud compute addresses create nat-ip-2 --region=us-central1
    
    gcloud compute routers nats create my-nat-static \
        --router=my-router \
        --region=us-central1 \
        --nat-all-subnet-ip-ranges \
        --nat-external-ip-pool=nat-ip-1,nat-ip-2
    
    # Enable logging
    gcloud compute routers nats update my-nat \
        --router=my-router \
        --region=us-central1 \
        --enable-logging

**List and Describe NAT:**

.. code-block:: bash

    # List Cloud NAT configurations
    gcloud compute routers nats list --router=my-router --region=us-central1
    
    # Describe NAT configuration
    gcloud compute routers nats describe my-nat \
        --router=my-router \
        --region=us-central1

====================
Cloud Load Balancing
====================

GCP offers several types of load balancers:

- **Global External Load Balancer**: HTTP(S), SSL Proxy, TCP Proxy
- **Regional External Load Balancer**: Network TCP/UDP, Internal TCP/UDP
- **Internal Load Balancer**: HTTP(S), TCP/UDP

**Create HTTP(S) Load Balancer:**

.. code-block:: bash

    # 1. Create instance group
    gcloud compute instance-groups managed create web-backend-group \
        --zone=us-central1-a \
        --template=web-server-template \
        --size=3
    
    # Set named port
    gcloud compute instance-groups managed set-named-ports web-backend-group \
        --named-ports=http:80 \
        --zone=us-central1-a
    
    # 2. Create health check
    gcloud compute health-checks create http web-health-check \
        --port=80 \
        --request-path=/health \
        --check-interval=10s \
        --timeout=5s \
        --healthy-threshold=2 \
        --unhealthy-threshold=3
    
    # 3. Create backend service
    gcloud compute backend-services create web-backend-service \
        --protocol=HTTP \
        --health-checks=web-health-check \
        --global \
        --enable-cdn \
        --connection-draining-timeout=300
    
    # Add instance group to backend
    gcloud compute backend-services add-backend web-backend-service \
        --instance-group=web-backend-group \
        --instance-group-zone=us-central1-a \
        --balancing-mode=UTILIZATION \
        --max-utilization=0.8 \
        --global
    
    # 4. Create URL map
    gcloud compute url-maps create web-url-map \
        --default-service=web-backend-service
    
    # 5. Create SSL certificate (for HTTPS)
    gcloud compute ssl-certificates create web-ssl-cert \
        --domains=www.example.com
    
    # Or use managed certificate
    gcloud compute ssl-certificates create web-ssl-cert \
        --domains=www.example.com \
        --global
    
    # 6. Create target HTTPS proxy
    gcloud compute target-https-proxies create web-https-proxy \
        --url-map=web-url-map \
        --ssl-certificates=web-ssl-cert
    
    # 7. Create forwarding rule
    gcloud compute forwarding-rules create web-https-rule \
        --address=web-lb-ip \
        --global \
        --target-https-proxy=web-https-proxy \
        --ports=443

**Create Network Load Balancer:**

.. code-block:: bash

    # Create target pool
    gcloud compute target-pools create web-pool \
        --region=us-central1 \
        --health-check=web-health-check
    
    # Add instances to target pool
    gcloud compute target-pools add-instances web-pool \
        --instances=web-server-1,web-server-2,web-server-3 \
        --zone=us-central1-a
    
    # Create forwarding rule
    gcloud compute forwarding-rules create web-lb-rule \
        --region=us-central1 \
        --ports=80 \
        --target-pool=web-pool

===========
VPC Peering
===========

VPC Network Peering allows private connectivity between two VPC networks.

**Create VPC Peering:**

.. code-block:: bash

    # From VPC-A to VPC-B
    gcloud compute networks peerings create vpc-a-to-vpc-b \
        --network=vpc-a \
        --peer-project=PROJECT_B_ID \
        --peer-network=vpc-b \
        --auto-create-routes
    
    # From VPC-B to VPC-A (must be done in PROJECT_B)
    gcloud compute networks peerings create vpc-b-to-vpc-a \
        --network=vpc-b \
        --peer-project=PROJECT_A_ID \
        --peer-network=vpc-a \
        --auto-create-routes
    
    # List peering connections
    gcloud compute networks peerings list
    
    # Describe peering
    gcloud compute networks peerings list --network=vpc-a

=========
Cloud VPN
=========

Cloud VPN securely connects your on-premises network to your GCP VPC.

**Create HA VPN:**

.. code-block:: bash

    # 1. Create VPN gateway
    gcloud compute vpn-gateways create my-ha-vpn-gateway \
        --network=my-custom-vpc \
        --region=us-central1
    
    # 2. Create external VPN gateway (represents on-prem device)
    gcloud compute external-vpn-gateways create on-prem-gateway \
        --interfaces=0=ON_PREM_IP_ADDRESS
    
    # 3. Create Cloud Router
    gcloud compute routers create vpn-router \
        --region=us-central1 \
        --network=my-custom-vpc \
        --asn=65001
    
    # 4. Create VPN tunnels
    gcloud compute vpn-tunnels create tunnel-1 \
        --peer-external-gateway=on-prem-gateway \
        --peer-external-gateway-interface=0 \
        --region=us-central1 \
        --ike-version=2 \
        --shared-secret=SHARED_SECRET \
        --router=vpn-router \
        --vpn-gateway=my-ha-vpn-gateway \
        --interface=0
    
    # 5. Create BGP sessions
    gcloud compute routers add-interface vpn-router \
        --interface-name=tunnel-1-int \
        --ip-address=169.254.1.1 \
        --mask-length=30 \
        --vpn-tunnel=tunnel-1 \
        --region=us-central1
    
    gcloud compute routers add-bgp-peer vpn-router \
        --peer-name=bgp-peer-1 \
        --interface=tunnel-1-int \
        --peer-ip-address=169.254.1.2 \
        --peer-asn=65002 \
        --region=us-central1

=====================
Private Google Access
=====================

Allow instances without external IPs to access Google services.

.. code-block:: bash

    # Enable Private Google Access on subnet
    gcloud compute networks subnets update my-subnet-us-central1 \
        --region=us-central1 \
        --enable-private-ip-google-access
    
    # Verify
    gcloud compute networks subnets describe my-subnet-us-central1 \
        --region=us-central1 \
        --format="get(privateIpGoogleAccess)"

=========
Cloud DNS
=========

**Create DNS Zone:**

.. code-block:: bash

    # Create public DNS zone
    gcloud dns managed-zones create my-zone \
        --dns-name=example.com. \
        --description="My DNS zone"
    
    # Create private DNS zone
    gcloud dns managed-zones create my-private-zone \
        --dns-name=internal.example.com. \
        --description="Internal DNS zone" \
        --visibility=private \
        --networks=my-custom-vpc

**Add DNS Records:**

.. code-block:: bash

    # Start transaction
    gcloud dns record-sets transaction start --zone=my-zone
    
    # Add A record
    gcloud dns record-sets transaction add \
        --zone=my-zone \
        --name=www.example.com. \
        --type=A \
        --ttl=300 \
        "203.0.113.10"
    
    # Add CNAME record
    gcloud dns record-sets transaction add \
        --zone=my-zone \
        --name=blog.example.com. \
        --type=CNAME \
        --ttl=300 \
        "www.example.com."
    
    # Execute transaction
    gcloud dns record-sets transaction execute --zone=my-zone
    
    # List records
    gcloud dns record-sets list --zone=my-zone

==================
Network Monitoring
==================

**Enable VPC Flow Logs:**

.. code-block:: bash

    # Enable on existing subnet
    gcloud compute networks subnets update my-subnet-us-central1 \
        --region=us-central1 \
        --enable-flow-logs \
        --logging-aggregation-interval=interval-5-sec \
        --logging-flow-sampling=0.5 \
        --logging-metadata=include-all

**View Flow Logs:**

.. code-block:: bash

    # Query flow logs
    gcloud logging read "resource.type=gce_subnetwork" \
        --limit=10 \
        --format=json

**Network Intelligence Center:**

.. code-block:: bash

    # Get connectivity test
    gcloud network-management connectivity-tests create my-test \
        --source-instance=source-vm \
        --destination-ip-address=10.0.1.10 \
        --protocol=TCP \
        --destination-port=80

==============
Best Practices
==============

**1. Network Design:**

- Use custom VPC for production workloads
- Plan IP addressing carefully (use RFC 1918 ranges)
- Separate environments into different VPCs
- Use VPC peering or Shared VPC for multi-project architectures
- Implement least-privilege firewall rules

**2. Security:**

.. code-block:: bash

    # Use default-deny firewall rules
    gcloud compute firewall-rules create deny-all-ingress \
        --network=my-custom-vpc \
        --direction=INGRESS \
        --priority=65534 \
        --action=DENY \
        --rules=all
    
    # Allow only specific traffic
    gcloud compute firewall-rules create allow-specific \
        --network=my-custom-vpc \
        --direction=INGRESS \
        --priority=1000 \
        --action=ALLOW \
        --rules=tcp:443 \
        --source-ranges=203.0.113.0/24

**3. High Availability:**

- Use multiple zones for instances and load balancers
- Implement health checks for all backend services
- Use managed instance groups with autoscaling
- Configure connection draining for graceful shutdowns

**4. Cost Optimization:**

- Use Cloud NAT instead of external IPs
- Implement network tiers (Premium vs Standard)
- Use committed use discounts for VPN and load balancers
- Monitor egress traffic costs

===============
Troubleshooting
===============

**Test Connectivity:**

.. code-block:: bash

    # From an instance, test connectivity
    gcloud compute ssh my-instance --zone=us-central1-a --command="ping -c 3 8.8.8.8"
    
    # Test internal connectivity
    gcloud compute ssh my-instance --zone=us-central1-a --command="ping -c 3 10.0.1.10"
    
    # Test DNS resolution
    gcloud compute ssh my-instance --zone=us-central1-a --command="nslookup google.com"

**Check Firewall Rules:**

.. code-block:: bash

    # List applicable firewall rules for an instance
    gcloud compute instances describe my-instance \
        --zone=us-central1-a \
        --format="get(tags.items)"
    
    # Find firewall rules for specific tags
    gcloud compute firewall-rules list \
        --filter="targetTags:http-server"

**Packet Mirroring:**

.. code-block:: bash

    # Create packet mirroring policy for troubleshooting
    gcloud compute packet-mirrorings create my-mirror \
        --region=us-central1 \
        --network=my-custom-vpc \
        --mirrored-subnets=my-subnet-us-central1 \
        --collector-ilb=my-collector-forwarding-rule

====================
Additional Resources
====================

- VPC Documentation: https://cloud.google.com/vpc/docs
- Firewall Rules Guide: https://cloud.google.com/vpc/docs/firewalls
- Load Balancing Documentation: https://cloud.google.com/load-balancing/docs
- VPC Network Peering: https://cloud.google.com/vpc/docs/vpc-peering
- Cloud VPN Documentation: https://cloud.google.com/network-connectivity/docs/vpn

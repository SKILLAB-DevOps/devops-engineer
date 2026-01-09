####
TODO
####


This section contains practical exercises designed to build your Linux administration skills progressively. Each task simulates real DevOps scenarios you'll encounter in production environments.

.. note::

    **Learning Approach:**
    
    1. **Quick Assessment**: Answer knowledge questions to identify learning gaps
    2. **Hands-On Practice**: Complete practical tasks in a safe environment
    3. **Validate Solutions**: Check ANSWERS.rst for detailed explanations and code
    4. **Apply Knowledge**: Use skills in real projects and automation

===============
Quick Questions
===============

**Test your Linux fundamentals. Solutions in ANSWERS.rst include explanations and context.**

1. **Which command shows all running processes with their resource usage in real-time?**

2. **How do you make a script executable for the owner only while keeping it readable by the group?**

3. **What's the difference between `apt`, `snap`, and container-based package management?**

4. **Which command shows real-time system resource usage including CPU, memory, and I/O?**

5. **How do you create a service user for a web application with no shell access?**

6. **What does `/etc/fstab` contain and why is it critical for system boot?**

7. **How do you follow logs from multiple services simultaneously?**

8. **Which command identifies which process is using a specific network port?**

9. **What's the difference between `systemctl enable` and `systemctl start`?**

10. **How do you securely store secrets in configuration files with proper permissions?**

===============
Practical Tasks
===============

**Complete these hands-on exercises to build production-ready skills. Estimated time: 15-30 minutes each.**

**Task 1: DevOps User Management Automation**

*Scenario*: You need to set up user accounts for a new development team with proper security and permissions.

Requirements:
- Create a Python script that manages DevOps team user accounts
- Support creating users with SSH key authentication
- Assign users to appropriate groups (docker, sudo, developers)
- Implement user auditing and permission reporting
- Include proper error handling and logging

*Success Criteria*: Script creates secure users, sets up SSH keys, and generates audit reports

**Task 2: System Health Monitoring Dashboard**

*Scenario*: Build a monitoring solution for critical system metrics in a production environment.

Requirements:
- Create a Python dashboard showing real-time system health
- Monitor CPU, memory, disk usage, network activity, and critical services
- Include alerting for threshold breaches
- Save metrics history for trend analysis
- Support multiple output formats (console, JSON, HTML)

*Success Criteria*: Dashboard provides actionable insights and early warning of issues

**Task 3: Log Analysis and Security Monitoring**

*Scenario*: Analyze system and application logs to identify security issues and performance problems.

Requirements:
- Build a Python log analyzer for common log formats (syslog, nginx, apache)
- Detect security patterns (failed logins, unusual activity)
- Generate summary reports with actionable insights
- Support real-time monitoring and historical analysis
- Include export functionality for security teams

*Success Criteria*: Tool identifies security threats and performance bottlenecks

**Task 4: Automated Configuration Management**

*Scenario*: Manage configuration files across multiple servers with version control and rollback capability.

Requirements:
- Create a Python tool for managing configuration files
- Include backup and rollback functionality
- Support templating and environment-specific configurations
- Validate configuration files before deployment
- Integrate with version control systems

*Success Criteria*: Tool safely manages configs with zero-downtime deployments

**Task 5: Service Health and Dependency Management**

*Scenario*: Monitor critical services and automatically handle failures in a microservices environment.

Requirements:
- Build a service health monitor for systemd services
- Include dependency checking and cascade failure prevention
- Implement intelligent restart strategies
- Generate service dependency maps
- Support integration with external monitoring systems

*Success Criteria*: Monitor ensures service availability and quick recovery

**Task 6: Container-Ready System Preparation**

*Scenario*: Prepare Linux systems for container workloads with proper security and optimization.

Requirements:
- Create a system preparation script for container hosts
- Configure proper user namespaces and security
- Set up resource limits and monitoring
- Prepare for Kubernetes node deployment
- Include security hardening and compliance checks

*Success Criteria*: System is optimized and secured for container workloads

**Task 7: Infrastructure as Code Integration**

*Scenario*: Bridge the gap between manual Linux administration and Infrastructure as Code.

Requirements:
- Build tools that generate Ansible playbooks from current system state
- Create Terraform modules based on system configuration
- Include drift detection between desired and actual state
- Support compliance reporting and remediation
- Generate documentation automatically

*Success Criteria*: Tools enable seamless transition to IaC practices

**Task 8: Cloud-Native Linux Operations**

*Scenario*: Adapt traditional Linux operations for cloud-native environments.

Requirements:
- Create cloud metadata integration tools
- Build auto-scaling preparation scripts
- Implement cloud storage integration
- Configure cloud-native monitoring and logging
- Support multi-cloud deployment scenarios

*Success Criteria*: Linux systems integrate seamlessly with cloud platforms

- Create a Python tool that manages software packages across distributions
- Support apt, dnf/yum, and snap package managers
- Success: Tool installs and updates software regardless of distribution

**Task 10: System Security Auditor**

- Write a Python script that performs basic security audits
- Check user permissions, open ports, and system configurations
- Success: Tool identifies potential security issues and recommendations

=================
Discussion Topics
=================

**Think through these open-ended questions. No single "correct" answer - focus on understanding trade-offs and real-world applications.**

**1. Linux distribution selection strategy**

How would you choose a Linux distribution for different use cases (development, production servers, containers, desktop)? What factors influence your decision, and how do you balance stability versus features?

**2. System hardening and security practices**

Design a comprehensive security strategy for Linux servers. Consider user management, network security, file permissions, monitoring, and compliance requirements. What tools and practices would you implement?

**3. Performance optimization methodology**

Develop a systematic approach to diagnosing and resolving Linux performance issues. How would you identify bottlenecks in CPU, memory, disk I/O, and network? What tools and techniques are most effective?

**4. Automation vs manual administration**

When should you automate Linux administration tasks versus performing them manually? How do you balance the investment in automation scripts with the need for immediate solutions? What tasks are best automated first?

**5. Disaster recovery and business continuity**

Design a comprehensive disaster recovery plan for Linux-based infrastructure. Consider backup strategies, system recovery procedures, and business continuity requirements. How would you test and maintain the plan?


==========
Next Steps
==========

After completing this chapter:

1. **Practice in Real Environments**: Apply skills to actual projects
2. **Explore Specializations**: Container orchestration, cloud platforms, security
3. **Join Communities**: Linux user groups, DevOps meetups, online forums
4. **Continuous Learning**: Stay updated with new tools and practices
5. **Certification Paths**: Consider RHCSA, LFCS, or cloud certifications

**Recommended Learning Resources:**

- Linux Foundation training courses
- Red Hat Learning Subscription
- Cloud provider documentation and labs
- Open source project contributions
- DevOps community conferences and webinars

.. note::

    **Remember**: Linux mastery comes through consistent practice and real-world application. Start with the basics, build solid foundations, and gradually tackle more complex challenges. Every expert was once a beginner.

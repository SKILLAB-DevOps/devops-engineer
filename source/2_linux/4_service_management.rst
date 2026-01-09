######################
2.4 Service Management
######################

==========================
systemd Service Management
==========================

Modern Linux systems use **systemd** to manage services. Essential for DevOps automation and monitoring.

**Core Commands:**

.. code-block:: bash

    # Service status and control
    systemctl status service_name
    sudo systemctl start service_name
    sudo systemctl stop service_name
    sudo systemctl restart service_name
    sudo systemctl reload service_name
    
    # Enable/disable services (auto-start at boot)
    sudo systemctl enable service_name
    sudo systemctl disable service_name
    
    # List services
    systemctl list-units --type=service
    systemctl list-units --type=service --state=active
    systemctl list-units --type=service --state=failed

**Common Services:**

.. code-block:: bash

    # Web servers
    sudo systemctl status nginx
    sudo systemctl status apache2
    
    # Databases
    sudo systemctl status mysql
    sudo systemctl status postgresql
    
    # SSH
    sudo systemctl status ssh
    sudo systemctl status sshd
    
    # System services
    sudo systemctl status docker
    sudo systemctl status firewalld

========================
Creating Custom Services
========================

**Service File Location:**

.. code-block:: bash

    /etc/systemd/system/myservice.service

**Modern Service File Example:**

.. code-block:: ini

    [Unit]
    Description=Modern Python Web Application
    Documentation=https://myapp.example.com/docs
    After=network-online.target
    Wants=network-online.target
    Requires=postgresql.service
    
    [Service]
    Type=notify
    User=appuser
    Group=appuser
    WorkingDirectory=/opt/myapp
    Environment=PYTHONPATH=/opt/myapp
    Environment=DJANGO_SETTINGS_MODULE=myapp.settings.production
    EnvironmentFile=-/etc/myapp/environment
    ExecStartPre=/opt/myapp/scripts/pre-start.sh
    ExecStart=/opt/myapp/venv/bin/python manage.py runserver 0.0.0.0:8000
    ExecReload=/bin/kill -HUP $MAINPID
    ExecStop=/bin/kill -TERM $MAINPID
    Restart=always
    RestartSec=10
    TimeoutStartSec=30
    TimeoutStopSec=30
    
    # Security settings
    NoNewPrivileges=yes
    ProtectSystem=strict
    ProtectHome=yes
    ReadWritePaths=/var/lib/myapp /var/log/myapp
    PrivateTmp=yes
    PrivateDevices=yes
    ProtectKernelTunables=yes
    ProtectControlGroups=yes
    RestrictRealtime=yes
    
    # Resource limits
    LimitNOFILE=1024
    MemoryMax=512M
    CPUQuota=50%
    
    [Install]
    WantedBy=multi-user.target

**Advanced Service Management:**

.. code-block:: bash

    # Service dependency management
    systemctl list-dependencies service_name     # Show dependencies
    systemctl list-dependencies --reverse nginx  # Show what depends on nginx
    
    # Performance and resource monitoring
    systemctl show service_name --property=CPUShares,MemoryLimit
    systemd-cgtop                                # Real-time resource usage
    
    # Service security and isolation
    systemctl show service_name --property=User,Group,NoNewPrivileges
    systemd-analyze security service_name        # Security analysis
    
    # Troubleshooting failed services
    systemctl status service_name --no-page      # Detailed status
    systemctl cat service_name                   # Show service file
    systemd-analyze verify service_name          # Validate service file

**Container Integration:**

.. code-block:: bash

    # Podman/Docker integration with systemd
    podman generate systemd --new --name myapp > /etc/systemd/system/myapp.service
    systemctl daemon-reload
    systemctl enable myapp.service
    
    # User services (rootless containers)
    systemctl --user enable myapp.service
    loginctl enable-linger username              # Enable user services at boot

===========================
Logging and Troubleshooting
===========================

**Service Logs:**

.. code-block:: bash

    # View service logs
    journalctl -u service_name
    journalctl -u service_name -f        # Follow logs
    journalctl -u service_name --since today
    journalctl -u service_name --since "2024-01-01"
    
    # System logs
    journalctl -p err                     # Error messages only
    journalctl --since "1 hour ago"      # Recent logs

**Troubleshooting Steps:**

1. Check service status: `systemctl status service_name`
2. View recent logs: `journalctl -u service_name -n 50`
3. Check configuration files for syntax errors
4. Verify user permissions and file ownership
5. Test service manually outside systemd

.. note::

    **DevOps Tip**: Always test service configurations in development before deploying to production. Use `systemctl --user` for user services that don't require root privileges.

=========  =================================================================================================================================
Swap       A unit of this type encapsulates/activates/deactivates swap partition
Path       A unit of this type monitors files/directories and activates/deactivates a service if the specified file or directory is accessed
Timer      A unit of this type activates/deactivates specified service based on a timer or when the set time is elapsed
Snapshot   A unit that creates and saves the current state of all running units. This state can be used to restore the system later
Slice      A group of units that manages system resources such as CPU, and memory
Scope      A unit that organizes and manages foreign processes
=========  =================================================================================================================================

The following table briefly explains the terms that the systemd uses to describe the status of units.

============== =============================================================================================================================================
Status         Description
============== =============================================================================================================================================
loaded         The unit's configuration file has been successfully read and processed
active exited  Successfully executed the one-time configuration and after execution, the unit is neither running an active process nor waiting for an event
active running Successfully executed the one-time configuration and after execution, the unit is running one or more active processes
active waiting Successfully executed the one-time configuration and after execution, the unit is waiting for an event
inactive dead  Either the one-time configuration failed to execute or not executed yet
============== =============================================================================================================================================

===============
systemd targets
===============

systemd replaces traditional SysVinit **runlevels** with predefined groups of units called **targets**.

Targets are usually defined according to the intended use of the system, and ensure that the required dependencies for that use are met.

The following table shows some standard preconfigured targets, the sysVinit runlevels they resemble, and the use case they address.

========== ======== ======================================================================================
Target     Runlevel Usage
========== ======== ======================================================================================
rescue     1        single-user mode, for recovery of critical system components or configuration
multi-user 2        non-graphical multi-user console access, via local TTYs or network
graphical  5        a GUI sessions. Typically, provides the user with a fully featured desktop environment
custom     4        systemd allows any number of custom-defined targets
========== ======== ======================================================================================

The standard LINUX kernel supports these seven different runlevels :

    * 0 - System halt the system can be safely powered off with no activity.
    * 1 - Single user mode.
    * 2 - Multiple user mode with no NFS(network file system).
    * 3 - Multiple user mode under the command line interface and not under the graphical user interface.
    * 4 - User-definable.
    * 5 - Multiple user mode under GUI (graphical user interface) and this is the standard runlevel for most of the LINUX-based systems.
    * 6 - Reboot which is used to restart the system.

=============
REDHAT FAMILY
=============

.. code-block:: bash

    # List all loaded service units
    systemctl list-units --type=service

    # Check status for NAME service unit
    systemctl status NAME

    # Check if NAME service is enabled
    systemctl is-enabled NAME

    # Check start|stop|restart NAME service
    systemctl start|stop|restart NAME

    # Enable|disable NAME service
    systemctl enable|disable NAME

    # Get default target
    systemctl get-default


.. warning::

    Linux is user-friendly, but it's just very selective about who its friends are.

=========
Questions
=========

1. What is the difference between a service and a daemon?   
    a. A daemon is a program that runs in the background, while a service is a daemon that is started by systemd.
    b. A daemon is a program that runs in the background, while a service is a program that runs in the foreground.
    c. A daemon is a program that runs in the foreground, while a service is a program that runs in the background.
    d. A daemon is a program that runs in the foreground, while a service is a daemon that is started by systemd.

2. Which of the following is not a systemd unit type?
    a. Service
    b. Device
    c. Target
    d. Scope

3. Which of the following is not a systemd target?
    a. rescue
    b. multi-user
    c. graphical
    d. custom

4. Which of the following is not a valid systemd command?
    a. systemctl list-units --type=service
    b. systemctl status NAME
    c. systemctl is-enabled NAME
    d. systemctl update NAME

5. What is the default target in systemd?
    a. rescue
    b. multi-user
    c. graphical
    d. custom

6. How do you check the status of a service?
    a. systemctl status NAME
    b. systemctl list-units --type=service
    c. systemctl is-enabled NAME
    d. systemctl update NAME

7. How do you check if a service is enabled?
    a. systemctl status NAME
    b. systemctl list-units --type=service
    c. systemctl is-enabled NAME
    d. systemctl update NAME

=======
Answers
=======

1. A daemon is a program that runs in the background, while a service is a daemon that is started by systemd.
2. Target
3. custom
4. systemctl update NAME
5. graphical
6. systemctl status NAME
7. systemctl is-enabled NAME
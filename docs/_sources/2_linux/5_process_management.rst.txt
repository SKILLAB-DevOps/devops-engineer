######################
2.5 Process Management
######################

=======================
Understanding Processes
=======================

Every running program is a **process** with a unique Process ID (PID). Process management is critical for system performance, troubleshooting, and DevOps automation.

**Key Concepts:**

- **PID**: Unique process identifier (1-65535)
- **PPID**: Parent process ID (process hierarchy)
- **UID/GID**: User and group running the process
- **Process States**: Running, Sleeping, Stopped, Zombie
- **Child Processes**: Spawned by parent processes
- **Zombie Processes**: Finished but not cleaned up by parent
- **Orphan Processes**: Parent process has terminated
- **Process Priority**: Nice values (-20 to 19, lower = higher priority)

**DevOps Context:**

In modern DevOps environments, process management involves:

- **Container Processes**: Managing processes inside containers
- **Service Orchestration**: Process lifecycle in Kubernetes pods
- **Microservices Monitoring**: Tracking distributed application processes
- **Resource Optimization**: CPU and memory allocation for workloads
- **Autoscaling**: Process-based scaling decisions

===========================
Process Monitoring Commands
===========================

**Enhanced Process Listing:**

.. code-block:: bash

    # Comprehensive process information
    ps aux                           # All processes with resource usage
    ps -ef                           # All processes with full details
    ps -eo pid,ppid,cmd,%cpu,%mem,user  # Custom format
    ps --forest                      # Process tree format
    
    # Modern alternatives
    pstree -p                        # Process tree with PIDs
    pstree -u                        # Show user transitions
    
    # Container-aware process listing
    ps -eo pid,ppid,cmd,cgroup       # Show control groups
    systemd-cgls                     # systemd control group tree

**Real-Time Process Monitoring:**

.. code-block:: bash

    # Interactive monitoring tools
    top                              # Classic process monitor
    htop                             # Enhanced with colors and mouse support
    btop                             # Modern resource monitor (install: apt install btop)
    
    # Specialized monitoring
    iotop                            # Disk I/O per process (requires sudo)
    nethogs                          # Network usage per process
    powertop                         # Power consumption analysis
    
    # Advanced system monitoring
    glances                          # All-in-one system monitor
    nmon                             # Performance monitoring tool

**Process Discovery and Analysis:**

.. code-block:: bash

    # Find processes by various criteria
    pgrep -f "python.*django"        # Find by full command line
    pgrep -u username                # Find processes by user
    pgrep -g groupname               # Find by group
    pidof nginx                      # Get PID of specific process
    
    # Process resource analysis
    cat /proc/PID/status             # Detailed process information
    cat /proc/PID/limits             # Process resource limits
    lsof -p PID                      # Files opened by process
    strace -p PID                    # System calls (debugging)
    
    # Container process analysis
    docker top container_name        # Processes in container
    kubectl top pods                 # Kubernetes pod resource usage

**Advanced Process Control:**

.. code-block:: bash

    # Signal management
    kill -l                          # List all available signals
    kill -TERM PID                   # Graceful termination (default)
    kill -KILL PID                   # Force termination (use sparingly)
    kill -HUP PID                    # Hang up (reload config for daemons)
    kill -USR1 PID                   # User-defined signal 1
    
    # Bulk process management
    killall -TERM nginx              # Kill all nginx processes
    pkill -f "python.*celery"        # Kill processes matching pattern
    killall -u username              # Kill all processes by user (dangerous!)
    
    # Process priority management
    nice -n 10 command               # Start with lower priority
    renice -n 5 -p PID               # Change priority of running process
    ionice -c 3 -p PID               # Set I/O scheduling priority
    
    # Job control (interactive shells)
    command &                        # Run in background
    jobs                             # List background jobs
    fg %1                            # Bring job 1 to foreground
    bg %1                            # Send job 1 to background
    disown %1                        # Remove job from shell control
    nohup command &                  # Run immune to hangups
    
    # Screen/tmux for persistent sessions
    screen -S session_name           # Create named screen session
    tmux new -s session_name         # Create named tmux session
    tmux attach -t session_name      # Attach to existing session

**Container and Cloud Process Management:**

.. code-block:: bash

    # Docker process management
    docker exec -it container bash   # Enter container for process management
    docker kill container            # Send SIGKILL to container
    docker stop container            # Send SIGTERM, then SIGKILL
    
    # Kubernetes process management
    kubectl exec -it pod -- ps aux   # List processes in pod
    kubectl delete pod pod_name      # Restart pod (processes)
    
    # Systemd integration
    systemd-run --user command       # Run as systemd service
    systemctl --user status          # User service status


**Process Resource Analysis:**

.. code-block:: bash

    # Top resource consumers
    echo "=== Top CPU Consumers ==="
    ps aux --sort=-%cpu | head -10
    
    echo -e "\n=== Top Memory Consumers ==="
    ps aux --sort=-%mem | head -10
    
    echo -e "\n=== Process Tree ==="
    pstree -p
    
    # System load and resource summary
    echo -e "\n=== System Load ==="
    uptime
    echo -e "\n=== Memory Usage ==="
    free -h
    echo -e "\n=== Disk Usage ==="
    df -h


===================
Resource Management
===================

**Resource Monitoring:**

.. code-block:: bash

    # CPU and memory usage
    top -b -n 1               # Single snapshot
    vmstat 1 5                # VM statistics every 1 sec, 5 times
    iostat 1 5                # I/O statistics
    
    # Memory details
    free -h                   # Human readable memory info
    cat /proc/meminfo         # Detailed memory info
    
    # Open files and processes
    lsof                      # List open files
    lsof -p PID              # Files opened by specific process
    lsof -i :80              # Processes using port 80

**Process Limits:**

.. code-block:: bash

    # View limits
    ulimit -a                 # All current limits
    cat /proc/PID/limits      # Limits for specific process
    
    # Set limits
    ulimit -n 4096           # Max open files
    ulimit -u 1024           # Max user processes
    ulimit -m 1048576        # Max memory (KB)

.. warning::

    **Dangerous Commands**: Never run `kill -9 1` (kills init process) or `killall -9 python` without being specific about which processes you want to terminate.

	# To kill the process
	kill PROCESS_ID

===============
kill vs kill -9
===============

The secure and appropriate method of ending a process is kill, often known as ``kill -TERM`` or ``kill -15``. It is comparable to properly turning off a computer.
The risky method of brutally murdering a process is ``kill -9``. It might corrupt the data and is similar to unplugging the power wire.

-------------------
Process Cheat sheet
-------------------

.. code-block:: bash

	# List all running processes
	ps aux

	# List all running processes in extra wide format
	# useful to display long commands that are trimmed by default
	ps auxww

	# Hierarchy list all running processes
	ps auxf

	# terminate process
	kill PID

	# forcefully terminate process
	kill -9 PID

	# returns a list of PIDs that have "keyword" in the command field
	pgrep -f "keyword"

	# terminates all PIDs that have "keyword" in the command field
	pkill -f "keyword"  

	# run "command" and send it in the background
	command &

	# detach command from tty and run it in the background
	# send stdout and stderr to the cmd.log file
	nohup command 2>&1 > cmd.log &

	# allows you to execute a command or program periodically and also shows your output on the screen which means that you will be able to see the program output in time. By default, watch re-runs the command/program every 2 seconds. The interval can be easily changed to meet your requirements.
	watch free -m
	
	# display commands sent to run in the background
	jobs

	# bring the last command sent to the background in the foreground
	fg

	# resume commands paused with CTRL-Z
	bg

.. warning::

	Thou shalt not kill -9

=========
Questions
=========

1. What is a process?

   a. A program that is running on the system
   b. A program that is running on the system and has a PID
   c. A program that is running on the system and has a parent process
   d. A program that is running on the system and has a parent process and a PID

2. What is a PID?

   a. A unique identification number assigned to a process
   b. A unique identification number assigned to a process by the kernel
   c. A unique identification number assigned to a process by the kernel that is used to manage and control the process through its lifecycle
   d. A unique identification number assigned to a process by the kernel that is used to manage and control the process through its lifecycle and is reported back to its parent process when the process completes its lifecycle or is terminated

3. What is the correct way to terminate a process?

   a. kill -9 PID
   b. kill -TERM PID
   c. kill PID
   d. kill -15 PID

4. What is the correct way to terminate a process that is not responding?

   a. kill -9 PID
   b. kill -TERM PID
   c. kill PID
   d. kill -15 PID

5. What is the correct way to terminate a process that is not responding and is not terminating with kill -9?

   a. kill -9 PID
   b. kill -TERM PID
   c. kill PID
   d. kill -15 PID

=======
Answers
=======

1. d
2. d
3. b
4. a
5. a
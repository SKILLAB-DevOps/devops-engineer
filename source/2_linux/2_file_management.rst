###################
2.2 File Management
###################

=========================
Linux Directory Structure
=========================

**Essential Directories for DevOps:**

.. code-block:: bash

    /                      # Root filesystem
    ├── bin/              # Essential user commands (ls, cat, cp)
    ├── sbin/             # System administration commands
    ├── etc/              # System configuration files
    │   ├── systemd/      # Service definitions
    │   ├── nginx/        # Web server config
    │   ├── ssh/          # SSH configuration
    │   └── ssl/          # SSL certificates
    ├── home/             # User home directories
    ├── opt/              # Optional software (Docker, third-party apps)
    ├── tmp/              # Temporary files (cleared on reboot)
    ├── usr/              # User programs and data
    │   ├── bin/          # User commands
    │   ├── lib/          # Libraries
    │   └── local/        # Locally installed software
    ├── var/              # Variable data
    │   ├── log/          # System and application logs
    │   ├── lib/          # Application data (databases)
    │   ├── cache/        # Application cache files
    │   └── spool/        # Print queues, mail, cron jobs
    └── root/             # Root user home directory

**Container and Cloud Considerations:**

.. code-block:: bash

    # Container-specific paths
    /var/lib/docker/      # Docker data (images, containers, volumes)
    /var/lib/kubelet/     # Kubernetes node data
    /etc/docker/          # Docker daemon configuration
    /etc/kubernetes/      # Kubernetes configuration
    
    # Cloud provider agents
    /opt/aws/             # AWS CLI and tools
    /etc/waagent.conf     # Azure agent (Azure VMs)
    /etc/google/          # Google Cloud agent configuration
    
    # Configuration management
    /etc/ansible/         # Ansible configuration
    /etc/puppet/          # Puppet configuration
    /etc/salt/            # Salt configuration

===============
File Operations
===============

**Navigation and Discovery:**

.. code-block:: bash

    # Enhanced listing with details
    ls -la                           # List all files with permissions, dates
    ls -lah                          # Human-readable file sizes
    ls -lt                           # Sort by modification time
    ls -lS                           # Sort by file size
    tree /path/                      # Show directory structure (install: apt install tree)
    
    # Modern alternatives
    exa -la                          # Modern ls replacement (install: apt install exa)
    bat filename                     # Syntax-highlighted cat (install: apt install bat)
    fd pattern /path/                # Fast find alternative (install: apt install fd-find)

**File Operations with Safety:**

.. code-block:: bash

    # Safe copying with backups
    cp -i source destination         # Interactive mode (confirm overwrites)
    cp -a source/ destination/       # Archive mode (preserves all attributes)
    rsync -av source/ destination/   # Better for large files/directories
    
    # Safe moving and renaming
    mv -i source destination         # Interactive mode
    rename 's/old/new/' *.txt        # Batch rename using regex
    
    # Safe deletion
    rm -i filename                   # Interactive deletion
    rm -rf dirname                   # Recursive force delete (DANGEROUS!)
    trash filename                   # Move to trash instead (install: apt install trash-cli)

**File Content Operations:**

.. code-block:: bash

    # View file content
    cat filename                     # Display entire file
    less filename                    # Paginated view (q to quit)
    head -n 20 filename              # First 20 lines
    tail -n 20 filename              # Last 20 lines
    tail -f /var/log/syslog          # Follow log file changes
    
    # Modern alternatives
    bat filename                     # Syntax highlighting + line numbers
    delta file1 file2                # Better diff tool
    jq . config.json                 # Pretty-print JSON files

**File Permissions and Security:**

.. code-block:: bash

    # Permission format: rwxrwxrwx (owner group other)
    # r=read(4), w=write(2), x=execute(1)
    
    # Common permission patterns
    chmod 644 file.txt               # rw-r--r-- (readable config files)
    chmod 600 private.key            # rw------- (private keys, secrets)
    chmod 755 script.sh              # rwxr-xr-x (executable scripts)
    chmod 700 ~/.ssh/                # rwx------ (SSH directory)
    chmod +x script.py               # Add execute permission
    
    # Ownership changes
    chown user:group file            # Change user and group
    chown -R user:group directory/   # Recursive ownership change
    
    # Advanced permissions
    chmod u+s executable             # Set SUID (run as owner)
    chmod g+s directory/             # Set SGID (inherit group)
    chmod +t /tmp/                   # Sticky bit (only owner can delete)

**DevOps-Specific Permissions:**

.. code-block:: bash

    # Configuration files
    chmod 640 /etc/nginx/nginx.conf          # Readable by group
    chmod 600 /etc/ssl/private/server.key    # Private keys
    chmod 644 /etc/systemd/system/app.service # Service files
    
    # Application directories
    chown -R app:app /var/lib/myapp/
    chmod 755 /var/lib/myapp/
    chmod 644 /var/lib/myapp/config/*
    
    # Log files
    chmod 640 /var/log/myapp.log
    chown app:adm /var/log/myapp.log

**Search and Find Operations:**

.. code-block:: bash

    # Find files and directories
    find /path -name "*.py"                    # Find Python files
    find /path -type f -size +100M             # Files larger than 100MB
    find /path -mtime -7                       # Modified in last 7 days
    find /path -user appuser                   # Files owned by specific user
    find /etc -name "*.conf" -exec chmod 644 {} \;  # Find and fix permissions
    
    # Modern find alternatives
    fd "\.py$" /path/                          # Faster find (install: apt install fd-find)
    fd --type f --size +100m                   # Large files with fd
    
    # Content search with grep
    grep -r "pattern" /path/                   # Search in files recursively
    grep -n "error" /var/log/app.log           # Show line numbers
    grep -i "warning" /var/log/*               # Case-insensitive search
    grep -v "debug" /var/log/app.log           # Exclude lines containing "debug"
    grep -A 5 -B 5 "error" /var/log/app.log   # Show 5 lines before/after match
    
    # Modern grep alternatives
    rg "pattern" /path/                        # ripgrep (faster, install: apt install ripgrep)
    ag "pattern" /path/                        # silver searcher (install: apt install silversearcher-ag)

**Advanced File Operations:**

.. code-block:: bash

    # Symbolic and hard links
    ln -s /path/to/file symlink                # Create symbolic link
    ln /path/to/file hardlink                  # Create hard link
    readlink -f symlink                        # Show target of symbolic link
    
    # Archives and compression
    tar -czf backup.tar.gz directory/          # Create compressed archive
    tar -xzf backup.tar.gz                     # Extract archive
    tar -tzf backup.tar.gz                     # List archive contents
    zip -r archive.zip directory/              # Create ZIP archive
    unzip archive.zip                          # Extract ZIP archive
    
    # Disk usage analysis
    du -sh directory/                          # Directory size (human readable)
    du -ah directory/ | sort -rh | head -20    # Top 20 largest files/dirs
    df -h                                      # Filesystem usage
    lsblk                                      # List block devices
    
    # Modern disk usage tools
    ncdu /path/                                # Interactive disk usage (install: apt install ncdu)
    dust /path/                                # Fast du replacement (install: cargo install du-dust)

**DevOps File Operations:**

.. code-block:: bash

    # Configuration management
    diff -u original.conf modified.conf        # Show configuration differences
    rsync -av --delete source/ dest/           # Sync directories (delete removed files)
    
    # Log file operations
    tail -f /var/log/{syslog,auth.log,nginx/*.log}  # Follow multiple logs
    journalctl -f -u nginx                     # Follow systemd service logs
    logrotate -f /etc/logrotate.d/nginx        # Force log rotation
    
    # Security and compliance
    find /etc -type f -perm /o+w               # Find world-writable files
    find /home -name ".ssh" -type d            # Find SSH directories
    stat filename                             # Show detailed file information
    
    # Container and cloud operations
    docker cp container:/path/file ./          # Copy from container
    kubectl cp pod:/path/file ./file           # Copy from Kubernetes pod
    aws s3 sync ./local/ s3://bucket/prefix/   # Sync to cloud storage

.. warning::

    **Dangerous Commands**: Never run `rm -rf /` or similar destructive commands. Always double-check paths before deleting.

------------------
Permission Classes
------------------

	- **User (u)**: The owner of a file/directory
	- **Group (g)**: The members of the file/directory's group
	- **Others (o)**: Any users that are not part of the *user* or *group* classes

----------------
Permission Types
----------------

	- **Read (r/4)**: view/copy file/directory contents
	- **Write (w/2)**: view/copy/move/delete file/directory
	- **Execute (x/1)**: execute file, access directory

------------------
Access Permissions
------------------

=====  ========  =======================
Octal  Symbolic  Description
=====  ========  =======================
0      ---       no permissions
1      --x       execute only
2      -w-       write only
3      -wx       write and execute
4      r--       read only
5      r-x       read and execute
6      rw-       read and write
7      rwx       read, write and execute
=====  ========  =======================

----------------------
Access rights commands
----------------------

.. code-block:: bash

	# The chown (change owner) command alters the user that a file or directory belongs to
	chown --help

	# The chgrp (change group) command alters the group that a file or directory belongs to
	chgrp --help

	# The chmod (change mode) command alters the file permissions
	chmod --help
	
	chmod 700 file

	chmod u=rwx file

-------------------
Special permissions
-------------------

Linux offers three other types of permissions, called **special permission bits** that may be set on executable files or directories to allow them to respond differently for certain operations.

- **setuid** bit: affects only on files, provides non-owners the ability to run executables with the privileges of the owner
- **setgid** bit: has an effect on files and directories, used for group collaboration (alters the standard behavior so that the group of the files created inside the directory, will not be that of the user who created them, but that of the parent directory)
- **sticky** bit: When the sticky bit is set on a directory, only the owner of a file within that directory can delete or modify it, even if other users have write permissions to the directory. A typical case is the */tmp* directory, which is writable by all users on the system, but users cannot delete files owned by others.

-------------------
Default permissions
-------------------

Linux assigns default permissions to a file or directory at the time of its creation. Default permissions are calculated based on the **umask** (user mask) value subtracted from a preset value called *initial permissions* (777 for directories, 666 for files).

===================  =========  =====
                     Directory  Files
===================  =========  =====
initial permissions  777 -      666 - 
umask                022        022
default permissions  775        644
===================  =========  =====

------------------
Control attributes
------------------

There are certain **attributes** that may be set on a file or directory in order to control what can or cannot be done to it. For example, you can enable attributes on a file or directory so that no users, including root, can delete, modify, rename, or compress it.

The commands to list or change attributes are **lsattr** and **chattr**.

------------------------------
Inodes, soft links, hard links
------------------------------

Each file within a file system has associated metadata information such as file's type, size, permissions, owner's name, owner's group name, last access/modification time, ACL settings, link count, number of allocated blocks, and pointers to the location in the file system where the file data is actually stored.

That metadata is stored in a 128 byte space on disk which is called **inode** (index node).

The inode is assigned a unique numeric identifier that is used by the kernel for accessing, tracking, and managing the file.

The inode does not store the file's name in its metadata. The file name and corresponding inode number mapping is maintained in the directory's metadata.

A **soft link** (a.k.a. a symbolic link or a symlink) associates one file with another (similar to a shortcut in Windows). Each soft link has a unique inode number that stores the path to the file it is linked with.

A **hard link** associates one or more files with a single inode number, making all files indistinguishable from one another. This implies that the files will have identical permissions, ownership, time stamp, and file contents. Changes made to any of the files will be reflected in the other linked files as well.

---------------
Useful commands
---------------

.. code-block:: bash

	# Shows information about file system disk usage
	df -h

	# Shows information about directory and file sizes on the disk
	du -h /var

	# Shows information about directory and file sizes on the disk
	# Only on the first level of directories
	# Sort output in reversed order and human-readable format
	du -h --max-depth=1 /usr | sort -rh

	# Find and print all directories in /usr
	find /usr -type d

	# Find and print all files with .log extension in /var/log
	find /var/log -type f -name "*.log"

	# Find directories and files owned by Alice
	find / -user alice

	# Find directories and files owned by the billing group
	find / -group billing

	# Find files larger than 10MB and list them in long format
	find / -type f -size +10M -exec ls -lh {} \;

====
TODO
====

1. create **/opt/billing** directory
2. create **/opt/billing/clients** and **/opt/billing/invoices** files
3. configure **alice** user as owner for **/opt/billing** directory and its contents
4. configure **billing** group as owner for **/opt/billing** directory and its contents
5. configure access rights for **/opt/billing** directory:
	a. read, write and execute for **alice** user
	b. read and execute for **billing** group
	c. read and execute for everyone else
6. remove access rights to others for all files in the **/opt/billing** directory
7. add write permissions on **/opt/billing/invoices** for **billing** group
8. make **john** as owner for **/opt/billing/clients** and assign him read-only rights
9. make **alice** as owner for **/opt/billing/invoices** and assign her read-only rights

.. warning::

	To err is human ... to really f*ck up requires the root password.

================
Solution to TODO
================

1. mkdir /opt/billing
2. touch /opt/billing/clients /opt/billing/invoices
3. chown alice /opt/billing
4. chgrp billing /opt/billing
5. chmod 755 /opt/billing
6. chmod o-r /opt/billing/*
7. chmod g+w /opt/billing/invoices
8. chown john /opt/billing/clients
   chmod u-w /opt/billing/clients
9. chown alice /opt/billing/invoices
   chmod u-w /opt/billing/invoices
#############################
2.1 Managing Users and Groups
#############################

=========================
Essential User Management
=========================

Linux user management controls who can access systems and what they can do. Critical for DevOps security and automation.

**Key Files:**

.. code-block:: bash

    /etc/passwd     # User account information
    /etc/shadow     # Encrypted passwords  
    /etc/group      # Group information
    /etc/sudoers    # Sudo permissions

**Essential Commands:**

.. code-block:: bash

    # User operations
    sudo useradd username
    sudo usermod -aG group username
    sudo userdel username
    sudo passwd username
    
    # Group operations  
    sudo groupadd groupname
    sudo groupdel groupname
    
    # Information commands
    id username
    groups username
    whoami
    who
    w

**User Information Format (/etc/passwd):**

.. code-block:: bash

    username:x:UID:GID:full_name:home_directory:shell
    
    # Example:
    devops:x:1000:1000:DevOps Engineer:/home/devops:/bin/bash

=========================
Practical User Management
=========================

**Create Service Account:**

.. code-block:: bash

    # Create system user for applications
    sudo useradd -r -s /bin/false -d /var/lib/myapp myapp
    
    # Create regular user with home directory
    sudo useradd -m -s /bin/bash newuser

**Group Management:**

.. code-block:: bash

    # Add user to multiple groups
    sudo usermod -aG docker,sudo,developers username
    
    # Change primary group
    sudo usermod -g newgroup username
    
    # Remove user from group
    sudo gpasswd -d username groupname

**Security Best Practices for DevOps:**

.. code-block:: bash

    # Service accounts for applications (no shell access)
    sudo useradd -r -s /usr/sbin/nologin -d /var/lib/myapp myapp
    
    # DevOps user with sudo access
    sudo useradd -m -s /bin/bash -G sudo,docker devops-user
    
    # Temporary contractor access (expires in 30 days)
    sudo useradd -m -e $(date -d '+30 days' +%Y-%m-%d) contractor
    
    # Lock account without deleting (preserves files)
    sudo usermod -L username
    sudo passwd -l username

**Modern Authentication Methods:**

.. code-block:: bash

    # SSH key-only authentication (disable password auth)
    sudo mkdir -p /home/username/.ssh
    sudo cp authorized_keys /home/username/.ssh/
    sudo chown -R username:username /home/username/.ssh
    sudo chmod 700 /home/username/.ssh
    sudo chmod 600 /home/username/.ssh/authorized_keys
    
    # Multi-factor authentication with Google Authenticator
    sudo apt install libpam-google-authenticator
    google-authenticator  # Run as user to set up
    
    # LDAP/Active Directory integration
    sudo apt install sssd realmd
    sudo realm join domain.company.com

**Container and Cloud Integration:**

.. code-block:: bash

    # Docker group management
    sudo groupadd docker
    sudo usermod -aG docker $USER
    
    # Kubernetes service accounts (for CI/CD)
    kubectl create serviceaccount ci-deployer
    kubectl create clusterrolebinding ci-deployer-binding \
        --clusterrole=cluster-admin --serviceaccount=default:ci-deployer
    
    # AWS IAM instance profile (cloud)
    aws iam create-role --role-name EC2-DevOps-Role \
        --assume-role-policy-document file://trust-policy.json

   * - Field
     - Example
     - Description
   * - **username**
     - ``devops``
     - Login name (only lowercase, numbers, hyphens)
   * - **password**
     - ``x``
     - Password placeholder (actual password in /etc/shadow)
   * - **UID**
     - ``1000``
     - User ID number (0=root, 1-999=system, 1000+=regular users)
   * - **GID**
     - ``1000``
     - Primary group ID number
   * - **full_name**
     - ``DevOps Engineer``
     - User's real name or description
   * - **home_directory**
     - ``/home/devops``
     - User's home folder location
   * - **shell**
     - ``/bin/bash``
     - Default command shell (/bin/bash, /bin/zsh, /usr/sbin/nologin)

.. note::
    **Security tip**: System accounts (UID 1-999) like ``nginx`` or ``mysql`` typically use ``/usr/sbin/nologin`` as their shell, preventing direct login while allowing the service to run.

================================
/etc/shadow - The Security Vault
================================

The ``/etc/shadow`` file stores encrypted passwords and security settings. Think of it as a secure vault that only root can access.

**Format:**

.. code-block:: bash

    username:encrypted_password:last_change:min_days:max_days:warn_days:inactive:expire::

**Real Example:**

.. code-block:: bash

    # Only root can read this file
    sudo cat /etc/shadow | head -3
    
    # Example entries:
    root:$6$xyz...:19000:0:99999:7:::
    devops:$6$abc...:19010:0:90:7:30::

**Field Breakdown:**

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Field
     - Example
     - Description
   * - **username**
     - ``devops``
     - Must match /etc/passwd entry
   * - **encrypted_password**
     - ``$6$abc...``
     - Encrypted password ($6$ = SHA-512, ! = locked account)
   * - **last_change**
     - ``19010``
     - Days since epoch (Jan 1, 1970) when password was last changed
   * - **min_days**
     - ``0``
     - Minimum days before password can be changed again
   * - **max_days**
     - ``90``
     - Maximum days before password must be changed
   * - **warn_days**
     - ``7``
     - Days before expiration to start warning user
   * - **inactive**
     - ``30``
     - Days after expiration before account is disabled
   * - **expire**
     - *(empty)*
     - Absolute expiration date (days since epoch)

**Understanding Password States:**

.. code-block:: bash

    # Check password status
    sudo passwd -S devops
    
    # Possible outputs:
    devops PS 2024-01-15 0 90 7 30 (Password set, expires in 90 days)
    devops L  2024-01-15 0 90 7 30 (Locked account)
    devops NP 2024-01-15 0 90 7 30 (No password set)

=====================================
/etc/group - The Department Directory
=====================================

The ``/etc/group`` file is like a company's department directory, showing which employees belong to which teams.

**Format:**
.. code-block:: bash

    group_name:x:GID:member_list

**Real Example:**
.. code-block:: bash

    # View group information
    cat /etc/group | grep -E "(wheel|docker|sudo)"
    
    # Example entries:
    wheel:x:10:devops,admin
    docker:x:999:devops,jenkins
    sudo:x:27:devops

**Field Breakdown:**

.. list-table::
   :header-rows: 1
   :widths: 20 20 60

   * - Field
     - Example
     - Description
   * - **group_name**
     - ``docker``
     - Unique group name
   * - **password**
     - ``x``
     - Group password placeholder (rarely used)
   * - **GID**
     - ``999``
     - Group ID number
   * - **member_list**
     - ``devops,jenkins``
     - Comma-separated list of secondary group members

**Understanding Group Membership:**

.. code-block:: bash

    # Check your groups
    groups
    # Output: devops wheel docker sudo
    
    # Check specific user's groups
    groups devops
    # Output: devops : devops wheel docker sudo
    
    # Detailed group info
    id devops
    # Output: uid=1000(devops) gid=1000(devops) groups=1000(devops),10(wheel),999(docker),27(sudo)

.. note::
    **Primary vs Secondary Groups**: Every user has one primary group (defined in /etc/passwd) and can belong to multiple secondary groups (listed in /etc/group). Files created by the user will belong to their primary group by default.

================================
Configuration Files and Defaults
================================

These files control default settings when creating new users and groups:

.. code-block:: bash

    /etc/default/useradd    # Default settings for new users
    /etc/login.defs         # System-wide login and password defaults
    /etc/skel/              # Template files copied to new user homes

**View Current Defaults:**

.. code-block:: bash

    # See useradd defaults
    useradd -D
    # Output:
    # GROUP=100
    # HOME=/home
    # INACTIVE=-1
    # EXPIRE=
    # SHELL=/bin/bash
    # SKEL=/etc/skel

**What's in /etc/skel:**

.. code-block:: bash

    # Template files for new users
    ls -la /etc/skel/
    # Common files:
    # .bash_logout    - Commands to run when logging out
    # .bashrc         - Bash shell configuration
    # .profile        - Login shell configuration

=========================
Practical User Management
=========================

Now let's learn how to actually manage users and groups with hands-on examples.

---------------------------
Creating Users Step-by-Step
---------------------------

**Basic User Creation:**

.. code-block:: bash

    # Create a simple user (uses defaults)
    sudo useradd alice
    
    # Check what was created
    id alice
    # Output: uid=1001(alice) gid=1001(alice) groups=1001(alice)
    
    # Check home directory
    ls -la /home/alice
    # Directory exists with template files from /etc/skel

**Advanced User Creation:**

.. code-block:: bash

    # Create user with specific settings
    sudo useradd bob \
        --uid 1500 \
        --gid 1000 \
        --home-dir /opt/bob \
        --shell /bin/zsh \
        --comment "Bob the Builder" \
        --create-home
    
    # Verify the creation
    grep bob /etc/passwd
    # Output: bob:x:1500:1000:Bob the Builder:/opt/bob:/bin/zsh

**DevOps-Specific Examples:**

.. code-block:: bash

    # Create a service account for web server
    sudo useradd nginx \
        --system \
        --no-create-home \
        --shell /usr/sbin/nologin \
        --comment "Nginx web server"
    
    # Create a deployment user
    sudo useradd deploy \
        --groups wheel,docker \
        --comment "Deployment Account" \
        --create-home

-----------------------------
Setting Up Passwords Securely
-----------------------------

.. code-block:: bash

    # Set password interactively (most secure)
    sudo passwd alice
    # You'll be prompted to enter password twice
    
    # Set password from script (less secure, but useful for automation)
    echo "alice:newpassword" | sudo chpasswd
    
    # Generate random password
    openssl rand -base64 12
    # Output: xK2mP9qR8nL4
    
    # Lock an account (disable login)
    sudo passwd -l alice
    
    # Unlock an account
    sudo passwd -u alice
    
    # Check password status
    sudo passwd -S alice
    # Output: alice PS 2024-01-15 0 99999 7 -1

**Password Aging Configuration:**

.. code-block:: bash

    # Force password change every 90 days, warn 7 days before
    sudo chage -M 90 -W 7 alice
    
    # Set account to expire on specific date
    sudo chage -E 2024-12-31 alice
    
    # View current settings
    sudo chage -l alice

----------------------------
Group Management in Practice
----------------------------

.. code-block:: bash

    # Create groups for different teams
    sudo groupadd developers
    sudo groupadd operations
    sudo groupadd devops-team
    
    # Create group with specific GID
    sudo groupadd -g 2000 database-admins
    
    # Add users to groups (secondary groups)
    sudo usermod -aG developers alice
    sudo usermod -aG developers,devops-team bob
    
    # Change user's primary group
    sudo usermod -g developers alice
    
    # Remove user from a group
    sudo gpasswd -d alice developers

**Real-World DevOps Example:**

.. code-block:: bash

    # Set up typical DevOps team structure
    
    # Create groups
    sudo groupadd developers
    sudo groupadd devops
    sudo groupadd docker-users
    
    # Create users and assign to appropriate groups
    sudo useradd --groups developers,docker-users jane
    sudo useradd --groups devops,docker-users,wheel mike
    sudo useradd --groups developers sarah
    
    # Verify group memberships
    groups jane mike sarah

------------------------
Modifying Existing Users
------------------------

.. code-block:: bash

    # Change user's home directory
    sudo usermod -d /new/home/path alice
    
    # Change user's shell
    sudo usermod -s /bin/zsh alice
    
    # Change user's UID (be careful!)
    sudo usermod -u 2000 alice
    
    # Change user's comment/description
    sudo usermod -c "Alice in DevOps" alice
    
    # Lock account (keeps files, prevents login)
    sudo usermod -L alice
    
    # Unlock account
    sudo usermod -U alice

--------------------------------
Removing Users and Groups Safely
--------------------------------

.. code-block:: bash

    # Remove user but keep home directory
    sudo userdel alice
    
    # Remove user and home directory
    sudo userdel -r alice
    
    # Remove user and all files owned by user
    sudo userdel -r -f alice
    
    # Remove group (only if no users use it as primary group)
    sudo groupdel developers
    
    # Check if group is safe to delete
    grep developers /etc/passwd
    # If output is empty, safe to delete

.. warning::
    **Be careful when deleting users!** Always backup important data first. Use ``userdel -r`` only when you're certain you want to permanently delete all user files.

=====================
DevOps Best Practices
=====================

**1. Service Accounts**
Create dedicated accounts for services:

.. code-block:: bash

    # Database service account
    sudo useradd -r -s /usr/sbin/nologin -d /var/lib/mysql mysql
    
    # Web server account
    sudo useradd -r -s /usr/sbin/nologin -d /var/www nginx

**2. Deployment Accounts**
Create accounts for automated deployments:

.. code-block:: bash

    # Deployment user with sudo access
    sudo useradd -m -s /bin/bash deploy
    sudo usermod -aG sudo deploy
    
    # Set up SSH key authentication
    sudo mkdir /home/deploy/.ssh
    sudo chmod 700 /home/deploy/.ssh
    sudo chown deploy:deploy /home/deploy/.ssh

**3. Monitoring Group Access**
Use groups to manage access to logs and monitoring:

.. code-block:: bash

    # Create monitoring group
    sudo groupadd monitoring
    
    # Add users who need to read logs
    sudo usermod -aG monitoring alice
    sudo usermod -aG monitoring bob
    
    # Set appropriate permissions on log files
    sudo chgrp monitoring /var/log/application.log
    sudo chmod 640 /var/log/application.log

========================
Common Command Reference
========================

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Command
     - Description
   * - ``useradd [options] username``
     - Create new user account
   * - ``userdel [options] username``
     - Delete user account
   * - ``usermod [options] username``
     - Modify existing user
   * - ``passwd [username]``
     - Set/change user password
   * - ``chage [options] username``
     - Change password aging information
   * - ``groupadd [options] groupname``
     - Create new group
   * - ``groupdel groupname``
     - Delete group
   * - ``gpasswd [options] groupname``
     - Manage group membership
   * - ``id [username]``
     - Display user and group IDs
   * - ``groups [username]``
     - Display user's groups
   * - ``su - username``
     - Switch to another user
   * - ``sudo -u username command``
     - Run command as another user


============================
Hands-On Practice Exercises
============================

**Exercise 1: Create a Development Team**

1. Create a user named *alice* with UID and GID set to *3001*
2. Create a user named *bob* with home directory in */opt/bob*
3. Create a user named *john* with comment field set to *John Doe*
4. Create a service user named *minecraft* with:

   - UID *9990* and GID *9990*
   - Home directory in */usr/games*
   - No login privileges (shell: */bin/false*)
   - Don't create the home directory

**Exercise 2: Configure Security**

5. Set a strong password for alice
6. Create a group named *dataManagement* with GID 9001
7. Add *alice* and *bob* to the *billing* group
8. Configure password aging for *alice*:

   - Password expires after 31 days
   - User gets warnings 7 days before expiration

**Exercise 3: Clean Up**

9. Lock the *minecraft* account and password
10. Remove the *minecraft* account and home directory
11. Remove the *minecraft* group
12. Remove the *dataManagement* and *billing* groups

.. note::

    **Practice safely**: Use a virtual machine or container to practice these commands. Never practice user management on production systems!

.. warning::

    **Security reminder**: Passwords are like underwear, change them often, don't share them, and don't leave them lying around!

==================
Exercise Solutions
==================

.. code-block:: bash

    # Exercise 1: Create users
    sudo useradd alice -u 3001 -g 3001
    sudo useradd bob -d /opt/bob -m
    sudo useradd john -c "John Doe"
    sudo useradd minecraft -u 9990 -g 9990 -d /usr/games -s /bin/false -M
    
    # Exercise 2: Configure security
    sudo passwd alice
    sudo groupadd dataManagement -g 9001
    sudo groupadd billing  # Create billing group first
    sudo usermod -aG billing alice
    sudo usermod -aG billing bob
    sudo chage -M 31 -W 7 alice
    
    # Exercise 3: Clean up
    sudo passwd -l minecraft
    sudo userdel -r minecraft
    sudo groupdel minecraft
    sudo groupdel dataManagement
    sudo groupdel billing

=============
Key Takeaways
=============

1. **File Structure**: User info is split across multiple files (/etc/passwd, /etc/shadow, /etc/group)
2. **Security**: Never edit these files directly—use the proper commands
3. **Groups**: Every user has one primary group and can belong to multiple secondary groups
4. **Service Accounts**: Use system accounts with no login for services
5. **Password Security**: Implement aging, complexity, and regular changes
6. **DevOps Practice**: Automate user management but understand the fundamentals first

.. note::

    **Next Steps**: Now that you understand user management, you're ready to learn about file permissions and ownership—which directly builds on group membership concepts!
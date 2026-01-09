######################
2.7 Linux File Systems
######################

======================
Storage Types Overview
======================

**Block Storage:**

- Raw storage devices managed by OS
- High performance, low latency
- Examples: Local disks, SAN, cloud block storage

**File Storage:**

- Files organized in directories
- Shared across networks
- Examples: NFS, SMB/CIFS, cloud file storage

**Object Storage:**

- Data stored as objects with metadata
- Highly scalable, web-accessible
- Examples: AWS S3, Google Cloud Storage

===========================
File Systems and Partitions
===========================

**Common Linux File Systems:**

.. code-block:: bash

    ext4        # Default on most distributions
    xfs         # High performance, good for large files
    btrfs       # Advanced features, snapshots
    zfs         # Enterprise features, built-in RAID
    tmpfs       # RAM-based filesystem

**Disk and Partition Commands:**

.. code-block:: bash

    # List disks and partitions
    lsblk                     # Tree view of block devices
    fdisk -l                  # List all disks and partitions
    df -h                     # Show mounted filesystems
    
    # Partition management
    fdisk /dev/sda            # Interactive partition editor
    parted /dev/sda           # GNU parted tool
    
    # File system operations
    mkfs.ext4 /dev/sda1       # Create ext4 filesystem
    fsck /dev/sda1            # Check filesystem
    tune2fs -l /dev/sda1      # Show filesystem info

=======================
Mounting and /etc/fstab
=======================

**Mount Operations:**

.. code-block:: bash

    # Mount filesystem
    sudo mount /dev/sda1 /mnt/data
    sudo mount -t ext4 /dev/sda1 /mnt/data
    
    # Unmount
    sudo umount /mnt/data
    sudo umount /dev/sda1
    
    # Show mounted filesystems
    mount | column -t
    findmnt
    
    # Mount with options
    sudo mount -o rw,noexec,nosuid /dev/sda1 /mnt/data

**Persistent Mounts (/etc/fstab):**

.. code-block:: bash

    # /etc/fstab format:
    # device  mountpoint  filesystem  options  dump  pass
    /dev/sda1  /home      ext4        defaults  0     2
    UUID=xxx   /data      xfs         defaults  0     2
    
    # Test fstab without reboot
    sudo mount -a

=============================
Filesystem Monitoring Scripts
=============================

**Filesystem Information:**

.. code-block:: bash

    # Get detailed filesystem information
    lsblk -f                    # Show filesystems with UUIDs
    blkid                       # Show block device attributes
    findmnt                     # Show mounted filesystems in tree format
    
    # Disk usage analysis
    du -sh /* 2>/dev/null | sort -hr | head -10    # Top directories by size
    du -sh ~/.* ~ 2>/dev/null | sort -hr           # Home directory analysis
    
    # Find large files
    find /var/log -type f -size +50M -exec ls -lh {} \;
    find /tmp -type f -size +10M -mtime +7         # Large old temp files
                    continue
        return large_files

==================
Storage Management
==================

**LVM (Logical Volume Management):**

.. code-block:: bash

    # Physical volume operations
    sudo pvcreate /dev/sdb
    pvdisplay
    
    # Volume group operations  
    sudo vgcreate myvg /dev/sdb
    vgdisplay
    
    # Logical volume operations
    sudo lvcreate -L 10G -n mylv myvg
    lvdisplay
    
    # Create filesystem and mount
    sudo mkfs.ext4 /dev/myvg/mylv
    sudo mount /dev/myvg/mylv /mnt/data

**RAID Management:**

.. code-block:: bash

    # Software RAID with mdadm
    sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc
    
    # Check RAID status
    cat /proc/mdstat
    sudo mdadm --detail /dev/md0

**Backup and Sync:**

.. code-block:: bash

    # Rsync for file synchronization
    rsync -av /source/ /destination/
    rsync -av user@host:/remote/path/ /local/path/
    
    # Create filesystem snapshots (btrfs)
    sudo btrfs subvolume snapshot /home /home/.snapshots/$(date +%Y%m%d)

.. note::

    **DevOps Tip**: Always monitor disk usage in production. Set up alerts when filesystems reach 80% capacity to prevent service disruptions.

======================
Logical Volume Manager
======================

#. **LVM** is a storage abstraction layer that allows for very flexible management of block-level devices
#. provides features like the ability to add disk space to a logical volume and its filesystem while that filesystem is mounted and active
#. allows for the collection of multiple physical hard drives and partitions into a single volume group which can then be divided into logical volumes.
#. terminology:
    #. **physical volumes**: physical disks, or disk partitions
    #. **volume groups**: seen as a *"virtual partition"* which comprises an arbitrary number of physical volumes
    #. **logical volumes**: contained in the volume groups they can be bigger than any single physical volume you might have. These will be formatted with a file system

============
File systems
============

#. a **file system** is a structured representation of data and a set of metadata describing this data
#. it is applied to the storage during the **format** operation
#. common file system types: ext3, **ext4**, **xfs**, fat, ntfs; nfs, smbfs/cifs

=========
Questions
=========

1. What is the difference between block-level and a file-level storage?

   a. Block-level storage is offered directly to the Operating System as raw devices, while file-level storage is stored as files and presented to OSes as a hierarchical directories structure.
   b. Block-level storage is stored as files and presented to OSes as a hierarchical directories structure, while file-level storage is offered directly to the Operating System as raw devices.
   c. Block-level storage is stored as files and presented to OSes as a hierarchical directories structure, while file-level storage is offered directly to the Operating System as raw devices.
   d. Block-level storage is offered directly to the Operating System as raw devices, while file-level storage is stored as files and presented to OSes as a hierarchical directories structure.

2. What is the difference between a disk and a partition?

    a. A disk is a logical form of boundary, it is used to divide the disk into logical units, while a partition is just raw physical/virtual means to store data.
    b. A disk is just raw physical/virtual means to store data, while a partition is a logical form of boundary, it is used to divide the disk into logical units.
    c. A disk is a logical form of boundary, it is used to divide the disk into logical units, while a partition is a logical form of boundary, it is used to divide the disk into logical units.
    d. A disk is just raw physical/virtual means to store data, while a partition is just raw physical/virtual means to store data.

3. What is the difference between a partition and a partition table?

    a. A partition is a logical form of boundary, it is used to divide the disk into logical units, while a partition table is just raw physical/virtual means to store data.
    b. A partition is just raw physical/virtual means to store data, while a partition table is a logical form of boundary, it is used to divide the disk into logical units.
    c. A partition is a logical form of boundary, it is used to divide the disk into logical units, while a partition table is a logical form of boundary, it is used to divide the disk into logical units.
    d. A partition is just raw physical/virtual means to store data, while a partition table is just raw physical/virtual means to store data.

4. What is the difference between a partition table and a file system?

    a. A partition table is a logical form of boundary, it is used to divide the disk into logical units, while a file system is just raw physical/virtual means to store data.
    b. A partition table is just raw physical/virtual means to store data, while a file system is a logical form of boundary, it is used to divide the disk into logical units.
    c. A partition table is a logical form of boundary, it is used to divide the disk into logical units, while a file system is a logical form of boundary, it is used to divide the disk into logical units.
    d. A partition table is just raw physical/virtual means to store data, while a file system is just raw physical/virtual means to store data.

5. What is the difference between a file system and a file?

    a. A file system is a structured representation of data and a set of metadata describing this data, while a file is a logical form of boundary, it is used to divide the disk into logical units.
    b. A file system is a logical form of boundary, it is used to divide the disk into logical units, while a file is a structured representation of data and a set of metadata describing this data.
    c. A file system is a structured representation of data and a set of metadata describing this data, while a file is a structured representation of data and a set of metadata describing this data.
    d. A file system is a logical form of boundary, it is used to divide the disk into logical units, while a file is a logical form of boundary, it is used to divide the disk into logical units.

=======
Answers
=======

1. a
2. b
3. c
4. c
5. b
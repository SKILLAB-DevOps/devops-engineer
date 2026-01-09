##########
4.10 Files
##########

.. note:: 

    Always use the ``with`` statement when dealing with file objects. This ensures that the file is closed when the block inside the ``with`` statement is exited.

.. code-block:: python
    
    # read data from file
    with open('file.txt') as f:
        data = f.read()
        
    # write data to file
    with open('file.txt', 'w') as f:
        f.write('some data')
    

================
File Path Issues
================

1. **Problem**: Relative vs Absolute Paths

    **Solution**: Be clear about whether you're using a relative or absolute path. Use os.path or pathlib for platform-independent path manipulation - don't hardcode path separators. Use ``os.path.join()`` to construct file paths.

2. **Problem**: Platform-Specific Paths

    **Solution**: Use ``os`` or ``pathlib`` libraries to construct file paths in a way that's compatible with all platforms.

===============
File Operations
===============

1. **Problem**: File Locks

    **Solution**: Use file-locking libraries to ensure that only one process can access a file at a time.

2. **Problem**: Reading Large Files

    **Solution**: Read the file in chunks or employ lazy loading to reduce memory consumption.

3. **Problem**: File Encoding

    **Solution**: Specify the encoding while opening the file, or use tools to detect encoding automatically.

==============================
File Existence and Permissions
==============================

1. **Problem**: File Not Found

    **Solution**: Use ``try/except`` blocks to catch FileNotFoundError and handle it gracefully.

2. **Problem**: Permission Errors

    **Solution**: Check file permissions using ``os.access()`` before attempting to read or write.

3. **Problem**: Safe File Deletion

    **Solution**: Use secure deletion methods or libraries to ensure files are deleted securely.

==============
Data Integrity
==============

1. **Problem**: Atomic Writes

    **Solution**: Use temporary files and rename them upon a successful write to ensure atomicity.

2. **Problem**: Data Consistency

    **Solution**: Use file locks or database transactions for consistent data.

3. **Problem**: Buffering

    **Solution**: Use the ``flush()`` method or disable buffering to ensure immediate disk writes.

==============
Text vs Binary
==============

1. **Problem**: Mode Confusion

    **Solution**: Specify whether you're opening the file in text (t) or binary (b) mode.

2. **Problem**: Newline Translation

    **Solution**: Open the file in binary mode if newline translation is not desired.

==============
Error Handling
==============

1. **Problem**: Exception Handling

    **Solution**: Wrap file operations in ``try/except`` blocks to handle exceptions like ``IOError``, ``FileNotFoundError``, and ``PermissionError``.

2. **Problem**: Resource Leaks

    **Solution**: Use with statements (context managers) to ensure that files are properly closed.

============
File Formats
============

1. **Problem**: Parsing Errors

    **Solution**: Use dedicated parsing libraries like ``json``, ``csv``, or ``xml.etree.ElementTree`` and handle exceptions.

2. **Problem**: Version Compatibility

    **Solution**: Always check the version of the file format and adapt your code accordingly.

==========
Efficiency
==========

1. **Problem**: I/O Bottlenecks

    **Solution**: Use asynchronous I/O if the architecture of the program allows for it.

2. **Problem**: Memory Usage

    **Solution**: Use generators or lazy evaluation to read files line-by-line or chunk-by-chunk.

========
Security
========

1. **Problem**: Injection Attacks

    **Solution**: Sanitize user-generated filenames and content. Avoid using shell=True in subprocess calls.

2. **Problem**: Sensitive Data

    **Solution**: Encrypt the data before writing to a file and set appropriate file permissions to restrict access.

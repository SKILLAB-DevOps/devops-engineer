import psutil

"""Simple command line tool to extract system information.""" ""


def get_cpu_info():
    """Shows CPU Resources."""
    return psutil.cpu_times()


def get_disk_info():
    """Shows Disk Status."""
    return psutil.disk_partitions()


def get_memory_info():
    """Shows Memory Status."""
    return psutil.virtual_memory()


def get_network_info():
    """Shows Network Status."""
    return psutil.net_io_counters()


def get_swap_info():
    """Shows Swap Status."""
    return psutil.swap_memory()


def get_sensors_info():
    """Shows Sensors Status."""
    return psutil.sensors_temperatures()

import devops_cli.functions as info
import psutil


def test_get_cpu_info():
    assert info.get_cpu_info() == psutil.cpu_times()


def test_get_disk_info():
    assert info.get_disk_info() == psutil.disk_partitions()


def test_get_memory_info():
    assert info.get_memory_info() == psutil.virtual_memory()


def test_get_network_info():
    assert info.get_network_info() == psutil.net_io_counters()


def test_get_swap_info():
    assert info.get_swap_info() == psutil.swap_memory()


def test_get_sensors_info():
    assert info.get_sensors_info() == psutil.sensors_temperatures()

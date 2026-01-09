"""System information services."""

import psutil
from typing import Dict, List, Any

from .models import (
    CPUInfo,
    MemoryInfo,
    DiskInfo,
    DiskPartition,
    NetworkInfo,
    SwapInfo,
    SensorInfo,
    SystemInfo,
)


class SystemInfoService:
    """Service class for gathering system information."""

    @staticmethod
    def get_cpu_info() -> CPUInfo:
        """Get CPU information."""
        cpu_times = psutil.cpu_times()
        return CPUInfo(**cpu_times._asdict())

    @staticmethod
    def get_memory_info() -> MemoryInfo:
        """Get memory information."""
        memory = psutil.virtual_memory()
        return MemoryInfo(**memory._asdict())

    @staticmethod
    def get_disk_info() -> DiskInfo:
        """Get disk information."""
        partitions = psutil.disk_partitions()
        disk_partitions = [
            DiskPartition(
                device=p.device,
                mountpoint=p.mountpoint,
                fstype=p.fstype,
                opts=p.opts,
            )
            for p in partitions
        ]
        return DiskInfo(partitions=disk_partitions)

    @staticmethod
    def get_network_info() -> NetworkInfo:
        """Get network information."""
        network = psutil.net_io_counters()
        return NetworkInfo(**network._asdict())

    @staticmethod
    def get_swap_info() -> SwapInfo:
        """Get swap information."""
        swap = psutil.swap_memory()
        return SwapInfo(**swap._asdict())

    @staticmethod
    def get_sensors_info() -> SensorInfo:
        """Get sensor information."""
        try:
            sensors = psutil.sensors_temperatures()
            # Convert namedtuples to dictionaries for JSON serialization
            sensors_dict: Dict[str, List[Dict[str, Any]]] = {}
            for name, entries in sensors.items():
                sensors_dict[name] = [
                    {
                        "label": entry.label or "Unknown",
                        "current": entry.current,
                        "high": entry.high,
                        "critical": entry.critical,
                    }
                    for entry in entries
                ]
            return SensorInfo(sensors=sensors_dict)
        except AttributeError:
            # Sensors not available on this platform
            return SensorInfo(sensors={})

    @classmethod
    def get_all_info(cls) -> SystemInfo:
        """Get all system information."""
        return SystemInfo(
            cpu=cls.get_cpu_info(),
            memory=cls.get_memory_info(),
            disk=cls.get_disk_info(),
            network=cls.get_network_info(),
            swap=cls.get_swap_info(),
            sensors=cls.get_sensors_info(),
        )

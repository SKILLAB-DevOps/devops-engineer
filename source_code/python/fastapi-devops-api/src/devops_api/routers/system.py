"""System information API routes."""

from fastapi import APIRouter, HTTPException
from ..models import CPUInfo, MemoryInfo, DiskInfo, NetworkInfo, SwapInfo, SensorInfo, SystemInfo
from ..services import SystemInfoService

router = APIRouter(prefix="/system", tags=["system"])
service = SystemInfoService()


@router.get("/cpu", response_model=CPUInfo, summary="Get CPU Information")
async def get_cpu_info():
    """
    Get detailed CPU usage information.
    
    Returns information about CPU time spent in different modes:
    - User mode execution
    - System mode execution  
    - Idle time
    - I/O wait time (Linux only)
    - Interrupt handling time
    """
    try:
        return service.get_cpu_info()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get CPU info: {str(e)}")


@router.get("/memory", response_model=MemoryInfo, summary="Get Memory Information")
async def get_memory_info():
    """
    Get detailed memory usage information.
    
    Returns information about system memory:
    - Total physical memory
    - Available memory
    - Used memory percentage
    - Free memory
    - Cached and buffered memory
    """
    try:
        return service.get_memory_info()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get memory info: {str(e)}")


@router.get("/disk", response_model=DiskInfo, summary="Get Disk Information")
async def get_disk_info():
    """
    Get disk partitions and mount point information.
    
    Returns information about:
    - Mounted disk partitions
    - Mount points
    - File system types
    - Mount options
    """
    try:
        return service.get_disk_info()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get disk info: {str(e)}")


@router.get("/network", response_model=NetworkInfo, summary="Get Network Information") 
async def get_network_info():
    """
    Get network interface statistics.
    
    Returns information about network I/O:
    - Bytes sent and received
    - Packets sent and received
    - Network errors
    - Dropped packets
    """
    try:
        return service.get_network_info()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get network info: {str(e)}")


@router.get("/swap", response_model=SwapInfo, summary="Get Swap Information")
async def get_swap_info():
    """
    Get swap memory usage information.
    
    Returns information about swap memory:
    - Total swap space
    - Used swap space
    - Free swap space
    - Swap usage percentage
    - Swap in/out operations
    """
    try:
        return service.get_swap_info()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get swap info: {str(e)}")


@router.get("/sensors", response_model=SensorInfo, summary="Get Temperature Sensors")
async def get_sensors_info():
    """
    Get temperature sensor information.
    
    Returns information about hardware temperature sensors:
    - CPU temperature sensors
    - System temperature sensors  
    - Current, high, and critical temperatures
    - Sensor labels and locations
    
    Note: Sensor availability depends on hardware and platform support.
    """
    try:
        return service.get_sensors_info()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get sensors info: {str(e)}")


@router.get("/all", response_model=SystemInfo, summary="Get All System Information")
async def get_all_system_info():
    """
    Get comprehensive system information.
    
    Returns complete system information including:
    - CPU usage and timing
    - Memory utilization
    - Disk partitions
    - Network statistics
    - Swap memory usage
    - Temperature sensors
    
    This endpoint combines all individual system information endpoints
    for convenience when you need a complete system overview.
    """
    try:
        return service.get_all_info()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get system info: {str(e)}")

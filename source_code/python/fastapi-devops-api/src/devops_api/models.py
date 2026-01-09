"""Pydantic models for system information."""

from datetime import datetime
from typing import Dict, List, Optional, Any
from pydantic import BaseModel, Field


class APIInfo(BaseModel):
    """API information model."""
    
    name: str = Field(..., description="API name")
    version: str = Field(..., description="API version")
    description: str = Field(..., description="API description")
    timestamp: datetime = Field(default_factory=datetime.now, description="Current timestamp")


class CPUInfo(BaseModel):
    """CPU information model."""
    
    user: float = Field(..., description="Time spent in user mode")
    nice: float = Field(..., description="Time spent in nice mode")
    system: float = Field(..., description="Time spent in system mode")
    idle: float = Field(..., description="Time spent idle")
    iowait: Optional[float] = Field(None, description="Time spent waiting for I/O")
    irq: Optional[float] = Field(None, description="Time spent servicing hardware interrupts")
    softirq: Optional[float] = Field(None, description="Time spent servicing software interrupts")
    steal: Optional[float] = Field(None, description="Time stolen by other operating systems")
    guest: Optional[float] = Field(None, description="Time spent running a virtual CPU")
    guest_nice: Optional[float] = Field(None, description="Time spent running a niced guest")


class MemoryInfo(BaseModel):
    """Memory information model."""
    
    total: int = Field(..., description="Total physical memory in bytes")
    available: int = Field(..., description="Available memory in bytes")
    percent: float = Field(..., description="Memory usage percentage")
    used: int = Field(..., description="Used memory in bytes")
    free: int = Field(..., description="Free memory in bytes")
    active: Optional[int] = Field(None, description="Active memory in bytes")
    inactive: Optional[int] = Field(None, description="Inactive memory in bytes")
    buffers: Optional[int] = Field(None, description="Buffer memory in bytes")
    cached: Optional[int] = Field(None, description="Cached memory in bytes")
    shared: Optional[int] = Field(None, description="Shared memory in bytes")
    slab: Optional[int] = Field(None, description="Slab memory in bytes")


class DiskPartition(BaseModel):
    """Disk partition model."""
    
    device: str = Field(..., description="Device name")
    mountpoint: str = Field(..., description="Mount point")
    fstype: str = Field(..., description="File system type")
    opts: str = Field(..., description="Mount options")


class DiskInfo(BaseModel):
    """Disk information model."""
    
    partitions: List[DiskPartition] = Field(..., description="List of disk partitions")


class NetworkInfo(BaseModel):
    """Network information model."""
    
    bytes_sent: int = Field(..., description="Bytes sent")
    bytes_recv: int = Field(..., description="Bytes received")
    packets_sent: int = Field(..., description="Packets sent")
    packets_recv: int = Field(..., description="Packets received")
    errin: int = Field(..., description="Input errors")
    errout: int = Field(..., description="Output errors")
    dropin: int = Field(..., description="Input packets dropped")
    dropout: int = Field(..., description="Output packets dropped")


class SwapInfo(BaseModel):
    """Swap memory information model."""
    
    total: int = Field(..., description="Total swap memory in bytes")
    used: int = Field(..., description="Used swap memory in bytes")
    free: int = Field(..., description="Free swap memory in bytes")
    percent: float = Field(..., description="Swap usage percentage")
    sin: int = Field(..., description="Bytes swapped in")
    sout: int = Field(..., description="Bytes swapped out")


class SensorInfo(BaseModel):
    """Temperature sensor information model."""
    
    sensors: Dict[str, List[Dict[str, Any]]] = Field(
        ..., 
        description="Temperature sensors grouped by hardware component"
    )


class SystemInfo(BaseModel):
    """Complete system information model."""
    
    cpu: CPUInfo = Field(..., description="CPU information")
    memory: MemoryInfo = Field(..., description="Memory information")
    disk: DiskInfo = Field(..., description="Disk information")
    network: NetworkInfo = Field(..., description="Network information")
    swap: SwapInfo = Field(..., description="Swap information")
    sensors: SensorInfo = Field(..., description="Sensor information")
    timestamp: datetime = Field(default_factory=datetime.now, description="Collection timestamp")

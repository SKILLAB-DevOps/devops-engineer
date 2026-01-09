from pathlib import Path
import os
import psutil
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field

app = FastAPI(title="WSL System Monitor API with Pydantic")

class StorageInfo(BaseModel):
    total_gb: float = Field(..., description="Total disk size in GB")
    used_gb: float = Field(..., description="Used disk in GB")
    free_gb: float = Field(..., description="Free disk in GB")
    percent: float = Field(..., ge=0, le=100)

class PartitionInfo(BaseModel):
    device: str
    mountpoint: str
    fstype: str

class SystemInfo(BaseModel):
    cpu_percent: float = Field(..., description="Total CPU usage %")
    ram_percent: float = Field(..., description="Used RAM %")
    ram_total_gb: float = Field(..., description="Total RAM in GB")
    ram_used_gb: float = Field(..., description="Used RAM in GB")

class CPUInfo(BaseModel):
    overall_percent: float
    per_core: list[float]
    freq_current: float | None
    freq_min: float | None
    freq_max: float | None

class MemoryInfo(BaseModel):
    total_gb: float
    available_gb: float
    used_gb: float
    percent: float
    swap_total_gb: float
    swap_used_gb: float
    swap_free_gb: float
    swap_percent: float

class LogLines(BaseModel):
    file: str
    lines: list[str]

@app.get("/storage", response_model=StorageInfo)
async def get_storage(path: str = Query("/", description="Directory path")):
    usage = psutil.disk_usage(path)
    return StorageInfo(
        total_gb=usage.total/(1024**3),
        used_gb=usage.used/(1024**3),
        free_gb=usage.free/(1024**3),
        percent=usage.percent
    )

@app.get("/storage/partitions", response_model=list[PartitionInfo])
async def get_partitions():
    return [
        PartitionInfo(device=p.device, mountpoint=p.mountpoint, fstype=p.fstype)
        for p in psutil.disk_partitions()
    ]

@app.get("/system", response_model=SystemInfo)
async def get_system():
    mem = psutil.virtual_memory()
    return SystemInfo(
        cpu_percent=psutil.cpu_percent(interval=0.5),
        ram_percent=mem.percent,
        ram_total_gb=mem.total/(1024**3),
        ram_used_gb=mem.used/(1024**3)
    )

@app.get("/cpu", response_model=CPUInfo)
async def get_cpu():
    freq = psutil.cpu_freq()
    return CPUInfo(
        overall_percent=psutil.cpu_percent(interval=0.5),
        per_core=psutil.cpu_percent(interval=0.5, percpu=True),
        freq_current=freq.current if freq else None,
        freq_min=freq.min if freq else None,
        freq_max=freq.max if freq else None
    )

@app.get("/memory", response_model=MemoryInfo)
async def get_memory():
    mem = psutil.virtual_memory()
    swap = psutil.swap_memory()
    return MemoryInfo(
        total_gb=mem.total/(1024**3),
        available_gb=mem.available/(1024**3),
        used_gb=mem.used/(1024**3),
        percent=mem.percent,
        swap_total_gb=swap.total/(1024**3),
        swap_used_gb=swap.used/(1024**3),
        swap_free_gb=swap.free/(1024**3),
        swap_percent=swap.percent
    )

@app.get("/logs", response_model=LogLines)
async def get_logs(
    file: str = Query("/var/log/README", description="Log file path"),
    lines: int = Query(50, ge=1, le=500)
):
    path = Path(file)
    if not (path.exists() and path.is_file()):
        raise HTTPException(status_code=404, detail="Log file not found")
    try:
        with path.open("rb") as f:
            f.seek(0, os.SEEK_END)
            data = b""
            block = 8192
            while f.tell() > 0 and data.count(b"\n") <= lines:
                jump = min(f.tell(), block)
                f.seek(-jump, os.SEEK_CUR)
                data = f.read(jump) + data
                f.seek(-jump, os.SEEK_CUR)
            last = data.splitlines()[-lines:]
        return LogLines(file=str(path), lines=[ln.decode(errors="ignore") for ln in last])
    except PermissionError:
        raise HTTPException(status_code=403, detail="Permission denied")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0", port=8000, log_level="info")
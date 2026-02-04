Write-Host "=== Configuring Additional Game Disk ==="

# 1. Check if D: is already present (from autounattend)
if (Test-Path "D:\") {
  Write-Host "Drive D: is already mounted. Skipping initialization."
}

else {
# 2. If D: is missing, try to initialize RAW disks
  Write-Host "Detecting uninitialized disks..."
  $rawDisk = Get-Disk | Where-Object { $_.PartitionStyle -eq 'RAW' -and $_.Size -gt 40GB } | Select-Object -First 1

  if ($rawDisk) {
    Write-Host "Initializing Disk $($rawDisk.Number)..."
      Initialize-Disk -Number $rawDisk.Number -PartitionStyle GPT
      New-Partition -DiskNumber $rawDisk.Number -UseMaximumSize -DriveLetter D
      Format-Volume -DriveLetter D -FileSystem NTFS -NewFileSystemLabel "GAMES" -AllocationUnitSize 65536 -Confirm:$false
  } else {
    Write-Host "WARNING: No D: drive found and no RAW disk detected."
  }
}

# 3. Create Library Folders (Safe to run always)
New-Item -ItemType Directory -Force -Path "D:\Games" | Out-Null
New-Item -ItemType Directory -Force -Path "D:\SteamLibrary" | Out-Null

Write-Host "=== Game Disk Configuration Complete ==="

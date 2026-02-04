Write-Host "=== NVIDIA Driver Install (GPU Passthrough Mode) ==="

# ---------------------------------------------------------
# Disable Hyper-V & all virtualization features (prevents Code 43)
# ---------------------------------------------------------
Write-Host "Disabling virtualization features..."

$features = @(
    "Microsoft-Hyper-V-All",
    "HypervisorPlatform",
    "VirtualMachinePlatform",
    "Microsoft-Windows-Subsystem-Linux"
)

foreach ($f in $features) {
    Disable-WindowsOptionalFeature -Online -FeatureName $f -NoRestart -ErrorAction SilentlyContinue
}

# Disable Credential Guard / Memory Integrity
Write-Host "Disabling Device Guard and Memory Integrity..."

reg add "HKLM\System\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f
reg add "HKLM\System\CurrentControlSet\Control\DeviceGuard" /v RequireMicrosoftSignedBootChain /t REG_DWORD /d 0 /f

reg add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard" /v Enabled /t REG_DWORD /d 0 /f

# Disable Memory Integrity (Core Isolation)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LsaCfgFlags /t REG_DWORD /d 0 /f

# ---------------------------------------------------------
# Prevent Windows Update from installing bad NVIDIA drivers
# ---------------------------------------------------------
Write-Host "Preventing Windows Update from automatically replacing NVIDIA drivers..."

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v SearchOrderConfig /t REG_DWORD /d 0 /f

# ---------------------------------------------------------
# Download NVIDIA driver for GTX 970
# ---------------------------------------------------------
$nv = "C:\Windows\Temp\nvidia-driver.exe"

Write-Host "Downloading NVIDIA Game Ready Driver for GTX 970..."

# NVIDIA direct download URL for latest Game Ready driver (GTX 900 series)
# Using the Windows 11 64-bit driver for GeForce GTX 970
$nvDriverUrl = "https://us.download.nvidia.com/Windows/572.83/572.83-desktop-win10-win11-64bit-international-dch-whql.exe"

try {
    # Use BITS for more reliable large file download
    Start-BitsTransfer -Source $nvDriverUrl -Destination $nv -ErrorAction Stop
    Write-Host "Download complete."
}
catch {
    Write-Host "BITS transfer failed, trying Invoke-WebRequest..."
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $nvDriverUrl -OutFile $nv -UseBasicParsing
        Write-Host "Download complete."
    }
    catch {
        Write-Host "ERROR: Failed to download NVIDIA driver: $_"
        exit 1
    }
}

# ---------------------------------------------------------
# Install NVIDIA driver
# ---------------------------------------------------------
if (Test-Path $nv) {
    Write-Host "Installing NVIDIA Driver..."
    # -s: Silent, -noreboot: Don't reboot yet
    $proc = Start-Process -FilePath $nv -ArgumentList "-s -noreboot" -PassThru -Wait

    if ($proc.ExitCode -ne 0) {
        Write-Host "ERROR: NVIDIA Installer failed with code $($proc.ExitCode)"
        exit 1
    }

    # Cleanup installer
    Remove-Item $nv -Force -ErrorAction SilentlyContinue
}
else {
    Write-Host "ERROR: NVIDIA driver download failed!"
    exit 1
}

Write-Host "=== NVIDIA Setup Complete ==="

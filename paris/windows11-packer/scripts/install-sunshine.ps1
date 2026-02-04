Write-Host "=== Installing Sunshine (Game Streaming Server) ==="

$scriptDir = "C:\Windows\Temp\scripts"
$sunLocal = Join-Path $scriptDir "sunshine.msi"

# --------------------------------------------------------
# Fetch the *actual* latest Sunshine MSI from GitHub API
# --------------------------------------------------------
if (-not (Test-Path $sunLocal)) {
    Write-Host "Fetching latest Sunshine release info..."
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/LizardByte/Sunshine/releases/latest"

    $asset = $release.assets | Where-Object { $_.name -match "windows-x64.*\.msi$" } | Select-Object -First 1
    if (-not $asset) {
        Write-Host "ERROR: Sunshine MSI not found in latest release. Check GitHub."
        exit 1
    }

    Write-Host "Downloading Sunshine: $($asset.name)"
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $sunLocal -UseBasicParsing
}

# --------------------------------------------------------
# Install Sunshine silently
# --------------------------------------------------------
Write-Host "Installing Sunshine package..."
Start-Process msiexec.exe -ArgumentList "/i `"$sunLocal`" /qn /norestart" -Wait

Start-Sleep -Seconds 2

# --------------------------------------------------------
# Preseed Sunshine config (disable onboarding)
# --------------------------------------------------------
$sunConfigDir = "$env:ProgramData\Sunshine"
$sunConfig = Join-Path $sunConfigDir "config.json"

if (!(Test-Path $sunConfigDir)) {
    New-Item -ItemType Directory -Path $sunConfigDir | Out-Null
}

# Basic default config (auto-login, disable onboarding web UI)
$configJson = @"
{
  "first_time": false,
  "username": "sunshine",
  "password": "sunshine",
  "capture": {
    "method": "auto"
  },
  "encoder": {
    "hw": "auto"
  }
}
"@

$configJson | Out-File -FilePath $sunConfig -Encoding utf8 -Force

# --------------------------------------------------------
# Add firewall rules (required for Moonlight)
# --------------------------------------------------------
Write-Host "Adding Windows Firewall rules..."

$rules = @(
    @{ Name="Sunshine TCP 47984";   Port=47984;   Protocol="TCP" },
    @{ Name="Sunshine UDP 47998";   Port=47998;   Protocol="UDP" },
    @{ Name="Sunshine UDP 48000";   Port=48000;   Protocol="UDP" },
    @{ Name="Sunshine TCP 47989";   Port=47989;   Protocol="TCP" }
)

foreach ($r in $rules) {
    New-NetFirewallRule `
        -DisplayName $r.Name `
        -Direction Inbound `
        -Protocol $r.Protocol `
        -Action Allow `
        -LocalPort $r.Port `
        -ErrorAction SilentlyContinue | Out-Null
}

# --------------------------------------------------------
# Ensure Sunshine service autostart
# --------------------------------------------------------
if (Get-Service -Name "Sunshine" -ErrorAction SilentlyContinue) {
    Write-Host "Configuring Sunshine service..."
    Set-Service -Name "Sunshine" -StartupType Automatic
    Start-Service -Name "Sunshine"
} else {
    Write-Host "WARNING: Sunshine service missing after install."
}

# --------------------------------------------------------
# Fix GPU permission issues (NVIDIA/AMD)
# --------------------------------------------------------
Write-Host "Adding Sunshine to GPU AllowList..."

$exePath = "C:\Program Files\Sunshine\sunshine.exe"
if (Test-Path $exePath) {
    # For NVENC/AMD AMF video encoder
    & icacls $exePath /grant "*S-1-5-32-545:(RX)" 2>$null | Out-Null
}

Write-Host "Sunshine installed, configured, and service started."

# --------------------------------------------------------
# Cleanup
# --------------------------------------------------------
Remove-Item $sunLocal -Force -ErrorAction SilentlyContinue

Write-Host "=== Sunshine installation complete ==="

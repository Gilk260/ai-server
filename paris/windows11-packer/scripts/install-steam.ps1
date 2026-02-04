Write-Host "=== Installing Steam ==="

$steamExe = "C:\Windows\Temp\scripts\SteamSetup.exe"
$steamDefault = "C:\Program Files (x86)\Steam"
$steamTarget = "D:\Steam"

# Download
if (-not (Test-Path $steamExe)) {
  Invoke-WebRequest -Uri "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" -OutFile $steamExe
}

# Install
Write-Host "Installing Steam..."
Start-Process -FilePath $steamExe -ArgumentList "/S" -Wait

# Ensure Steam is dead before moving
Write-Host "Stopping Steam processes..."
Get-Process steam, steamservice, steamwebhelper -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 5

# Move to D:\ (Only if D: exists)
if (Test-Path "D:\") {
  Write-Host "Moving Steam to $steamTarget..."
  if (Test-Path $steamDefault) {
      Move-Item -Path $steamDefault -Destination $steamTarget -Force
      # Create Junction Point (Compat link)
      cmd /c mklink /J "$steamDefault" "$steamTarget"
  }
}

# Cleanup Autostart
Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\Steam" -ErrorAction SilentlyContinue

Write-Host "=== Steam Installed ==="

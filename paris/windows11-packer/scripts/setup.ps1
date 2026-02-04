Write-Host "=== Base setup starting... ==="

# -------------------------
# Set network to private (Critical for Game Streaming discovery)
# -------------------------
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# -------------------------
# Enable RDP (Backup access)
# -------------------------
Write-Host "Enabling Remote Desktop..."
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# -------------------------
# Disable UAC (Optional: helps with automation, risky for daily driver)
# -------------------------
Write-Host "Disabling UAC..."
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0

# -------------------------
# Disable sleep/hibernation (Critical for Servers/VMs)
# -------------------------
Write-Host "Disabling Sleep and Hibernation..."
powercfg /hibernate off
powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-ac 0
powercfg /change disk-timeout-ac 0

# -------------------------
# Timezone
# -------------------------
Set-TimeZone -Id "Romance Standard Time"

Write-Host "=== Base setup complete ==="

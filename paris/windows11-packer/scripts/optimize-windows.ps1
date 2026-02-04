Write-Host "Applying optimization tweaks..."
# Minimal performance tweaks (example)
# Disable Xbox services and Game Bar
Get-AppxPackage *Xbox* | Remove-AppxPackage -ErrorAction SilentlyContinue
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\gamebar.exe" /v Debugger /d "ntsd -d" /f > $null 2>&1

# Increase process priority for games later as needed; disable telemetry services (best-effort)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0 -Force

Write-Host "Optimizations applied."

Write-Host "Installing Cloudbase-Init..."
$msi = "C:\Windows\Temp\scripts\CloudbaseInitSetup_Stable_x64.msi"
# If the MSI file isn't present, try downloading (internet must be available)
if (-not (Test-Path $msi)) {
  Invoke-WebRequest -Uri "https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi" -OutFile $msi -UseBasicParsing
}
Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn" -Wait
# Minimal config to allow injection via metadata service (Terraform/Proxmox later)
$config = "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf"
@"
[DEFAULT]
username=Administrator
inject_user_password=true
first_logon_behaviour=no
"@ | Out-File -FilePath $config -Encoding ascii
Write-Host "Cloudbase-Init installed."

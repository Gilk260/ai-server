Write-Host "Preparing sysprep..."
# Remove temporary installers if any
Remove-Item -Path "C:\Windows\Temp\scripts\*" -Force -Recurse -ErrorAction SilentlyContinue

# Run Sysprep: OOBE + generalize so the image can be used as a template
$sysprep = "$env:SystemRoot\System32\Sysprep\sysprep.exe"
Start-Process -FilePath $sysprep -ArgumentList "/oobe /generalize /shutdown /quiet" -Wait
# VM will shut down after sysprep; Packer will capture disk image

# Function to stop gamingservices.exe
function Stop-GamingServicesProcess {
    $process = Get-Process | Where-Object { $_.Name -eq "gamingservices" } -ErrorAction SilentlyContinue
    if ($process) {
        Write-Host "Stopping gamingservices.exe..."
        Stop-Process -Name "gamingservices" -Force
        Start-Sleep -Seconds 2
        Write-Host "gamingservices.exe stopped."
    }
}

# Uninstall Xbox-related components
Write-Host "Uninstalling Xbox-related components..."

# Remove Xbox App
Get-AppxPackage -AllUsers *XboxApp* | Remove-AppxPackage
Write-Host "Removed Xbox App."

# Remove Xbox Gaming Overlay
Get-AppxPackage -AllUsers *Microsoft.XboxGamingOverlay* | Remove-AppxPackage
Write-Host "Removed Xbox Gaming Overlay."

# Remove Gaming Services
$gamingServicesRemoved = $false
while (-not $gamingServicesRemoved) {
    Stop-GamingServicesProcess
    try {
        Get-AppxPackage -AllUsers Microsoft.GamingServices | Remove-AppxPackage
        Write-Host "Removed Gaming Services."
        $gamingServicesRemoved = $true
    } catch {
        Write-Host "Gaming Services is still running, retrying removal..."
        Start-Sleep -Seconds 3
    }
}

# Remove Xbox Gaming App
Get-AppxPackage -AllUsers Microsoft.GamingApp | Remove-AppxPackage
Write-Host "Removed Xbox Gaming App."

# Clearing temp/cache files
Write-Host "Clearing cache and temporary files..."
Remove-Item -Path "$env:LOCALAPPDATA\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "$env:ProgramData\Microsoft\Windows\Caches\*" -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Cleared temporary files and cache."

# Countdown for system restart
$restartTime = 15 # Countdown in seconds
Write-Host "The system will restart in $restartTime seconds to apply changes."
for ($i = $restartTime; $i -ge 1; $i--) {
    Write-Host "$i seconds remaining..." -NoNewline
    Start-Sleep -Seconds 1
    Write-Host "`r" -NoNewline
}

# Restarting system
Write-Host "Restarting system now..."
Restart-Computer -Force

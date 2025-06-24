# Windows Debloat - CTT Winutil Script
# Applies additional system optimizations and tweaks using CTT Winutil functionality

$logDir = Join-Path $env:TEMP "WinDebloatLogs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $logDir "08_CTT_Winutil_$timestamp.log") -Append -Force
$start = Get-Date

function Write-LoggedOperation {
    param ([scriptblock]$Block, [string]$Description)
    Write-Host "`n[INFO] $Description"
    try { & $Block; Write-Host "[SUCCESS] $Description completed" } 
    catch { Write-Host "[ERROR] $Description failed: $($_.Exception.Message)" }
}

# Performance settings
Write-LoggedOperation {
    # Enable Ultimate Performance power plan
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

    # Optimize for performance
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\DWM" -Name "EnableAeroPeek" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\DWM" -Name "AlwaysHibernateThumbnails" -Value 0
} "Configuring system performance settings"

# Network settings
Write-LoggedOperation {
    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "*FlowControl" -RegistryValue 0
    Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "*JumboPacket" -RegistryValue 1514
    Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "*PriorityVLANTag" -RegistryValue 0
} "Configuring network settings"

# Privacy settings
Write-LoggedOperation {
    # Disable telemetry
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0

    # Disable location tracking
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"

    # Disable advertising ID
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0
} "Configuring privacy settings"

# Maintenance
Write-LoggedOperation {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "MaintenanceDisabled" -Value 1

    # Disable automatic updates
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1

    # Disable Windows Search
    Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "WSearch" -StartupType Disabled -ErrorAction SilentlyContinue
} "Configuring system maintenance"

$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
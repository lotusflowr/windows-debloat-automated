# ============================================================================
# Windows Debloat - CTT Winutil Script
# ============================================================================
# Purpose: Applies additional system optimizations and tweaks using
#          CTT Winutil functionality.
# ============================================================================

#region Logging Setup
# ============================================================================
# Initialize logging with timestamp
# ============================================================================
$logDir = Join-Path $env:TEMP "WinDebloatLogs"
if (-not (Test-Path $logDir)) { 
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null 
}
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $logDir "08_CTT_Winutil_$timestamp.log") -Append -Force
$start = Get-Date

<#
.TITLE
    Script 08 – CTT Winutil

.SYNOPSIS
    Applies additional system optimizations and tweaks using CTT Winutil functionality.

.DESCRIPTION
    - Configures system performance settings
    - Applies network optimizations
    - Configures privacy settings
    - Sets up system maintenance tasks

.NOTES
    🚀 Optimizes system performance
    🔒 Enhances privacy settings
    📁 Logs saved to $env:TEMP\WinDebloatLogs\08_CTT_Winutil_YYYYMMDD_HHMMSS.log
#>
#endregion

#region Helper Functions
# ============================================================================
# Utility Functions
# ============================================================================
function Write-LoggedOperation {
    param (
        [scriptblock]$Block,
        [string]$Description
    )
    Write-Host "`n[INFO] $Description"
    try {
        & $Block
        Write-Host "[SUCCESS] $Description completed.`n"
    } catch {
        Write-Host "[ERROR] $Description failed: $($_.Exception.Message)`n"
    }
}
#endregion

#region Performance Settings
# ============================================================================
# Configure System Performance
# ============================================================================
Write-LoggedOperation {
    # Enable Ultimate Performance power plan
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

    # Optimize for performance
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\DWM" -Name "EnableAeroPeek" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\DWM" -Name "AlwaysHibernateThumbnails" -Value 0
} "Configuring system performance settings"
#endregion

#region Network Settings
# ============================================================================
# Configure Network Settings
# ============================================================================
Write-LoggedOperation {
    # Optimize network adapter settings
    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "*FlowControl" -RegistryValue 0
    Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "*JumboPacket" -RegistryValue 1514
    Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "*PriorityVLANTag" -RegistryValue 0
} "Configuring network settings"
#endregion

#region Privacy Settings
# ============================================================================
# Configure Privacy Settings
# ============================================================================
Write-LoggedOperation {
    # Disable telemetry
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0

    # Disable location tracking
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"

    # Disable advertising ID
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0
} "Configuring privacy settings"
#endregion

#region Maintenance
# ============================================================================
# Configure System Maintenance
# ============================================================================
Write-LoggedOperation {
    # Disable automatic maintenance
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "MaintenanceDisabled" -Value 1

    # Disable automatic updates
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1

    # Disable Windows Search
    Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "WSearch" -StartupType Disabled -ErrorAction SilentlyContinue
} "Configuring system maintenance"
#endregion

#region Wrap Up
# ============================================================================
# Script Completion
# ============================================================================
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
#endregion

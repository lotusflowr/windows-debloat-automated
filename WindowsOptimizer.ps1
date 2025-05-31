# ============================================================================
# Windows Debloat - Windows Optimizer Script
# ============================================================================
# Purpose: Downloads and runs the latest Optimizer.exe with predefined
#          configurations for system optimization.
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
Start-Transcript -Path (Join-Path $logDir "05_WindowsOptimizer_$timestamp.log") -Append -Force
$start = Get-Date

<#
.TITLE
    Script 05 – Windows Optimizer

.SYNOPSIS
    Downloads and runs the latest Optimizer.exe with predefined configurations.

.DESCRIPTION
    - Downloads the latest Optimizer.exe from GitHub
    - Applies predefined optimization settings via JSON config
    - Cleans up temporary files after completion

.NOTES
    ✅ Internet required for downloading executable
    🧪 Uses predefined optimization settings
    📁 Logs saved to $env:TEMP\WinDebloatLogs\05_WindowsOptimizer_YYYYMMDD_HHMMSS.log

.LINK
    https://github.com/hellzerg/optimizer
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

#region Configuration
# ============================================================================
# Optimization Configuration
# ============================================================================
$configJson = @'
{
    "WindowsVersion": "__OSVERSION__",
    "Tweaks": {
        "DisableTelemetry": true,
        "DisableErrorReporting": true,
        "DisableAdvertisingID": true,
        "DisableNewsAndInterests": true,
        "DisableStoreTaskbarPin": true,
        "DisableWidgets": true,
        "DisableFeedback": true,
        "DisableTailoredExperiences": true,
        "DisableConsumerFeatures": true,
        "DisableBackgroundApps": true,
        "DisableHibernation": true,
        "DisableNotifications": true,
        "DisableLocation": true,
        "DisableIPv6": true,
        "DisableSuggestedContent": true,
        "DisableSearchSuggestions": true,
        "DisableWiFiSense": true,
        "EnableUltimatePerformance": true,
        "HideTaskbarWeather": true,
        "DisableMyPeople": true,
        "EnableLongPaths": true,
        "DisableTPMCheck": true,
        "DisableSensorServices": true,
        "RemoveCastToDevice": true,
        "RestoreClassicPhotoViewer": true,
        "DisableModernStandby": true,
        "DisableAutomaticUpdates": true,
        "DisableStoreUpdates": true,
        "DisableInsiderService": true,
        "ExcludeDrivers": true,
        "DisableTelemetryServices": true,
        "DisableCortana": true,
        "DisablePrivacyOptions": true,
        "DisableStartMenuAds": true,
        "DisableEdgeTelemetry": true,
        "DisableEdgeDiscoverBar": true,
        "EnableGamingMode": true,
        "DisableXboxLive": true,
        "DisableGameBar": true,
        "DisableWindowsInk": true,
        "DisableSpellingTyping": true,
        "DisableCloudClipboard": true
    },
    "AdvancedTweaks": {
        "SvchostProcessSplitting": {
            "Disable": false,
            "RAM": null
        }
    },
    "Cleaner": {
        "RemovePUA": true,
        "RemoveOptionalFeatures": true,
        "RemoveOneDrive": true,
        "RemoveTeams": true
    },
    "RegistryFix": {
        "TaskManager": true,
        "CommandPrompt": true,
        "ControlPanel": true,
        "FolderOptions": true,
        "RunDialog": true,
        "RightClickMenu": true,
        "WindowsFirewall": true,
        "RegistryEditor": true
    },
    "Integrator": {
        "OpenWithCMD": true
    },
    "PostAction": {
        "Restart": true,
        "RestartType": "Normal"
    }
}
'@

# Apply OS version to config
try {
    $osVersion = if ([System.Environment]::OSVersion.Version.Build -ge 22000) { "11" } else { "10" }
    $configJson = $configJson -replace '"WindowsVersion":\s*"__OSVERSION__"', "`"WindowsVersion`": `"$osVersion`""
} catch {
    Write-Host "[WARNING] Could not determine OS version, defaulting to Windows 10"
    $configJson = $configJson -replace '"WindowsVersion":\s*"__OSVERSION__"', '"WindowsVersion": "10"'
}
#endregion

#region Download
# ============================================================================
# Download Optimizer
# ============================================================================
Write-LoggedOperation {
    $release = Invoke-RestMethod "https://api.github.com/repos/hellzerg/optimizer/releases/latest" -Headers @{ "User-Agent" = "PS" }
    $exeUrl = ($release.assets | Where-Object name -like "*.exe").browser_download_url
    Invoke-WebRequest -Uri $exeUrl -OutFile "$env:TEMP\Optimizer.exe"
} "Downloading Optimizer.exe"
#endregion

#region Execution
# ============================================================================
# Run Optimizer
# ============================================================================
Write-LoggedOperation {
    # Save config to file
    $configPath = "$env:TEMP\optimizer_config.json"
    $configJson | Out-File -FilePath $configPath -Encoding utf8 -Force

    # Run Optimizer with config
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "$env:TEMP\Optimizer.exe"
    $psi.Arguments = "/config=$configPath"
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    $null = $proc.Start()

    $stdout = $proc.StandardOutput
    $stderr = $proc.StandardError

    while (-not $proc.HasExited) {
        while (!$stdout.EndOfStream) {
            $line = $stdout.ReadLine()
            if ($line) { Write-Host $line }
        }
        Start-Sleep -Milliseconds 100
    }

    while (!$stdout.EndOfStream) {
        $line = $stdout.ReadLine()
        if ($line) { Write-Host $line }
    }

    $errors = $stderr.ReadToEnd()
    if ($errors) {
        Write-Host "`n=== STDERR ===`n$errors"
    }
} "Running Optimizer with configuration"
#endregion

#region Cleanup
# ============================================================================
# Cleanup Temporary Files
# ============================================================================
Write-LoggedOperation {
    Remove-Item "$env:TEMP\Optimizer.exe" -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\optimizer_config.json" -Force -ErrorAction SilentlyContinue
} "Cleaning up Optimizer files"
#endregion

#region Wrap Up
# ============================================================================
# Script Completion
# ============================================================================
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
#endregion
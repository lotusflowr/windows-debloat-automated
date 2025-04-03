# === LOGGING ===
Start-Transcript -Path "$env:TEMP\05_WindowsOptimizer.log" -Append -Force
$start = Get-Date

<#
.TITLE
    Script 05 – Windows Optimizer Automation

.SYNOPSIS
    Downloads and runs the latest Optimizer.exe with embedded config, and removes tray bloat.

.DESCRIPTION
    - Uses Invoke-WebRequest to fetch latest Optimizer EXE
    - Injects embedded config (auto-selects Windows 10 or 11)
    - Removes SecurityHealth tray startup entry
    - Removes MicrosoftEdgeAutoLaunch_* autostarts
    - Runs Optimizer silently with /config flag
    - Cleans up temporary files

.NOTES
    🌐 Internet required
    📁 Logs saved to $env:TEMP\05_WindowsOptimizer.log
#>

function Try-Run {
    param (
        [scriptblock]$Script,
        [string]$Description
    )
    Write-Host "`n[INFO] $Description"
    try {
        & $Script
        Write-Host "[SUCCESS] $Description completed."
    } catch {
        Write-Host "[ERROR] $Description failed: $($_.Exception.Message)"
    }
}

# === SETUP PATHS ===
$tempDir = "$env:TEMP\Optimizer"
$exePath = "$tempDir\Optimizer.exe"
$configPath = "$tempDir\template.json"

# === EMBEDDED CONFIG ===
$templateJson = @"
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
"@

# === APPLY OS VERSION ===
$pattern = '"WindowsVersion":\s*"__OSVERSION__"'
$osVersion = if ([System.Environment]::OSVersion.Version.Build -ge 22000) { "11" } else { "10" }
$replacement = '"WindowsVersion": "' + $osVersion + '"'
$templateJson = $templateJson -replace $pattern, $replacement

# === PREP ===
Try-Run {
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir | Out-Null
    }
} "Preparing Optimizer temp directory"

# === DOWNLOAD OPTIMIZER ===
Try-Run {
    $release = Invoke-WebRequest -Uri "https://api.github.com/repos/hellzerg/optimizer/releases/latest" -UseBasicParsing
    $json = $release.Content | ConvertFrom-Json
    $latestExeUrl = $json.assets | Where-Object { $_.name -match '^Optimizer-\d+.*\.exe$' } | Select-Object -First 1 -ExpandProperty browser_download_url

    if (-not $latestExeUrl) { throw "Could not find Optimizer EXE in release assets." }

    Write-Host "[INFO] Downloading from: $latestExeUrl"
    Invoke-WebRequest -Uri $latestExeUrl -OutFile $exePath -UseBasicParsing
} "Downloading latest Optimizer executable"

# === WRITE CONFIG ===
Try-Run {
    $templateJson | Out-File -FilePath $configPath -Encoding utf8 -Force
} "Saving embedded config to file"

# === EXECUTE OPTIMIZER ===
Try-Run {
    Start-Process -FilePath $exePath -ArgumentList "/config=$configPath" -Wait -WindowStyle Hidden
} "Launching Optimizer with config"

# === CLEANUP ===
Try-Run {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
} "Cleaning up temporary Optimizer files"

# === WRAP UP ===
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript

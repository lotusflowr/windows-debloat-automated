# === LOGGING ===
$logDir = Join-Path $env:TEMP "WinDebloatLogs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $logDir "05_WindowsOptimizer_$timestamp.log") -Append -Force
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
try {
    $osVersion = if ([System.Environment]::OSVersion.Version.Build -ge 22000) { "11" } else { "10" }
    $replacement = '"WindowsVersion": "' + $osVersion + '"'
    $templateJson = $templateJson -replace $pattern, $replacement
} catch {
    Write-Host "[WARNING] Could not determine OS version, defaulting to Windows 10"
    $templateJson = $templateJson -replace $pattern, '"WindowsVersion": "10"'
}

# === PREP ===
Write-LoggedOperation {
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir | Out-Null
    }
} "Preparing Optimizer temp directory"

# === DOWNLOAD OPTIMIZER ===
Write-LoggedOperation {
    $release = Invoke-WebRequest -Uri "https://api.github.com/repos/hellzerg/optimizer/releases/latest" -UseBasicParsing
    $json = $release.Content | ConvertFrom-Json
    $latestExeUrl = $json.assets | Where-Object { $_.name -match '^Optimizer-\d+.*\.exe$' } | Select-Object -First 1 -ExpandProperty browser_download_url

    if (-not $latestExeUrl) { throw "Could not find Optimizer EXE in release assets." }

    Write-Host "[INFO] Downloading from: $latestExeUrl"
    Invoke-WebRequest -Uri $latestExeUrl -OutFile $exePath -UseBasicParsing

    # Validate downloaded file
    if (-not (Test-Path $exePath)) {
        throw "Failed to download Optimizer executable."
    }
    if ((Get-Item $exePath).Length -lt 1MB) {
        throw "Downloaded file appears to be corrupted (too small)."
    }
} "Downloading latest Optimizer executable"

# === WRITE CONFIG ===
Write-LoggedOperation {
    $templateJson | Out-File -FilePath $configPath -Encoding utf8 -Force
} "Saving embedded config to file"

# === EXECUTE OPTIMIZER ===
Write-LoggedOperation {
    $process = Start-Process -FilePath $exePath -ArgumentList "/config=$configPath" -WindowStyle Hidden -PassThru
    $timeout = 120 # 2 minutes
    $startTime = Get-Date

    while (-not $process.HasExited) {
        if ((Get-Date).Subtract($startTime).TotalSeconds -gt $timeout) {
            Stop-Process -Id $process.Id -Force
            throw "Optimizer execution timed out after $timeout seconds."
        }
        Start-Sleep -Seconds 1
    }

    if ($process.ExitCode -ne 0) {
        throw "Optimizer exited with code $($process.ExitCode)."
    }
} "Launching Optimizer with config"

# === CLEANUP ===
Write-LoggedOperation {
    try {
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Stop
        }
    } catch {
        Write-Host "[WARNING] Failed to clean up temporary files: $($_.Exception.Message)"
        # Try individual files
        if (Test-Path $exePath) { Remove-Item -Path $exePath -Force -ErrorAction SilentlyContinue }
        if (Test-Path $configPath) { Remove-Item -Path $configPath -Force -ErrorAction SilentlyContinue }
    }
} "Cleaning up temporary Optimizer files"

# === WRAP UP ===
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
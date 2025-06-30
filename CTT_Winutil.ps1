# Windows Debloat - CTT WinUtil Setup and Tweaks
# Executes Chris Titus Tech's WinUtil tool with a predefined JSON config for system debloating and tweaking

# Logging
$logDir = Join-Path $env:TEMP "WinDebloatLogs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $logDir "07_CTT_Winutil_Tweaks_$timestamp.log") -Append -Force
$start = Get-Date

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

# Configuration
$configJson = @'
{
  "WPFFeature": [
    "WPFFeatureDisableSearchSuggestions"
  ],
  "WPFInstall": [],
  "Install": [],
  "WPFTweaks": [
    "WPFTweaksRemoveHomeGallery",
    "WPFTweaksDVR",
    "WPFTweaksEdgeDebloat",
    "WPFTweaksConsumerFeatures",
    "WPFTweaksDisableipsix",
    "WPFTweaksHome",
    "WPFTweaksDisableBGapps",
    "WPFTweaksStorage",
    "WPFTweaksHiber",
    "WPFTweaksRemoveCopilot",
    "WPFTweaksLoc",
    "WPFTweaksPowershell7Tele",
    "WPFTweaksWifi",
    "WPFTweaksServices",
    "WPFTweaksRecallOff",
    "WPFTweaksTele",
    "WPFTweaksIPv46",
    "WPFTweaksDisableNotifications"
  ]
}
'@

# Path
$configPath  = "$env:TEMP\winutil_config.json"
$winutilPath = "$env:TEMP\winutil.ps1"

# Save config
Write-LoggedOperation {
    $configJson | Out-File -FilePath $configPath -Encoding utf8 -Force
} "Saving WinUtil configuration to $configPath"

# Validate config
try {
    $null = $configJson | ConvertFrom-Json
} catch {
    Write-Host "[ERROR] Invalid JSON configuration: $($_.Exception.Message)"
    exit 1
}

# Download and patch script
Write-LoggedOperation {
    try {
        $response = Invoke-WebRequest 'https://christitus.com/win' -UseBasicParsing
        if ($response.StatusCode -ne 200) {
            throw "Failed to download WinUtil script. Status code: $($response.StatusCode)"
        }
        $response.Content | Set-Content -Path $winutilPath -Force
    } catch {
        throw "Failed to download WinUtil script: $($_.Exception.Message)"
    }

    if (-not (Test-Path $winutilPath)) {
        throw "Failed to save WinUtil script."
    }
    Write-Host "[INFO] Script saved to $winutilPath"

    # Remove feature install block
    $featureRegex  = '(?ms)(?<=^\s*Write-Host "Installing features..."\s*).*?(?=\s*Write-Host "Done.")'
    $patchedScript = (Get-Content -Raw $winutilPath) -replace $featureRegex, ''
    Set-Content -Path $winutilPath -Value $patchedScript
    Write-Host "[INFO] Removed feature installation block."

    # Auto-close patch
    $exitPatch = 'Write-Host "--     Tweaks are Finished    ---"; Start-Sleep -Seconds 1; Stop-Process -Id $PID -Force'
    $patchedScript = (Get-Content -Raw $winutilPath) -replace 'Write-Host "--     Tweaks are Finished    ---"', $exitPatch
    Set-Content -Path $winutilPath -Value $patchedScript
    Write-Host "[INFO] Applied auto-close patch."
} "Downloading and patching WinUtil script"

# Run patched winutil
Write-LoggedOperation {
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$winutilPath`" -Config `"$configPath`" -Run" -Wait
} "Running WinUtil with configuration"

# Cleanup
Write-LoggedOperation {
    Remove-Item -LiteralPath $winutilPath -Force -ErrorAction SilentlyContinue
} "Deleting WinUtil script"

# Wrapup
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
Restart-Computer -Force
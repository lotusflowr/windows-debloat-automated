# === LOGGING ===
Start-Transcript -Path "$env:TEMP\07_CTT_Winutil_Tweaks.log" -Append -Force
$start = Get-Date

<#
.TITLE
    Script 05 – CTT WinUtil Setup and Tweaks

.SYNOPSIS
    Executes Chris Titus Tech's WinUtil tool with a predefined JSON config for system debloating and tweaking.

.DESCRIPTION
    - Downloads the latest WinUtil script from the official source
    - Applies user-defined tweaks from an embedded JSON config
    - Auto-patches script to skip feature installations and auto-close when done

.HOW TO CUSTOMIZE CONFIG:
    1. Open PowerShell and run:
         irm 'https://christitus.com/win' | iex
    2. Go to the "Tweaks" tab and select the tweaks you want (avoid installing software here).
    3. Click the ⚙️ gear icon in the top-right and export your config as JSON.
    4. Replace the `$configJson` block below with your exported content.

.NOTES
    ✅ Internet required for downloading script
    📝 Config saved to $env:TEMP\winutil_config.json
    📁 Logs saved to $env:TEMP\07_CTT_Winutil_Tweaks.log

.LINK
    https://github.com/ChrisTitusTech/winutil
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

# === CONFIG JSON ===
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

# === PATH SETUP ===
$configPath  = "$env:TEMP\winutil_config.json"
$winutilPath = "$env:TEMP\winutil.ps1"

# === SAVE CONFIG ===
Write-LoggedOperation {
    $configJson | Out-File -FilePath $configPath -Encoding utf8 -Force
} "Saving WinUtil configuration to $configPath"

# === DOWNLOAD + PATCH SCRIPT ===
Write-LoggedOperation {
    Invoke-RestMethod 'https://christitus.com/win' -OutFile $winutilPath

    if (-not (Test-Path $winutilPath)) {
        throw "Failed to download WinUtil script."
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

# === RUN WINUTIL ===
Write-LoggedOperation {
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$winutilPath`" -Config `"$configPath`" -Run" -Wait
} "Running WinUtil with configuration"

# === CLEANUP ===
Write-LoggedOperation {
    Remove-Item -LiteralPath $winutilPath -Force -ErrorAction SilentlyContinue
} "Deleting WinUtil script"

# === WRAP UP ===
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
Restart-Computer -Force

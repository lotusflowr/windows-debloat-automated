# ======================================================================
# Windows Debloat - SysPrep Debloater Script
# ======================================================================
# Purpose: Removes bloatware and unnecessary components from Windows
#          during the SysPrep phase.
# ======================================================================

#region Logging Setup
# ===================================
# Initialize logging with timestamp
# ===================================
$logDir = Join-Path $env:TEMP "WinDebloatLogs"
if (-not (Test-Path $logDir)) { 
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null 
}
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $logDir "02_SysPrep_Debloater_$timestamp.log") -Append -Force
$start = Get-Date

<#
.TITLE
    Script 02 – Sysprep Debloater

.SYNOPSIS
    Removes bloatware and unnecessary components from Windows during the SysPrep phase.

.DESCRIPTION
    - Removes Windows Store apps
    - Disables unnecessary services
    - Removes scheduled tasks
    - Cleans up temporary files

.NOTES
    ✅ Internet access is required for online components (OneDrive removal)
    👤 Safe to run under a standard user context (FirstLogonCommands)
    📁 Logs are saved to $env:TEMP\WinDebloatLogs\02_SysPrep_Debloater_YYYYMMDD_HHMMSS.log

.LINK
    https://github.com/asheroto/UninstallOneDrive
#>
#endregion

#region Helper Functions
# ===================================
# Utility Functions
# ===================================
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

#region App Removal
# ===================================
# Remove Windows Store Apps
# ===================================
Write-LoggedOperation {
    Write-Host "[DETAIL] Removing provisioned apps..."
    $appsToRemove = @(
        'Microsoft.Microsoft3DViewer'
        'Microsoft.BingSearch'
        'Microsoft.BingFinance'
        'Microsoft.BingSports'
        'Microsoft.BingNews'
        'Microsoft.BingWeather'
        'Microsoft.BingTravel'
        'Microsoft.BingFoodAndDrink'
        'Microsoft.BingHealthAndFitness'
        'Microsoft.BingTranslator'
        'Microsoft.Wallet'
        'Microsoft.WindowsCamera'
        'Clipchamp.Clipchamp'
        'Microsoft.549981C3F5F10'
        '*DevHome*'
        'MicrosoftCorporationII.MicrosoftFamily'
        'Microsoft.WindowsFeedbackHub'
        'Microsoft.GetHelp'
        'microsoft.windowscommunicationsapps'
        'Microsoft.WindowsMaps'
        'Microsoft.ZuneVideo'
        'Microsoft.MicrosoftOfficeHub'
        'Microsoft.Office.OneNote'
        'Microsoft.OutlookForWindows'
        'Microsoft.MSPaint'
        'Microsoft.People'
        'Microsoft.Windows.Photos'
        'Microsoft.PowerAutomateDesktop'
        'MicrosoftCorporationII.QuickAssist'
        'Microsoft.SkypeApp'
        'Microsoft.ScreenSketch'
        'Microsoft.MicrosoftSolitaireCollection'
        'MSTeams'
        'Microsoft.Getstarted'
        'Microsoft.WindowsSoundRecorder'
        'Microsoft.ZuneMusic'
        'Microsoft.Xbox.TCUI'
        'Microsoft.XboxGameOverlay'
        'Microsoft.XboxGamingOverlay'
        'Microsoft.XboxSpeechToTextOverlay'
        'Microsoft.GamingApp'
        'Microsoft.YourPhone'
        'Microsoft.OneDrive'
        'Microsoft.MixedReality.Portal'
        'Microsoft.Windows.Ai.Copilot.Provider'
        'Microsoft.WindowsMeetNow'
        'Microsoft.Office.Lens'
        '*CandyCrush*'
        '*Netflix*'
    )

    foreach ($app in $appsToRemove) {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    }
} "Removing Windows Store apps"
#endregion

#region Service Disabling
# ===================================
# Disable Unnecessary Services
# ===================================
Write-LoggedOperation {
    $servicesToDisable = @(
        "DiagTrack"
        "dmwappushservice"
        "HomeGroupListener"
        "HomeGroupProvider"
        "lfsvc"
        "MapsBroker"
        "NetTcpPortSharing"
        "RemoteAccess"
        "RemoteRegistry"
        "SharedAccess"
        "TrkWks"
        "WbioSrvc"
        "WMPNetworkSvc"
        "WwanSvc"
    )

    foreach ($service in $servicesToDisable) {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    }
} "Disabling unnecessary services"
#endregion

#region Task Removal
# ===================================
# Remove Scheduled Tasks
# ===================================
Write-LoggedOperation {
    $tasksToRemove = @(
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
        "\Microsoft\Windows\Application Experience\StartupAppTask"
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
        "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    )

    foreach ($task in $tasksToRemove) {
        Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue
    }
} "Removing scheduled tasks"
#endregion

#region Cleanup
# ===================================
# Cleanup Temporary Files
# ===================================
Write-LoggedOperation {
    # Clear Windows Update Cache
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:windir\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue

    # Clear Temporary Files
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Clear Windows Error Reports
    Remove-Item "$env:ProgramData\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue
} "Cleaning up temporary files"
#endregion

#region Wrap Up
# ===================================
# Script Completion
# ===================================
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
#endregion
# Windows Debloat - SysPrep Debloater Script
# Removes bloatware and unnecessary components from Windows

# Logging
$logDir = Join-Path $env:TEMP "WinDebloatLogs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $logDir "02_SysPrep_Debloater_$timestamp.log") -Append -Force
$start = Get-Date

function Write-LoggedOperation {
    param ([scriptblock]$Block, [string]$Description)
    Write-Host "`n[INFO] $Description"
    try { & $Block; Write-Host "[SUCCESS] $Description completed" } 
    catch { Write-Host "[ERROR] $Description failed: $($_.Exception.Message)" }
}

# App removal
Write-LoggedOperation {
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

# Service disabling
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

# Task removal
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

# Cleanup
Write-LoggedOperation {
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:windir\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Clear Windows Error Reports
    Remove-Item "$env:ProgramData\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue
} "Cleaning up temporary files"

$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
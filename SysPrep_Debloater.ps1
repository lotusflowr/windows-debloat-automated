# === LOGGING ===
Start-Transcript -Path "$env:TEMP\02_SysPrep_Debloater.log" -Append -Force
$start = Get-Date

<#
.TITLE
    Script 02 – Sysprep Debloater & Cleanup

.SYNOPSIS
    Post-setup script to clean Windows from unnecessary preinstalled software, apps, and features.

.DESCRIPTION
    - Strips common PUWs (Provisioned Windows Apps)
    - Removes optional Windows features
    - Fully uninstalls Microsoft Teams
    - Blocks Dev Home and New Outlook auto-installation
    - Removes OneDrive using asheroto's PowerShell script

.NOTES
    ✅ Internet access is required for online components (OneDrive removal)
    👤 Safe to run under a standard user context (FirstLogonCommands)
    📁 Logs are saved to $env:TEMP\02_SysPrep_Debloater.log

.LINK
    https://github.com/asheroto/UninstallOneDrive
#>

# === UTILITY: Safe Execution Wrapper ===
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

# === REMOVE BLOATWARE (PUWs) ===
Write-LoggedOperation {
    Write-Host "[DETAIL] Removing provisioned apps..."
    $provisionedApps = @(
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
    Get-AppxProvisionedPackage -Online | Where-Object {
        $provisionedApps -contains $_.DisplayName -or ($provisionedApps | Where-Object { $_ -like "*" })
    } | Remove-AppxProvisionedPackage -AllUsers -Online
} "Removing provisioned apps (PUWs)"


# === REMOVE OPTIONAL FEATURES ===
Write-LoggedOperation {
    Write-Host "[DETAIL] Uninstalling legacy and optional features..."
    $optionalFeatures = @(
        'MathRecognizer'
        'OpenSSH.Client'
        'App.StepsRecorder'
        'Microsoft.Windows.WordPad'
    )
    Get-WindowsCapability -Online | Where-Object {
        ($_.Name -split '~')[0] -in $optionalFeatures
    } | Remove-WindowsCapability -Online
} "Removing optional Windows features"

# === WRAP UP ===
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript

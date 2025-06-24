# Windows Debloat - UI Tweaks Script
# Applies Explorer and taskbar behavior tweaks and privacy settings

$logDir = Join-Path $env:TEMP "WinDebloatLogs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $logDir "01_UI_Tweaks_$timestamp.log") -Append -Force
$start = Get-Date

function Write-LoggedOperation {
    param ([scriptblock]$Block, [string]$Description)
    Write-Host "`n[INFO] $Description"
    try { & $Block; Write-Host "[SUCCESS] $Description completed" } 
    catch { Write-Host "[ERROR] $Description failed: $($_.Exception.Message)" }
}

# Explorer & UI Tweaks
Write-LoggedOperation {
    # Taskbar and Widgets
    Write-Host "→ Removing Widgets"
    reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f

    # Notepad Settings
    Write-Host "→ Removing Store banner in Notepad"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Notepad" /v ShowStoreBanner /t REG_DWORD /d 0 /f

    # File Explorer Behavior
    Write-Host "→ Setting File Explorer to open 'This PC'"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 1 /f

    # Alt+Tab Behavior
    Write-Host "→ Setting Alt+Tab to show only open windows"
    reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v MultiTaskingAltTabFilter /t REG_DWORD /d 3 /f

    # Window Management
    Write-Host "→ Disabling Snap Assist Flyout"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v SnapAssist /t REG_DWORD /d 0 /f

    # Store Integration
    Write-Host "→ Preventing Store app pinning to taskbar"
    reg.exe add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoPinningStoreToTaskbar /t REG_DWORD /d 1 /f
} "Applying File Explorer and taskbar behavior tweaks"
#endregion

# Desktop cleanup
Write-LoggedOperation {
    Remove-Item "$env:USERPROFILE\Desktop\Microsoft Edge.lnk" -Force -ErrorAction SilentlyContinue
} "Removing Microsoft Edge shortcut from Desktop"

# Taskbar icons & news
Write-LoggedOperation {
    # News and Interests Panel
    Write-Host "→ Disabling News and Interests panel"
    reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsEnabled /t REG_DWORD /d 0 /f

    # News and Interests Hover
    Write-Host "→ Disabling News and Interests hover popup"
    reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarOpenOnHover /t REG_DWORD /d 0 /f

    # Meet Now Button
    Write-Host "→ Hiding Meet Now button from taskbar"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v HideSCAMeetNow /t REG_DWORD /d 1 /f
} "Disabling taskbar news, widgets, and chat icons"

# Privacy & telemetry
Write-LoggedOperation {
    # Language and Personalization
    Write-Host "→ Disabling language list sharing with websites"
    reg.exe add "HKCU\Control Panel\International\User Profile" /v HttpAcceptLanguageOptOut /t REG_DWORD /d 1 /f

    Write-Host "→ Disabling personalization consent"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v AcceptedPrivacyPolicy /t REG_DWORD /d 0 /f

    # Input Collection
    Write-Host "→ Disabling collection of typed text and handwriting"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\InputPersonalization" /v RestrictImplicitTextCollection /t REG_DWORD /d 1 /f
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\InputPersonalization" /v RestrictImplicitInkCollection /t REG_DWORD /d 1 /f

    # Feedback and Telemetry
    Write-Host "→ Disabling feedback sampling and related services"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback" /v AutoSample /t REG_DWORD /d 0 /f
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback" /v ServiceEnabled /t REG_DWORD /d 0 /f

    # Telemetry and Advertising
    Write-Host "→ Disabling telemetry and advertising ID features"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v NumberOfSIUFInPeriod /t REG_DWORD /d 0 /f
    reg.exe add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableTailoredExperiencesWithDiagnosticData /t REG_DWORD /d 1 /f
    reg.exe add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
} "Applying privacy and telemetry restrictions"
#endregion

#region Telemetry & Customer Experience
# ===================================
# Customer Experience and Telemetry Settings
# ===================================
Write-LoggedOperation {
    # Disable Customer Experience Improvement Program
    Write-Host "→ Disabling Customer Experience Improvement Program"
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient" /v CEIPEnable /t REG_DWORD /d 0 /f

    # Disable Application Telemetry
    Write-Host "→ Disabling Application Telemetry"
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v AITEnable /t REG_DWORD /d 0 /f

    # Disable Inventory Collection
    Write-Host "→ Disabling Inventory Collection"
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v DisableInventory /t REG_DWORD /d 1 /f

    # Disable Program Compatibility Assistant
    Write-Host "→ Disabling Program Compatibility Assistant"
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v DisablePCA /t REG_DWORD /d 1 /f

    # Disable Application Telemetry
    Write-Host "→ Disabling Application Telemetry"
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v DisableUAR /t REG_DWORD /d 1 /f
} "Disabling telemetry and customer experience tasks"

$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
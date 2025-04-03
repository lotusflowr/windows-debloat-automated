# === LOGGING ===
Start-Transcript -Path "$env:TEMP\01_UI_Tweaks.log" -Append -Force
$start = Get-Date

<#
.TITLE
    Script 01 – UI, Taskbar, and Privacy Tweaks

.SYNOPSIS
    Applies Explorer and taskbar behavior tweaks and disables various telemetry and ad-related settings via the registry.

.DESCRIPTION
    - Optimizes File Explorer and taskbar behavior
    - Removes unwanted UI components (e.g. Widgets, Meet Now)
    - Disables suggestions, feedback, and advertising telemetry
    - Hardens privacy for first-logon or automated Windows deployments

.NOTES
    ✅ Safe to run repeatedly (idempotent registry writes)
    🛠️ Intended for use during FirstLogon or SetupComplete
    📁 Logs all actions to $env:TEMP\01_UI_Tweaks.log
#>

# === FUNCTION: EXECUTION WRAPPER ===
function Try-Run {
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

# === EXPLORER UI ===
Try-Run {
    Write-Host "→ Removing Store banner in Notepad"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Notepad" /v ShowStoreBanner /t REG_DWORD /d 0 /f

    Write-Host "→ Setting File Explorer to open 'This PC'"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 1 /f

    Write-Host "→ Setting Alt+Tab to show only open windows"
    reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v MultiTaskingAltTabFilter /t REG_DWORD /d 3 /f

    Write-Host "→ Disabling Snap Assist Flyout"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v SnapAssist /t REG_DWORD /d 0 /f
} "Applying additional File Explorer UI tweaks"

# === TASKBAR ICONS ===
Try-Run {
    Write-Host "→ Hiding Meet Now button from taskbar"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v HideSCAMeetNow /t REG_DWORD /d 1 /f
} "Disabling Meet Now icon"

# === PRIVACY & INPUT ===
Try-Run {
    Write-Host "→ Disabling language list sharing with websites"
    reg.exe add "HKCU\Control Panel\International\User Profile" /v HttpAcceptLanguageOptOut /t REG_DWORD /d 1 /f

    Write-Host "→ Disabling personalization consent"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v AcceptedPrivacyPolicy /t REG_DWORD /d 0 /f

    Write-Host "→ Disabling collection of typed text and handwriting"
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\InputPersonalization" /v RestrictImplicitTextCollection /t REG_DWORD /d 1 /f
    reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\InputPersonalization" /v RestrictImplicitInkCollection /t REG_DWORD /d 1 /f
} "Applying additional privacy restrictions"

# === WRAP UP ===
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
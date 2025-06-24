# Windows Debloat - User Setup Script
# Configures keyboard layout, wallpaper, shortcuts, and Windows activation

$logDir = Join-Path $env:TEMP "WinDebloatLogs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $logDir "04_UserSetup_$timestamp.log") -Append -Force
$start = Get-Date

function Write-LoggedOperation {
    param ([scriptblock]$Block, [string]$Description)
    Write-Host "`n[INFO] $Description"
    try { & $Block; Write-Host "[SUCCESS] $Description completed" } 
    catch { Write-Host "[ERROR] $Description failed: $($_.Exception.Message)" }
}

# Keyboard layout
Write-LoggedOperation {
    # To customize: Run Get-WinUserLanguageList to view input/language codes
    # Replace 'en-CA' and '1009:00011009' with your own layout if desired
    $langList = New-WinUserLanguageList "en-CA"
    $langList[0].InputMethodTips.Clear()
    $langList[0].InputMethodTips.Add("1009:00011009")  # Canadian Multilingual Standard
    Set-WinUserLanguageList $langList -Force
} "Setting keyboard layout to English (Canada) - Canadian Multilingual"
#endregion

# Wallpaper
$W10_Wallpaper = "C:\Windows\Web\Wallpaper\Theme1\img4.jpg"
$W11_Wallpaper = "C:\Windows\Web\Wallpaper\ThemeA\img20.jpg"

Write-LoggedOperation {
    $wallpaperToApply = if (Test-Path $W10_Wallpaper) { $W10_Wallpaper }
    elseif (Test-Path $W11_Wallpaper) { $W11_Wallpaper }
    else { return }
    
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallPaper -Value $wallpaperToApply
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value "10"  # Fill
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value "0"     # No Tile
    Start-Process -FilePath rundll32.exe -ArgumentList 'user32.dll,UpdatePerUserSystemParameters' -NoNewWindow -Wait
} "Applying default wallpaper"

# Shortcut management
Write-LoggedOperation {
    Remove-Item "$env:USERPROFILE\Desktop\Microsoft Edge.lnk" -Force -ErrorAction SilentlyContinue
} "Removing Microsoft Edge shortcut from Desktop"

Write-LoggedOperation {
    $ncpa = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:USERPROFILE\Desktop\Network Connections.lnk")
    $ncpa.TargetPath       = "$env:windir\explorer.exe"
    $ncpa.Arguments        = "shell:::{992CFFA0-F557-101A-88EC-00DD010CCC48}"
    $ncpa.WorkingDirectory = "$env:windir"
    $ncpa.IconLocation     = "$env:SystemRoot\System32\netshell.dll"
    $ncpa.Save()
} "Creating 'Network Connections' shortcut on Desktop"

# Startup apps
Write-LoggedOperation {
    reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v SecurityHealth /f
    
    Write-Host "→ Removing Edge autolaunch startup"
    $runKey = "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    Get-ItemProperty -Path "Registry::$runKey" | 
        Get-Member -MemberType NoteProperty |
        Where-Object { $_.Name -like "MicrosoftEdgeAutoLaunch_*" } |
        ForEach-Object { Remove-ItemProperty -Path "Registry::$runKey" -Name $_.Name -Force }
} "Setting up user preferences"

# Tools
Write-LoggedOperation {
    curl.exe -L -s https://live.sysinternals.com/Autologon.exe -o "$env:USERPROFILE\Desktop\Autologon.exe"
} "Downloading Sysinternals Autologon to Desktop"

# Windows activation
Write-LoggedOperation {
    Write-Host "[DETAIL] Downloading and running TSForge activation script..."
    $tsPath = "$env:TEMP\TSforge_Activation.cmd"
    curl.exe -L -s https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/Separate-Files-Version/Activators/TSforge_Activation.cmd -o $tsPath
    & $tsPath /Z-Windows
    Remove-Item $tsPath -Force -ErrorAction SilentlyContinue
} "Running TSForge activation"

Write-Host "→ Restarting Explorer to apply changes"
taskkill /f /im explorer.exe | Out-Null
Start-Process explorer.exe

$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
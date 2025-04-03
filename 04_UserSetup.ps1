# === LOGGING ===
Start-Transcript -Path "$env:TEMP\04_UserSetup.log" -Append -Force
$start = Get-Date

<#
.TITLE
    Script 04 – Unattended Desktop Customization & Activation

.SYNOPSIS
    Configures keyboard layout, sets default wallpaper, removes clutter,
    adds helpful shortcuts, and activates Windows automatically.

.DESCRIPTION
    - Applies a preferred keyboard layout (customizable)
    - Sets default wallpaper from Windows stock backgrounds
    - Removes Microsoft Edge shortcut
    - Adds shortcuts for Network Connections and Sysinternals Autologon
    - Activates Windows using TSForge (via MAS scripts)

.NOTES
    ✅ Internet required for TSForge activation and Autologon download
    📁 Logs actions to $env:TEMP\04_UserSetup.log
    🛠️ Use `Get-WinUserLanguageList` to discover language/input codes

.LINK
    https://learn.microsoft.com/en-us/sysinternals/downloads/autologon
    https://github.com/massgravel/Microsoft-Activation-Scripts
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

# === KEYBOARD LAYOUT ===
Try-Run {
    # To customize: Run Get-WinUserLanguageList to view input/language codes
    # Replace 'en-CA' and '1009:00011009' with your own layout if desired
    $langList = New-WinUserLanguageList "en-CA"
    $langList[0].InputMethodTips.Clear()
    $langList[0].InputMethodTips.Add("1009:00011009")  # Canadian Multilingual Standard
    Set-WinUserLanguageList $langList -Force
} "Setting keyboard layout to English (Canada) - Canadian Multilingual"

# === WALLPAPER ===
$W10_Wallpaper = "C:\Windows\Web\Wallpaper\Theme1\img4.jpg"
$W11_Wallpaper = "C:\Windows\Web\Wallpaper\ThemeA\img20.jpg"

Try-Run {
    $wallpaperToApply = if (Test-Path $W10_Wallpaper) {
        Write-Host "[INFO] Using Windows 10 wallpaper."
        $W10_Wallpaper
    } elseif (Test-Path $W11_Wallpaper) {
        Write-Host "[INFO] Using Windows 11 fallback wallpaper."
        $W11_Wallpaper
    } else {
        Write-Warning "No suitable wallpaper found."
        return
    }

    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallPaper -Value $wallpaperToApply
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value "10"  # Fill
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value "0"     # No Tile
    Start-Process -FilePath rundll32.exe -ArgumentList 'user32.dll,UpdatePerUserSystemParameters' -NoNewWindow -Wait
} "Applying default wallpaper"

# === REMOVE MICROSOFT EDGE SHORTCUT ===
Try-Run {
    Remove-Item "$env:USERPROFILE\Desktop\Microsoft Edge.lnk" -Force -ErrorAction SilentlyContinue
} "Removing Microsoft Edge shortcut from Desktop"

# === STARTUP APPS ===
Try-Run {
	Write-Host "→ Removing SecurityHealth Notification startup"
	reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v SecurityHealth /f
	
	Write-Host "→ Removing Edge autolaunch startup"
	$runKey = "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
	Get-ItemProperty -Path "Registry::$runKey" | 
		Get-Member -MemberType NoteProperty |
		Where-Object { $_.Name -like "MicrosoftEdgeAutoLaunch_*" } |
		ForEach-Object {
			$name = $_.Name
			Write-Host "Removing Edge auto-start entry: $name"
			Remove-ItemProperty -Path "Registry::$runKey" -Name $name -Force
		} 

# === NETWORK CONNECTIONS SHORTCUT ===
Try-Run {
    $ncpa = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:USERPROFILE\Desktop\Network Connections.lnk")
    $ncpa.TargetPath       = "$env:windir\explorer.exe"
    $ncpa.Arguments        = "shell:::{992CFFA0-F557-101A-88EC-00DD010CCC48}"
    $ncpa.WorkingDirectory = "$env:windir"
    $ncpa.IconLocation     = "$env:SystemRoot\System32\netshell.dll"
    $ncpa.Save()
} "Creating 'Network Connections' shortcut on Desktop"

# === AUTOLOGON TOOL ===
Try-Run {
    curl.exe -L -s https://live.sysinternals.com/Autologon.exe -o "$env:USERPROFILE\Desktop\Autologon.exe"
} "Downloading Sysinternals Autologon to Desktop"

# === ACTIVATE WINDOWS VIA TSFORGE ===
Try-Run {
    Write-Host "[DETAIL] Downloading and running TSForge activation script..."
    $tsPath = "$env:TEMP\TSforge_Activation.cmd"
    curl.exe -L -s https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/Separate-Files-Version/Activators/TSforge_Activation.cmd -o $tsPath
    & $tsPath /Z-Windows
    Remove-Item $tsPath -Force -ErrorAction SilentlyContinue
} "Running TSForge activation"

# === RESTART EXPLORER TO APPLY CHANGES ===
Write-Host "→ Restarting Explorer to apply changes"
taskkill /f /im explorer.exe | Out-Null
Start-Process explorer.exe

# === WRAP UP ===
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
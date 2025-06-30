# Windows Debloat - Winget Application Installation Script
# Installs Winget if not present and installs a set of applications

# Logging
$logDir = Join-Path $env:TEMP "WinDebloatLogs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $logDir "03_Winget_Apps_$timestamp.log") -Append -Force
$start = Get-Date

function Write-LoggedOperation {
    param (
        [scriptblock]$Block,
        [string]$Description
    )
    Write-Host "`n[INFO] $Description"
    try { & $Block; Write-Host "[SUCCESS] $Description completed" } 
    catch { Write-Host "[ERROR] $Description failed: $($_.Exception.Message)" }
}

# Configuration
$RemoveShortcuts = $true
$appList = @(
    "Spotify.Spotify"
    "Zen-Team.Zen-Browser"
    "Microsoft.WindowsTerminal"
    "voidtools.Everything"
)
$shortcutFragments = $appList | ForEach-Object { ($_ -split '\.')[1] } | Where-Object { $_ }

function Remove-Shortcut {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$NameFragments
    )

    $shortcutPaths = @(
        "$env:USERPROFILE\Desktop",
        "C:\Users\Public\Desktop"
    )

    foreach ($path in $shortcutPaths) {
        foreach ($fragment in $NameFragments) {
            Get-ChildItem -Path $path -Filter *.lnk -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match [regex]::Escape($fragment) } |
                ForEach-Object {
                    Write-Host "`n[INFO] Found shortcut matching '$fragment': $($_.FullName)"
                    Write-LoggedOperation {
                        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                    } "Removing shortcut: $($_.Name)"
                }
        }
    }
}

# Path setup
$VCLibs       = "$env:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx"
$UIXaml       = "$env:TEMP\Microsoft.UI.Xaml.2.8.x64.appx"
$winget       = "$env:TEMP\winget.msixbundle"

$VCLibsUrl    = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
$UIXamlUrl    = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"
$wingetUrl    = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"

# Dependencies
Write-LoggedOperation {
    & curl.exe -L -o $VCLibs $VCLibsUrl
    Add-AppxPackage -Path $VCLibs
} "Installing Microsoft.VCLibs (UWP C++ runtime)"

Write-LoggedOperation {
    & curl.exe -L -o $UIXaml $UIXamlUrl
    Add-AppxPackage -Path $UIXaml
} "Installing Microsoft.UI.Xaml (UI framework)"

# Winget installation
Write-LoggedOperation {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $bundle = (Invoke-RestMethod $wingetUrl).assets | Where-Object { $_.name -like "*.msixbundle" } | Select-Object -First 1
    & curl.exe -L -J -o $winget $bundle.browser_download_url
    if (-Not (Test-Path $winget)) { throw "Download failed: $winget was not created." }
    Add-AppxPackage -Path $winget
} "Installing winget (Windows Package Manager)"

# Winget verification
Set-Variable -Name wingetAvailable -Value $false -Scope Script
Write-LoggedOperation {
    winget --version | Out-Null
    $script:wingetAvailable = $true
} "Verifying winget is available"

# Application installation
if ($wingetAvailable) {
    Write-LoggedOperation {
        Remove-Item -LiteralPath $winget -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $UIXaml -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $VCLibs -Force -ErrorAction SilentlyContinue
    } "Cleaning up temporary files"

    # Install applications
    foreach ($app in $appList) {
        Write-LoggedOperation {
            winget install --id=$app -e --accept-source-agreements --accept-package-agreements
        } "Installing $app"
    }

    # Optional shortcut cleanup
    if ($RemoveShortcuts) {
        Write-LoggedOperation {
            Remove-Shortcut -NameFragments $shortcutFragments
        } "Removing desktop shortcuts for installed apps"
    }
} else {
    Write-Host "`n[WARNING] winget is not available. Skipping app installations and cleanup."
}

# Wrapup
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
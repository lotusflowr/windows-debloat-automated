# === LOGGING ===
Start-Transcript -Path "$env:TEMP\03_Winget_Apps.log" -Append -Force
$start = Get-Date

<#
.TITLE
    Script 03 – Install Applications via Winget

.SYNOPSIS
    Installs Winget if not present, ensures required dependencies, and installs a set of applications.
    Optionally removes desktop shortcuts created by those apps.

.DESCRIPTION
    - Downloads and installs Microsoft.VCLibs and Microsoft.UI.Xaml if not already installed.
    - Automatically fetches the latest version of winget from GitHub.
    - Installs all listed apps via winget using their IDs.
    - Optionally deletes desktop shortcuts to keep a clean environment.

.NOTES
    ✅ Internet connection required
    🧪 Customize `$appList` for your software stack
    📁 Logs actions to $env:TEMP\03_Winget_Apps.log

.LINK
    https://learn.microsoft.com/en-us/windows/package-manager/
    https://winget.run/
    https://winstall.app
    https://winget.ragerworks.com
#>

# === CONFIGURATION ===

# Remove .lnk shortcuts after installing?
$RemoveShortcuts = $true

# Applications to install via winget (use IDs)
$appList = @(
    "Notepad++.Notepad++"
    "Mozilla.Firefox"
    "Microsoft.WindowsTerminal"
    "voidtools.Everything"
)

# Extract fragment of names for shortcut detection
$shortcutFragments = $appList | ForEach-Object { ($_ -split '\.')[1] } | Where-Object { $_ }

# === FUNCTIONS ===

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
                    Try-Run {
                        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                    } "Removing shortcut: $($_.Name)"
                }
        }
    }
}

# === INSTALLER PATHS & URLs ===

$VCLibs       = "$env:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx"
$UIXaml       = "$env:TEMP\Microsoft.UI.Xaml.2.8.x64.appx"
$winget       = "$env:TEMP\winget.msixbundle"

$VCLibsUrl    = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
$UIXamlUrl    = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"
$wingetUrl    = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"

# === INSTALL DEPENDENCIES ===

Try-Run {
    & curl.exe -L -o $VCLibs $VCLibsUrl
    Add-AppxPackage -Path $VCLibs
} "Installing Microsoft.VCLibs (UWP C++ runtime)"

Try-Run {
    & curl.exe -L -o $UIXaml $UIXamlUrl
    Add-AppxPackage -Path $UIXaml
} "Installing Microsoft.UI.Xaml (UI framework)"

# === INSTALL WINGET ===

Try-Run {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $bundle = (Invoke-RestMethod $wingetUrl).assets | Where-Object { $_.name -like "*.msixbundle" } | Select-Object -First 1
    & curl.exe -L -J -o $winget $bundle.browser_download_url

    if (-Not (Test-Path $winget)) {
        throw "Download failed: $winget was not created."
    }

    Add-AppxPackage -Path $winget
} "Installing winget (Windows Package Manager)"

# === VERIFY WINGET ===

Set-Variable -Name wingetAvailable -Value $false -Scope Script
Try-Run {
    winget --version | Out-Null
    $script:wingetAvailable = $true
} "Verifying winget is available"

if ($wingetAvailable) {

    # === CLEANUP TEMP FILES ===
    Try-Run {
        Remove-Item -LiteralPath $winget -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $UIXaml -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $VCLibs -Force -ErrorAction SilentlyContinue
    } "Cleaning up temporary installer files"

    # === INSTALL APPLICATIONS ===
    foreach ($app in $appList) {
        Try-Run {
            winget install --id=$app -e --accept-source-agreements --accept-package-agreements
        } "Installing $app"
    }

    # === OPTIONAL SHORTCUT CLEANUP ===
    if ($RemoveShortcuts) {
        Try-Run {
            Remove-Shortcut -NameFragments $shortcutFragments
        } "Removing desktop shortcuts for installed apps"
    }

} else {
    Write-Host "`n[WARNING] winget is not available. Skipping app installations and cleanup."
}

# === WRAP UP ===
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript

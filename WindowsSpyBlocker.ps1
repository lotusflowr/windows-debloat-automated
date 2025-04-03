# === LOGGING ===
Start-Transcript -Path "$env:TEMP\06_WindowsSpyBlocker.log" -Append -Force
$start = Get-Date

<#
.TITLE
    Script 06 – WindowsSpyBlocker Firewall Automation

.SYNOPSIS
    Silently installs and runs the latest WindowsSpyBlocker to apply telemetry blocking rules, then cleans up.

.DESCRIPTION
    - Downloads the latest WindowsSpyBlocker executable from GitHub
    - Automatically runs the tool with input to apply "spy" firewall rules
    - Streams output live to console and log to avoid missing buffered output
    - Cleans up all leftover files except the transcript log

.NOTES
    ✅ Internet required for downloading executable
    🧼 Only firewall rules remain after cleanup
    📁 Logs saved to $env:TEMP\06_WindowsSpyBlocker.log

.LINK
    https://github.com/crazy-max/WindowsSpyBlocker
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

# Download WindowsSpyBlocker
Try-Run {
    $release = Invoke-RestMethod "https://api.github.com/repos/crazy-max/WindowsSpyBlocker/releases/latest" -Headers @{ "User-Agent" = "PS" }
    $exeUrl = ($release.assets | Where-Object name -like "*.exe").browser_download_url
    Invoke-WebRequest -Uri $exeUrl -OutFile "$env:TEMP\WindowsSpyBlocker.exe"
} "Downloading WindowsSpyBlocker.exe"

# Run WindowsSpyBlocker
Try-Run {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "$env:TEMP\WindowsSpyBlocker.exe"
    $psi.RedirectStandardInput  = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    $null = $proc.Start()

    $stdin  = $proc.StandardInput
    $stdout = $proc.StandardOutput
    $stderr = $proc.StandardError

    $stdin.WriteLine("1")
    Start-Sleep -Milliseconds 300
    $stdin.WriteLine("1")
    Start-Sleep -Milliseconds 300
    $stdin.WriteLine("1")
    Start-Sleep -Milliseconds 300
    $stdin.WriteLine("exit")
    $stdin.Close()

    while (-not $proc.HasExited) {
        while (!$stdout.EndOfStream) {
            $line = $stdout.ReadLine()
            if ($line) { Write-Host $line }
        }
        Start-Sleep -Milliseconds 100
    }

    while (!$stdout.EndOfStream) {
        $line = $stdout.ReadLine()
        if ($line) { Write-Host $line }
    }

    $errors = $stderr.ReadToEnd()
    if ($errors) {
        Write-Host "`n=== STDERR ===`n$errors"
    }
} "Running WindowsSpyBlocker silently"

# Cleanup
Try-Run {
    $pathsToDelete = @(
        "$env:TEMP\libs",
        "$env:TEMP\logs",
        "$env:TEMP\tmp",
        "$env:TEMP\app.conf",
        "$env:TEMP\WindowsSpyBlocker.exe"
    )
    foreach ($path in $pathsToDelete) {
        if (Test-Path $path) {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
} "Cleaning up WindowsSpyBlocker files"


# === WRAP UP ===
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript

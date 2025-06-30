# Windows Debloat - WindowsSpyBlocker Automation Script
# Silently installs and runs the latest WindowsSpyBlocker to apply telemetry blocking rules

# Logging
$logDir = Join-Path $env:TEMP "WinDebloatLogs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $logDir "06_WindowsSpyBlocker_$timestamp.log") -Append -Force
$start = Get-Date

function Write-LoggedOperation {
    param ([scriptblock]$Block, [string]$Description)
    Write-Host "`n[INFO] $Description"
    try { & $Block; Write-Host "[SUCCESS] $Description completed" } 
    catch { Write-Host "[ERROR] $Description failed: $($_.Exception.Message)" }
}

# Download
Write-LoggedOperation {
    $release = Invoke-RestMethod "https://api.github.com/repos/crazy-max/WindowsSpyBlocker/releases/latest" -Headers @{ "User-Agent" = "PS" }
    $exeUrl = ($release.assets | Where-Object name -like "*.exe").browser_download_url
    Invoke-WebRequest -Uri $exeUrl -OutFile "$env:TEMP\WindowsSpyBlocker.exe"
} "Downloading WindowsSpyBlocker.exe"

# Execution
Write-LoggedOperation {
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
    if ($errors) { Write-Host "`n=== STDERR ===`n$errors" }
} "Running WindowsSpyBlocker silently"

# Cleanup
Write-LoggedOperation {
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

# Wrapup
$runtime = (Get-Date) - $start
Write-Host "`nCompleted in $([math]::Round($runtime.TotalSeconds, 2)) seconds."
Stop-Transcript
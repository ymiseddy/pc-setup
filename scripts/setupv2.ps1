# setup-pc.ps1
# Basic Windows 11 PC/Laptop setup
# Run as Administrator

#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$LogRoot = "C:\ProgramData\PCSetup"
$LogPath = Join-Path $LogRoot ("setup-{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
$script:TranscriptStarted = $false

function Write-Step {
    param([Parameter(Mandatory)] [string] $Message)

    Write-Host ""
    Write-Host "============================================================"
    Write-Host $Message
    Write-Host "============================================================"
}

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory)] [string] $Command,
        [Parameter(Mandatory)] [string[]] $Arguments,
        [Parameter(Mandatory)] [string] $Description,
        [int[]] $SuccessExitCodes = @(0)
    )

    Write-Step $Description
    Write-Host "Running: $Command $($Arguments -join ' ')"

    $output = & $Command @Arguments 2>&1
    $exitCode = $LASTEXITCODE

    if ($output) {
        $output | ForEach-Object { Write-Host $_ }
    }

    if ($SuccessExitCodes -notcontains $exitCode) {
        throw "FAILED: $Description. Command '$Command $($Arguments -join ' ')' exited with code $exitCode."
    }

    return $output
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

try {
    if (-not (Test-IsAdministrator)) {
        throw "This script must be run from an elevated PowerShell window. Right-click PowerShell and choose 'Run as administrator'."
    }

    if (-not (Test-Path $LogRoot)) {
        New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null
    }

    Start-Transcript -Path $LogPath -Force | Out-Null
    $script:TranscriptStarted = $true

    Write-Step "Starting Windows 11 setup"
    Write-Host "Log file: $LogPath"

    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if (-not $winget) {
        throw "winget.exe was not found. Install or update 'App Installer' from the Microsoft Store, then rerun this script."
    }

    Invoke-CheckedCommand `
        -Command "winget.exe" `
        -Arguments @("--version") `
        -Description "Checking winget availability"

    Invoke-CheckedCommand `
        -Command "winget.exe" `
        -Arguments @("source", "update") `
        -Description "Updating winget package sources"

    Invoke-CheckedCommand `
        -Command "winget.exe" `
        -Arguments @(
            "search",
            "Microsoft.PowerShell",
            "--source", "winget",
            "--accept-source-agreements"
        ) `
        -Description "Searching for Microsoft PowerShell package"

    Invoke-CheckedCommand `
        -Command "winget.exe" `
        -Arguments @(
            "install",
            "-e",
            "--id", "Microsoft.PowerShell",
            "--source", "winget",
            "--accept-package-agreements",
            "--accept-source-agreements"
        ) `
        -Description "Installing Microsoft PowerShell"

    Invoke-CheckedCommand `
        -Command "winget.exe" `
        -Arguments @(
            "upgrade",
            "--all",
            "--source", "winget",
            "--accept-package-agreements",
            "--accept-source-agreements"
        ) `
        -Description "Upgrading all winget packages"

    Invoke-CheckedCommand `
        -Command "sfc.exe" `
        -Arguments @("/scannow") `
        -Description "Running System File Checker"

    $dismScanOutput = Invoke-CheckedCommand `
        -Command "dism.exe" `
        -Arguments @("/online", "/cleanup-image", "/scanhealth") `
        -Description "Running DISM ScanHealth"

    $dismScanText = ($dismScanOutput | Out-String)

    $dismShowsRepairNeeded =
        $dismScanText -match "component store is repairable" -or
        $dismScanText -match "corruption.*detected" -or
        $dismScanText -match "repairable"

    $dismShowsHealthy =
        $dismScanText -match "No component store corruption detected"

    if ($dismShowsRepairNeeded -and -not $dismShowsHealthy) {
        Invoke-CheckedCommand `
            -Command "dism.exe" `
            -Arguments @("/online", "/cleanup-image", "/restorehealth") `
            -Description "DISM found issues; running RestoreHealth"
    }
    else {
        Write-Step "DISM RestoreHealth skipped"
        Write-Host "DISM ScanHealth did not report repairable component store corruption."
    }

    $packages = @(
        @{
            Name = "Adobe Acrobat Reader"
            Id   = "Adobe.Acrobat.Reader.64-bit"
        },
        @{
            Name = "Microsoft Office"
            Id   = "Microsoft.Office"
        },
        @{
            Name = "Google Chrome"
            Id   = "Google.Chrome"
        },
        @{
            Name = "Dropbox"
            Id   = "Dropbox.Dropbox"
        }
    )

    foreach ($package in $packages) {
        Invoke-CheckedCommand `
            -Command "winget.exe" `
            -Arguments @(
                "install",
                "-e",
                "--id", $package.Id,
                "--source", "winget",
                "--accept-package-agreements",
                "--accept-source-agreements"
            ) `
            -Description "Installing $($package.Name)"
    }

    Write-Step "Setup completed successfully"
    Write-Host "Log file: $LogPath"

    Stop-Transcript | Out-Null
    $script:TranscriptStarted = $false

    exit 0
}
catch {
    Write-Host ""
    Write-Host "SETUP FAILED" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Log file: $LogPath"

    if ($script:TranscriptStarted) {
        Stop-Transcript | Out-Null
    }

    exit 1
}

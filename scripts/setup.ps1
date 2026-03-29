# PowerShell Setup Script

This script automates the setup of a Windows PC environment using PowerShell.

## Steps:
1. Install/Update PowerShell via winget
2. Upgrade all packages using winget
3. Run `sfc /scannow`
4. Run `DISM /Online /Cleanup-Image /ScanHealth`
5. Optionally restore health if issues are found using `DISM /Online /Cleanup-Image /RestoreHealth`
6. Install common applications:
   - Adobe Acrobat Reader
   - Microsoft Office
   - Google Chrome
   - Dropbox
7. Optionally export BitLocker recovery key to Desktop
8. Optionally create a local user and add to Administrators

## Requirements
- Elevated permissions are required to run this script.

## Logging
- The output of each command will be logged for review.

## Sample Script:
```powershell
# Require elevated permissions
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WellKnownSidType]::Administrator)) {
    Write-Host "Please run as Administrator."
    exit 1
}

$logFile = "setup_log.txt"
function Log-Message {
    param ([string]$message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -Path $logFile -Value "$timestamp - $message"
}

# Install/update PowerShell
Log-Message "Installing/Updating PowerShell..."
winget install --id Microsoft.Powershell --source winget --accept-source-agreements --accept-package-agreements || exit 1

# Upgrade all packages
Log-Message "Upgrading all packages..."
winget upgrade --all || exit 1

# Run sfc/scannow
Log-Message "Running sfc /scannow..."
sfc /scannow || exit 1

# Run DISM scanhealth
Log-Message "Running DISM scanhealth..."
DISM /Online /Cleanup-Image /ScanHealth || exit 1

# Optionally run DISM restorehealth
$DismResult = DISM /Online /Cleanup-Image /ScanHealth
if ($DismResult -like '*error*') {
    Log-Message "DISM found issues. Restoring health..."
    DISM /Online /Cleanup-Image /RestoreHealth || exit 1
}

# Install common applications
$apps = @(
    'Adobe.Acrobat.Reader',
    'Microsoft.Office',
    'Google.Chrome',
    'Dropbox'
)
foreach ($app in $apps) {
    Log-Message "Installing $app..."
    winget install --id $app --source winget --accept-source-agreements --accept-package-agreements || exit 1
}

# Optionally export BitLocker recovery key
# Uncomment to export. Requires admin.
# manage-bde -protectors -get C: | findstr /C:"Numerical password" > $HOME\Desktop\BitLockerKey.txt

# Optionally create a local user and add to Administrators
# Uncomment and set your desired username.
# $userName = 'YourUsername'
# net user $userName Password123 /add
# net localgroup Administrators $userName /add
```

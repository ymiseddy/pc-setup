# Setup for PC/Laptop Win 11

## Powershell setup

```powershell
winget search Microsoft.PowerShell
```

```
winget install –id Microsoft.PowerShell --source winget
```

```
winget upgrade –all
```

```powershell
sfc /scannow
```

## DISM 

Scan health

```powershell
dism /online /cleanup-image /scanhealth
```

Restore health (if scan shows issues)

```powershell
dism /online /cleanup-image /restorehealth
```

## Acrobat Reader

```powershell
winget install -e --id Adobe.Acrobat.Reader.64-bit
```

## Office

```powershell
winget install --id Microsoft.Office -e
```

## Chrome

```powershell
winget install -e --id Google.Chrome
```

## Dropbox

```
winget install -e --id Dropbox.Dropbox
```

## BitLocker Recovery Key Backup Guide

It is highly recommended to store your BitLocker recovery key in multiple
locations separate from your computer.

### Method 1: Control Panel (Windows 10 & 11)
1. Open the **Control Panel** and navigate to **System and Security** >
   **BitLocker Drive Encryption**.
2. Find the encrypted drive and click **Back up your recovery key**.
3. Choose a backup option:
    * **Save to your Microsoft account**: Uploads the key to your [Microsoft Recovery Key Cloud](https://account.microsoft.com).
    * **Save to a USB flash drive**: Saves the key as a `.txt` file on an external drive.
    * **Save to a file**: Saves the key to a local or network location (cannot be the encrypted drive itself).
    * **Print the recovery key**: Creates a physical hard copy.

### Method 2: Windows 11 Settings
1. Go to **Settings** > **System** > **Storage**.
2. Select **Advanced storage settings** > **Disks & volumes**.
3. Select your drive, click **Properties**, and then click **Turn off BitLocker** (this opens the management window).
4. Select **Back up your recovery key** and follow the prompts.

### Method 3: Command Prompt (Admin)
To retrieve the 48-digit key via Command Prompt:
1. Open **Command Prompt** as an Administrator.
2. Run the following command (replace `C:` with your drive letter):
   ```cmd
   manage-bde -protectors -get C:


### Powershell commands

I haven't verified these yet, do it the hard way, then diff to verify this works:

```powershell
(Get-BitLockerVolume -MountPoint "C:").KeyProtector | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"}
```

```powershell
(Get-BitLockerVolume -MountPoint C).KeyProtector > $env:UserProfile\Desktop\BitLocker_Recovery_Key.txt
```

## Adding Local Account

```powershell
$Username = "TestUser"
```

```
$Fullname = "Test User"
```

```powershell
$Password = Read-Host -AsSecureString -Prompt "Enter password"
```

```powershell
New-LocalUser -Name $Usernamme -Password $Password -FullName $Fullname -Description "A standard local user account"
```

```powershell
Add-LocalGroupMember -Group "Administrators" -Member $Username
```


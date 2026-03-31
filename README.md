# Setup for PC/Laptop Win 11

## Powershell setup

```powershell
winget search Microsoft.PowerShell
```

```
winget install -–id Microsoft.PowerShell --source winget
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
winget install -e --id Adobe.Acrobat.Reader.64-bit --source winget
```

## Office

```powershell
winget install --id Microsoft.Office -e --source winget --source winget
```

## Chrome

```powershell
winget install -e --id Google.Chrome --source winget
```

## Dropbox

```
winget install -e --id Dropbox.Dropbox --source winget
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

## Useful commands

### Backup user files

```powershell
robocopy .\Users\ D:\Backup\Users /E /Copyall /A-:SH /XJ /ZB /R:2 /W:5 /XF NTUSER.DAT*
```

Here is the breakdown of that Robocopy command:

* `.\Users\`: The Source directory (current folder's Users).
* `D:\Backup\Users`: The Destination directory.
* `/E`: Copies Subdirectories, including empty ones.
* `/Copyall`: Copies all file information (Data, Attributes, Timestamps, NTFS
  ACLs/Permissions, Owner, and Auditing info). Equivalent to `/COPY:DATSOU`.
* `/A-:SH`: Removes the System (S) and Hidden (H) attributes from the files in
  the destination.
* `/XJ`: Excludes Junction points (symbolic links for folders). This prevents
  the command from getting stuck in infinite loops (like the "Application Data"
  loop).
* `/ZB`: Uses Restartable mode; if access is denied, it switches to Backup mode
  (useful for bypassing permission issues on system files).
* `/R:2`: Sets the number of Retries on failed copies to 2 (the default is 1 million).
* `/W:5`: Sets the Wait time between retries to 5 seconds.
* `/XF NTUSER.DAT*`: Excludes Files matching that name (typically registry
  hives that are locked while a user is logged in).  

### Downloading the setup script

To download the PowerShell setup script, use the following command:

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/ymiseddy/pc-setup/main/scripts/setup.ps1 -OutFile setup.ps1
```

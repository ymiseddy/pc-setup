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

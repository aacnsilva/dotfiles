# Run as Administrator!

function Install-App
{
  param (
    [string]$AppId,
    [string]$AppName
  )
  Write-Host "Installing $AppName..."
  winget install --id "$AppId" --source winget --accept-package-agreements --accept-source-agreements -e
  if ($?)
  {
    Write-Host "$AppName installed successfully.`n"
  } else
  {
    Write-Host "Failed to install $AppName.`n"
  }
}

# -------------------------------
# Chocolatey (for glazeWM)
# -------------------------------
if (-not (Get-Command choco -ErrorAction SilentlyContinue))
{
  Write-Host "Installing Chocolatey..."
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

Write-Host "Installing Visual C++ Redistributables (2005–2022)..."
choco install vcredist-all -y

# -------------------------------
# App Installs
# -------------------------------
choco install glazewm -y
choco install zebar -y
Install-App -AppId "Brave.Brave" -AppName "Brave Browser"
Install-App -AppId "Ubisoft.Connect" -AppName "Ubisoft Connect"
Install-App -AppId "Valve.Steam" -AppName "Steam"
Install-App -AppId "Discord.Discord" -AppName "Discord"
Install-App -AppId "Blizzard.BattleNet" -AppName "Battle.net"


Write-Host "Adding glazeWM to startup..."

$glazePath = "$Env:ProgramFiles\glazeWM\glazewm.exe"  # default choco install path
$startupFolder = "$Env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$shortcutPath = "$startupFolder\glazeWM.lnk"

$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $glazePath
$shortcut.WorkingDirectory = Split-Path $glazePath
$shortcut.WindowStyle = 1
$shortcut.Save()

Write-Host "glazeWM will now auto-start with Windows."
# -------------------------------
# Windows Tweaks
# -------------------------------

Write-Host "Applying system tweaks..."

# Show file extensions
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

# Disable Cortana
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f

# Disable Game DVR and Xbox Game Bar
REG ADD "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
REG ADD "HKCU\SOFTWARE\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d 0 /f
REG ADD "HKCU\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 0 /f

# Enable Ultimate Performance Power Plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61

# Disable background apps (modern UWP apps)
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f

# Disable OneDrive auto start
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /t REG_SZ /d "" /f

Write-Host "Windows and registry tweaks applied!"

# -------------------------------
# Dark Mode + UI Tweaks
# -------------------------------

Write-Host "Enabling dark mode and disabling animations..."

# Enable dark mode for apps and system UI
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0

# Disable UI animations
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) # Animation toggle
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0

# Enable taskbar auto-hide
$TaskbarSettings = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
$bytes = $TaskbarSettings.Settings
$bytes[8] = $bytes[8] -bor 0x02  # Set auto-hide flag
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" -Name "Settings" -Value $bytes
Stop-Process -f -ProcessName explorer  # Restart Explorer to apply

Write-Host "Dark mode, animations, and taskbar settings applied.`n"

# -------------------------------
# Wi-Fi Network Optimizations
# -------------------------------

Write-Host "Applying network tweaks for lower latency..."

# Disable Nagle's Algorithm (reduces latency in TCP)
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -Force | Out-Null
Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" | ForEach-Object {
  Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
  Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force
}

# Disable Network Throttling Index
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -PropertyType DWord -Force

# Disable Power Saving on Wi-Fi adapter
$netAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -match 'Wi-Fi' }
foreach ($adapter in $netAdapters)
{
  Write-Host "Disabling power saving on $($adapter.Name)..."
  powercfg /setacvalueindex SCHEME_CURRENT SUB_MISC POWER_SAVING_MODE 000
  powercfg /setdcvalueindex SCHEME_CURRENT SUB_MISC POWER_SAVING_MODE 000
}

Write-Host "Network tweaks for Wi-Fi gaming applied."

# -------------------------------
# Done
# -------------------------------
Write-Host "`nSetup complete! Reboot to finalize everything."

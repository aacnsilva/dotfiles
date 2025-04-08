# Run as Administrator!

function Install-App
{
  param (
    [string]$AppId,
    [string]$AppName
  )
  Write-Host "🔧 Installing $AppName..."
  winget install --id "$AppId" --source winget --accept-package-agreements --accept-source-agreements -e
  if ($?)
  {
    Write-Host "✅ $AppName installed successfully.`n"
  } else
  {
    Write-Host "❌ Failed to install $AppName.`n"
  }
}

# -------------------------------
# 🍫 Chocolatey (for glazeWM)
# -------------------------------
if (-not (Get-Command choco -ErrorAction SilentlyContinue))
{
  Write-Host "🍫 Installing Chocolatey..."
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# -------------------------------
# 🚀 App Installs
# -------------------------------
choco install glazewm -y
Install-App -AppId "Brave.Brave" -AppName "Brave Browser"
Install-App -AppId "Ubisoft.Connect" -AppName "Ubisoft Connect"
Install-App -AppId "Valve.Steam" -AppName "Steam"
Install-App -AppId "Discord.Discord" -AppName "Discord"
Install-App -AppId "Blizzard.BattleNet" -AppName "Battle.net"

# -------------------------------
# ⚙️ Windows Tweaks
# -------------------------------

Write-Host "`n🧠 Applying system tweaks..."

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

Write-Host "✅ Windows and registry tweaks applied!"

# -------------------------------
# 🔚 Done
# -------------------------------
Write-Host "`n🎉 Setup complete! Reboot to finalize everything."

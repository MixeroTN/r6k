$RootPath = Split-Path (Split-Path $PSScriptRoot -Parent)
$var = -join($PSScriptRoot, "/Launch_me.ps1");
$DesktopPath = [Environment]::GetFolderPath("Desktop")

Copy-Item -Path $var -Destination $DesktopPath
Add-Type -AssemblyName System.Windows.Forms

$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
$balmsg.BalloonTipText = 'Launch a Launch_me.ps1 file located on your Desktop'
$balmsg.BalloonTipTitle = "R6Killer by MixeroTN"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(30000)

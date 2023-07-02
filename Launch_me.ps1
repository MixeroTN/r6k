param([switch]$Elevated)

function Check-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Check-Admin) -eq $false)  {

    if ($elevated) {
        exit
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -elevated -windowstyle hidden' -f ($myinvocation.MyCommand.Definition))
    }

    exit
}

$trigger = New-JobTrigger -AtStartup -RandomDelay 00:01:30

Register-ScheduledJob -Trigger $trigger -FilePath $env:APPDATA\npm\node_modules\r6k\R6Killer.ps1 -Name 'R6Killer'
Add-Type -AssemblyName System.Windows.Forms

$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$balmsg.BalloonTipText = 'Done!'
$balmsg.BalloonTipTitle = "R6Killer by MixeroTN"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(30000)

Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force

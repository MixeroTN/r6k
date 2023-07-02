param([switch]$Elevated)

function Check-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Check-Admin) -eq $false)  {
    if ($elevated) {
        exit
    }
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated -windowstyle hidden' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

while ($true) {
    $taskName = "Rainbow Six"
    $taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }

    if ($taskExists) {
        Start-Sleep -Minutes 3

        Add-Type @"

using System;
using System.Runtime.InteropServices;
using System.Text;

public class Win32 {
    public delegate void ThreadDelegate(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool EnumThreadWindows(int dwThreadId, ThreadDelegate lpfn, IntPtr lParam);

    [DllImport("user32.dll", CharSet=CharSet.Auto, SetLastError=true)]
    public static extern int GetWindowText(IntPtr hwnd, StringBuilder lpString, int cch);

    [DllImport("user32.dll", CharSet=CharSet.Auto, SetLastError=true)]
    public static extern Int32 GetWindowTextLength(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool IsIconic(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    public static string GetTitle(IntPtr hWnd) {
        var len = GetWindowTextLength(hWnd);
        StringBuilder title = new StringBuilder(len + 1);
        GetWindowText(hWnd, title, title.Capacity);
        return title.ToString();
    }
}

"@

        $windows = New-Object System.Collections.ArrayList

        Get-Process | Where { $_.MainWindowTitle } | foreach {
            $_.Threads.ForEach({
                [void][Win32]::EnumThreadWindows($_.Id, {
                    param($hwnd, $lparam)
                    if ([Win32]::IsIconic($hwnd) -or [Win32]::IsWindowVisible($hwnd)) {
                        $windows.Add([Win32]::GetTitle($hwnd))
                    }
                }, 0)
            })
        }

        if ($windows -match 'Rainbow Six') {
            Add-Type -AssemblyName System.Windows.Forms
            $global:balmsg = New-Object System.Windows.Forms.NotifyIcon
            $path = (Get-Process -id $pid).Path
            $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
            $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
            $balmsg.BalloonTipText = 'Prepared and ready'
            $balmsg.BalloonTipTitle = "R6Killer by MixeroTN"
            $balmsg.Visible = $true
            $balmsg.ShowBalloonTip(5000)

            while ($true) {
                Start-Sleep -Seconds 30
                $windows = New-Object System.Collections.ArrayList
                Get-Process | Where { $_.MainWindowTitle } | foreach {
                    $_.Threads.ForEach({
                        [void][Win32]::EnumThreadWindows($_.Id, {
                            param($hwnd, $lparam)
                            if ([Win32]::IsIconic($hwnd) -or [Win32]::IsWindowVisible($hwnd)) {
                                $windows.Add([Win32]::GetTitle($hwnd))
                            }
                        }, 0)
                    })
                }

                if (-Not $windows -match 'Rainbow Six') {
                    Start-Sleep -Seconds 10
                    $windows = New-Object System.Collections.ArrayList
                    Get-Process | Where { $_.MainWindowTitle } | foreach {
                        $_.Threads.ForEach({
                            [void][Win32]::EnumThreadWindows($_.Id, {
                                param($hwnd, $lparam)
                                if ([Win32]::IsIconic($hwnd) -or [Win32]::IsWindowVisible($hwnd)) {
                                    $windows.Add([Win32]::GetTitle($hwnd))
                                }
                            }, 0)
                        })
                    }

                    if (Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }) {
                        Get-Process -ProcessName "Rainbow Six" | Stop-Process -Force
                        Add-Type -AssemblyName System.Windows.Forms
                        $global:balmsg = New-Object System.Windows.Forms.NotifyIcon
                        $path = (Get-Process -id $pid).Path
                        $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
                        $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
                        $balmsg.BalloonTipText = 'Rainbow Six Task has been closed'
                        $balmsg.BalloonTipTitle = "R6Killer by MixeroTN"
                        $balmsg.Visible = $true
                        $balmsg.ShowBalloonTip(5000)
                    }
                }
            }
        }
        else {
            Start-Sleep -Minutes 1
        }
    }
}

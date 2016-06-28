Set oShell = WScript.CreateObject("WScript.Shell")
oShell.run "cmd.exe /c powershell Write-Host lalala!"
Set oShell = Nothing
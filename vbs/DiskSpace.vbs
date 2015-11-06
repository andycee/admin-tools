Option Explicit

Dim objSWbemServices
Dim colItems
Dim objItem
Dim objArgs

Set objArgs = Wscript.Arguments
Set objSWbemServices = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & objArgs(0) & "\root\cimv2")
Set colItems = objSWbemServices.ExecQuery ("SELECT * FROM Win32_LogicalDisk")			

For Each objItem In colItems	
	WScript.Echo vbTab & objItem.caption & vbTab & FormatNumber(objItem.freespace/1024/1024/1024,2) & "Gb"
Next

objSWbemServices = null
colItems = null
objItem = null
objArgs = null
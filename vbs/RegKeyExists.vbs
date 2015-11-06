StartTime = Timer()
Const HKEY_LOCAL_MACHINE = &H80000002

strComputer = "."
Set objRegistry = GetObject("winmgmts:\\" & strComputer & "\root\default:StdRegProv")
 
	strKeyPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
	strValueName = "EnableLinkedConnections"
		objRegistry.GetDWORDValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,DWORDValue

		If Not IsNull(DWORDValue) Then
   				KeyExists = 1
			Else
   				
   				KeyExists = 0
		End If

WScript.Echo KeyExists

strComputer = null
objRegistry =null
strKeyPath = null
strValueName = null
DWORDValue = null
KeyExists = null

EndTime = Timer()
Wscript.Echo ("Run time in seconds: " & FormatNumber(EndTime - StartTime, 2))
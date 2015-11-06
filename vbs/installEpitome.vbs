Const ForReading = 1

Set objDictionary = CreateObject("Scripting.Dictionary")
Set objFSO = CreateObject("Scripting.FileSystemObject")
' файл со списком пользователей
Set objTextFile = objFSO.OpenTextFile("\\10.0.14.2\netlogon\Script\users.ini", ForReading)
Set fso = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("Wscript.Shell")


Function InstallEpitome(fldr)
   If (fso.FolderExists(fldr)) Then
      Wscript.Quit
   Else
      objShell.Run "cmd.exe /c mkdir C:\Winprog\ppm\app"
      objShell.Run "cmd.exe /c mkdir C:\Winprog\ppm\bmp"
      objShell.Run "cmd.exe /c xcopy \\10.0.14.3\Winprog\ppm\app\epitome.cmd C:\Winprog\ppm\app"
      objShell.Run "cmd.exe /c xcopy \\10.0.14.3\Winprog\ppm\app\epitome.ini C:\Winprog\ppm\app"
      objShell.Run "cmd.exe /c xcopy \\10.0.14.3\Winprog\ppm\app\ntwdblib.dll C:\Winprog\ppm\app"
      objShell.Run "cmd.exe /c xcopy \\10.0.14.2\shares\Sybase-Install\*.* C:\Windows"
   	'fso.CreateFolder "C:\Winprog\ppm\app"
   	'fso.CopyFolder "\\skaipm01\Winprog\*", fldr, True
   	'fso.CopyFile "\\skaidc01\shares\Sybase-Install\*", "C:\Windows\", True
   End If
End Function

Function RemoveEpitome(fldr)
	If (fso.FolderExists(fldr)) Then
		fso.DeleteFolder(fldr)
	Else
	Wscript.Quit
	End If
End Function


i = 0


Do Until objTextFile.AtEndOfStream
 strNextLine = objTextFile.Readline
 objDictionary.Add strNextLine, i
 i = i + 1
Loop

'For Each objItem in objDictionary
 StrUsername = objDictionary.Item(objItem)
 Set objNetwork = CreateObject("WScript.Network")
 Set objUser = CreateObject("ADSystemInfo")
 Set CurrentUser = GetObject("LDAP://" & objUser.UserName)


 If objDictionary.Exists(objNetwork.UserName) Then
 	call InstallEpitome("C:\Winprog")
 	 	Else
 	call RemoveEpitome("C:\Winprog")
 End If
'Next
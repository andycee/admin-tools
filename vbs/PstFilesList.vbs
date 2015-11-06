strComputer = InputBox("Enter computer name here")
'Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colFiles = objWMIService.ExecQuery("Select * from CIM_DataFile Where Extension = 'pst'")

For Each objFile in colFiles
    Wscript.Echo objFile.Drive & objFile.Path
    Wscript.Echo objFile.FileName & "." & objFile.Extension
    Wscript.Echo objFile.FileSize
    Wscript.Echo
Next
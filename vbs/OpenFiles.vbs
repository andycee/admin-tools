Set objConnection = GetObject("WinNT://skaidc01/LanmanServer")
Set colResources = objConnection.Resources

For Each objResource in colResources
    Wscript.Echo "Path: " & objResource.Path
    Wscript.Echo "User: " & objResource.User
    Wscript.Echo 
Next
Set dtmConvertedDate = CreateObject("WbemScripting.SWbemDateTime")
strComputer = "."
Wscript.Echo strComputer
Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set oss = objWMIService.ExecQuery ("Select * from Win32_OperatingSystem")
set WshShell = CreateObject("Wscript.shell")

For Each os in oss
    'Wscript.Echo "Boot Device: " & os.BootDevice
    'Wscript.Echo "Build Number: " & os.BuildNumber
    BuildNumber = os.BuildNumber
    'Wscript.Echo "Build Type: " & os.BuildType
    'Wscript.Echo "Caption: " & os.Caption
    'Wscript.Echo "Code Set: " & os.CodeSet
    'Wscript.Echo "Country Code: " & os.CountryCode
    'Wscript.Echo "Debug: " & os.Debug
    'Wscript.Echo "Encryption Level: " & os.EncryptionLevel
    'dtmConvertedDate.Value = os.InstallDate
    'dtmInstallDate = dtmConvertedDate.GetVarDate
    'Wscript.Echo "Install Date: " & dtmInstallDate 
    'Wscript.Echo "Licensed Users: " & os.NumberOfLicensedUsers
    'Wscript.Echo "Organization: " & os.Organization
    'Wscript.Echo "OS Language: " & os.OSLanguage
    'Wscript.Echo "OS Product Suite: " & os.OSProductSuite
    'Wscript.Echo "OS Type: " & os.OSType
    'Wscript.Echo "Primary: " & os.Primary
    'Wscript.Echo "Registered User: " & os.RegisteredUser
    'Wscript.Echo "Serial Number: " & os.SerialNumber
    'Wscript.Echo "Version: " & os.Version
Next

If InStr(BuildNumber, "7601") then
    Wscript.Echo BuildNumber
End If

On Error Resume Next

key = WshShell.RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLinkedConnections")
Wscript.Echo key
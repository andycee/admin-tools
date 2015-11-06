####################################################
# Change these values to the appropriate values in your environment

$PrinterIP = "10.0.14.235"
$PrinterPort = "9100"
$PrinterPortName = "IP_" + $PrinterIP
$DriverName = "Kyocera ECOSYS M2030dn KX"
$DriverPath = "\\skaidc01\shares\M2030dnx86"
$DriverInf = "\\skaidc01\shares\M2030dnx86\OEMSETUP.INF"
$PrinterCaption = "Kyocera Sales"
####################################################

### ComputerList Option 1 ###
$ComputerList = @("wkai01011")

### ComputerList Option 2 ###
# $ComputerList = @()
# Import-Csv "C:\Temp\ComputersThatNeedPrinters.csv" | `
# % {$ComputerList += $_.Computer}

Function CreatePrinterPort {
param ($PrinterIP, $PrinterPort, $PrinterPortName, $ComputerName)
$wmi = [wmiclass]"\\$ComputerName\root\cimv2:win32_tcpipPrinterPort"
$wmi.psbase.scope.options.enablePrivileges = $true
$Port = $wmi.createInstance()
$Port.name = $PrinterPortName
$Port.hostAddress = $PrinterIP
$Port.portNumber = $PrinterPort
$Port.SNMPEnabled = $false
$Port.Protocol = 1
$Port.put()
}

Function InstallPrinterDriver {
Param ($DriverName, $DriverPath, $DriverInf, $ComputerName)
$wmi = [wmiclass]"\\$ComputerName\Root\cimv2:Win32_PrinterDriver"
$wmi.psbase.scope.options.enablePrivileges = $true
$wmi.psbase.Scope.Options.Impersonation = [System.Management.ImpersonationLevel]::Impersonate
$Driver = $wmi.CreateInstance()
$Driver.Name = $DriverName
$Driver.DriverPath = $DriverPath
$Driver.InfName = $DriverInf
$wmi.AddPrinterDriver($Driver)
$wmi.Put()
}

Function CreatePrinter {
param ($PrinterCaption, $PrinterPortName, $DriverName, $ComputerName)
$wmi = ([WMIClass]"\\$ComputerName\Root\cimv2:Win32_Printer")
$Printer = $wmi.CreateInstance()
$Printer.Caption = $PrinterCaption
$Printer.DriverName = $DriverName
$Printer.PortName = $PrinterPortName
$Printer.DeviceID = $PrinterCaption
$Printer.Put()
}

foreach ($computer in $ComputerList) {
# Creating port
CreatePrinterPort -PrinterIP $PrinterIP -PrinterPort $PrinterPort -PrinterPortName $PrinterPortName -ComputerName $computer
# Installing printer driver
InstallPrinterDriver -DriverName $DriverName -DriverPath $DriverPath -DriverInf $DriverInf -ComputerName $computer
# Create printer with port and driver
CreatePrinter -PrinterPortName $PrinterPortName -DriverName $DriverName -PrinterCaption $PrinterCaption -ComputerName $computer
}
' PrinterWMI.vbs
' Sample WMI Printer VBScript to interrogate properties
' Author Guy Thomas http://computerperformance.co.uk/
' Version 2.3 - December 2010
' -----------------------------------------------' 
Option Explicit
Dim objWMIService, objItem, colItems, strComputer, intPrinters

strComputer ="."
intPrinters = 1

' --------------------------------------------
' Pure WMI Section
Set objWMIService = GetObject _
("winmgmts:\\" & strComputer & "\root\CIMV2")
Set colItems = objWMIService.ExecQuery _
("SELECT * FROM Win32_Printer")

Call Wait() ' Goto Sub Routine at the end

' On Error Resume Next
For Each objItem In colItems
WScript.Echo objItem.name & ", Printer Number: " & intPrinters & " " & objItem.DriverName & " " & objItem.PortName & " " & objItem.Shared
'& VbCr & "====================================" & VbCr &  "Availability: " & objItem.Availability & VbCr & _
'"Description: " & objItem.Description & VbCr & _ 
'"Printer: " & objItem.DeviceID & VbCr & _ 
'"Driver Name: " & objItem.DriverName & VbCr & _ 
'"Port Name: " & objItem.PortName & VbCr & _ 
'"Printer State: " & objItem.PrinterState & VbCr & _ 
'"Printer Status: " & objItem.PrinterStatus & VbCr & _ 
'"PrintJobDataType: " & objItem.PrintJobDataType & VbCr & _ 
'"Print Processor: " & objItem.PrintProcessor & VbCr & _ 
'"Spool Enabled: " & objItem.SpoolEnabled & VbCr & _ 
'"Separator File: " & objItem.SeparatorFile & VbCr & _ 
'"Queued: " & objItem.Queued & VbCr & _ 
'"Status: " & objItem.Status & VbCr & _ 
'"StatusInfo: " & objItem.StatusInfo & VbCr & _ 
'"Published: " & objItem.Published & VbCr & _ 
'"Shared: " & objItem.Shared & VbCr & _ 
'"ShareName: " & objItem.ShareName & VbCr & _ 
'"Direct: " & objItem.Direct & VbCr & _ 
'"Location: " & objItem.Location & VbCr & _ 
'"Priority: " & objItem.Priority & VbCr & _ 
'"Work Offline: " & objItem.WorkOffline & VbCr & _ 
'"Horizontal Res: " & objItem.HorizontalResolution & VbCr & _
'"Vertical Res: " & objItem.VerticalResolution & VbCr & ""
intPrinters = intPrinters + 1
Next

sub Wait()
If strComputer = "." then
strComputer = "Local Host"
else strComputer = strComputer
end if

WScript.Echo "Wait 2 mins for " & strComputer _
& " to enumerate printers"

End Sub

WScript.Quit

' End of Sample Printer VBScript
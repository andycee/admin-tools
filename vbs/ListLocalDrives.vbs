ComputerName = "wkai0026"
'Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objWMIService  = GetObject("winmgmts:{impersonationLevel=Impersonate}!//" & ComputerName)
' Get physical disk drive
Set wmiDiskDrives =  objWMIService.ExecQuery("SELECT Caption, DeviceID FROM Win32_DiskDrive")
Set myArray = CreateObject("System.Collections.ArrayList")
'strFile = "log.txt"
'Set logFile = objFSO.OpenTextFile(strFile, 8, True)

For Each wmiDiskDrive In wmiDiskDrives
    'Use the disk drive device id to
    ' find associated partition
    query = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & wmiDiskDrive.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition"
    Set wmiDiskPartitions = objWMIService.ExecQuery(query)

    For Each wmiDiskPartition In wmiDiskPartitions
        'Use partition device id to find logical disk
        Set wmiLogicalDisks = objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" _
             & wmiDiskPartition.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition") 

        For Each wmiLogicalDisk In wmiLogicalDisks
            myArray.Add wmiLogicalDisk.DeviceID
        Next      
    Next
Next

For Each itm in myArray
    'logFile.WriteLine itm
    Wscript.Echo itm
Next

Set myArray = Nothing
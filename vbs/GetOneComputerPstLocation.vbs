ComputerName = "."
'Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objWMIService  = GetObject("winmgmts:{impersonationLevel=Impersonate}!//" & ComputerName)

' Get physical disk drive
Set wmiDiskDrives =  objWMIService.ExecQuery("SELECT Caption, DeviceID FROM Win32_DiskDrive")
Set DiskLetters = CreateObject("System.Collections.ArrayList")
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

        For Each wmiLogicalDisk In wmiLogicalDisks ' populating mDiskLetters with logical disk letters with ":"
            DiskLetters.Add wmiLogicalDisk.DeviceID
        Next      
    Next
Next

For Each DiskLetter in DiskLetters
    ' populating colFiles array with information about pst files on "DiskLetter" drive
    Set colFiles = objWMIService.ExecQuery("Select * from CIM_DataFile Where Extension = 'pst' AND Drive='" & DiskLetter & "'")
        ' display selected info about each pst file in colFiles array
        For Each objFile in colFiles
                    WScript.Echo ComputerName
                    WScript.Echo objFile.Drive & objFile.Path & objFile.FileName & "." & objFile.Extension
                    WScript.Echo objFile.FileSize
                    WScript.Echo " "
        Next
Next

Set DiskLetters = Nothing
' delete trash >Const ADS_NAME_INITTYPE_GC = 3
Const ADS_NAME_TYPE_NT4 = 3
Const ADS_NAME_TYPE_1779 = 1
Const ForAppending = 8

' Initializing security group and textfile for .pst paths and other info
' todo: receive it from arguments
sGroup = "KAISERHOF\computers"
strFile = "PstList.txt"

Dim colPingResults, objPingResult, strQuery

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFileList = objFSO.OpenTextFile(strFile, ForAppending, True) ' open textfile from strFile for appending new data
' delete trash >Set dtmConvertedDate = CreateObject("WbemScripting.SWbemDateTime") 
Set objTrans = CreateObject("NameTranslate") ' variable for translate _NT4 name type to _1779
Set myArray = CreateObject("System.Collections.ArrayList") ' array for local disk letters

objTrans.Set ADS_NAME_TYPE_NT4, sGroup ' translating names for correct request
strGroupDN = objTrans.Get(ADS_NAME_TYPE_1779)

Set objGroup = GetObject ("LDAP://" & strGroupDN) ' request to AD for security group members
objGroup.GetInfo

arrMemberOf = objGroup.GetEx("member") ' populating array with security group members names

For Each strMember in arrMemberOf ' deleting $ from end of each computer name in array
Set objUser = GetObject ("LDAP://" & strMember)

ComputerName = TRIM(Left(objUser.sAMAccountName,Instr(objUser.sAMAccountName, "$")-1)) ' trim command

strQuery = "SELECT * FROM Win32_PingStatus WHERE Address = '" & ComputerName & "'"
Set colPingResults = GetObject("winmgmts://./root/cimv2").ExecQuery(strQuery)

	For Each objPingResult In colPingResults
        	If objPingResult.StatusCode = 0 Then
        		Set objWMIService = GetObject("winmgmts:{impersonationLevel=Impersonate}!//" & ComputerName)
        		Set wmiDiskDrives =  objWMIService.ExecQuery("SELECT DeviceID FROM Win32_DiskDrive")

					For Each wmiDiskDrive In wmiDiskDrives
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
        		
    For Each DriveLetter in myArray
        		'Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & ComputerName & "\root\cimv2")
				Set colFiles = objWMIService.ExecQuery("Select * from CIM_DataFile Where Extension = 'pst' AND Drive='" & DriveLetter & "'")
    	For Each objFile in colFiles
            		Wscript.Echo ComputerName & " " & objFile.FileName & "." & objFile.Extension
            		objFileList.WriteLine ComputerName
    				objFileList.WriteLine objFile.Drive & objFile.Path
    				objFileList.WriteLine objFile.FileName & "." & objFile.Extension
    				objFileList.WriteLine objFile.FileSize
    				objFileList.WriteLine "============================================"
		Next
	Next
        	
        	Else
            	Wscript.Echo "offline " & ComputerName
        	End If
	Next
' objFile.writeline ComputerName
Next

objFileList.close
Set objFile = Nothing
Set objFSO = Nothing
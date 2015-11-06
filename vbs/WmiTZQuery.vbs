' delete trash >Const ADS_NAME_INITTYPE_GC = 3
Const ADS_NAME_TYPE_NT4 = 3
Const ADS_NAME_TYPE_1779 = 1

' Initializing security group
' todo: receive it from arguments
sGroup = "KAISERHOF\computers"

Dim colPingResults, objPingResult, strQuery

Set objFSO = CreateObject("Scripting.FileSystemObject")
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
        		
        		Set objSWbemServices = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & ComputerName & "\root\cimv2")
				Set colTimeZone = objSWbemServices.ExecQuery ("SELECT * FROM Win32_TimeZone")
				Set colItems = objSWbemServices.ExecQuery ("SELECT * FROM Win32_LocalTime")
				Set colOperatingSystems = objSWbemServices.ExecQuery ("SELECT * FROM Win32_OperatingSystem")
					
					For Each objTimeZone in colTimeZone
 						Wscript.Echo ComputerName & "  " & vbTab & " Timezone: " & vbTab & objTimeZone.StandardName
					Next

					'For Each timeStamp in colItems
					''	Wscript.Echo  timeStamp.Hour & ":" & timeStamp.Minute
					'Next

					'For Each osver in colOperatingSystems
					''	Wscript.Echo osver.Caption & "  " & osver.Version
					''	Wscript.Echo " "
					'Next
        	
        	Else
            	Wscript.Echo "offline " & ComputerName
        	End If
	Next
Next

'objFileList.close
Set objFile = Nothing
Set objFSO = Nothing
HotFixID = InputBox("Enter the Microsoft KB# to check for: ONLY the kb number, no letters. This script will only find MS Windows Upates. Do not include Office or other MS products","Enter KB number only")

If HotFixID = "" Then
  WScript.Quit
End If


strputer = InputBox("Enter the MACHINE NAME or IP address of the computer to check:","Computer to Check")

If strputer = "" Then
  WScript.Quit
End If

status = CheckParticularHotfix(strputer, HotFixID)
If status = true then
	wscript.Echo "The Microsoft KB" & HotFixID & " IS installed."
Elseif status = false Then
	wscript.Echo "The Microsoft KB" & HotFixID & " is NOT installed."
else 
	'Error
	wscript.Echo "Error, unable to check for Microsoft KB. Error is: " & status
end if

private Function CheckParticularHotfix(strPuter, strHotfixID)
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' 
	' Version 1.0
	' Checks if a particular hotfix is installed or not. 
	' This function has these 3 return options:
	' TRUE, FALSE, <error description> 
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' 
	On error resume next
	Set objWMIService = GetObject("winmgmts:" _
	    & "{impersonationLevel=impersonate}!\\" & strPuter & "\root\cimv2")
	if err.number <> 0 then
		CheckParticularHotfix = "WMI could not connect to computer '" & strPuter & "'"
		exit function 'No reason to continue
	end if
	
	strWMIforesp = "Select * from Win32_QuickFixEngineering where HotFixID = 'Q" & strHotfixID &_ 
    "' OR HotFixID = 'KB" & strHotfixID & "'"
	Set colQuickFixes = objWMIService.ExecQuery (strWMIforesp)
	if err.number <> 0 Then	'if an error occurs
		CheckParticularHotfix = "Unable to get WMI hotfix info"
	else 'Error number 0 meaning no error occured 
		tal = colQuickFixes.count
		if tal > 0 then
			CheckParticularHotfix = True	'HF installed
		else 
			CheckParticularHotfix = False	'HF not installed
		end If
	end if
	Set colQuickFixes = Nothing
	
	Err.Clear
	On Error GoTo 0
end function
Const ADS_NAME_INITTYPE_GC = 3
Const ADS_NAME_TYPE_NT4 = 3
Const ADS_NAME_TYPE_1779 = 1
Const ForAppending = 8
Const StdOut = 1

' sGroup = InputBox("Enter group name")
'sGroup = "KAISERHOF\" & sGroup
sGroup = "KAISERHOF\computers"
'strFile = InputBox("Enter output file")
strFile = "members.txt"

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile(strFile, ForAppending, True)
Set Shout = objFSO.GetStandardStream(StdOut)

Set objTrans = CreateObject("NameTranslate")
objTrans.Set ADS_NAME_TYPE_NT4, sGroup
strGroupDN = objTrans.Get(ADS_NAME_TYPE_1779)

Set objGroup = GetObject ("LDAP://" & strGroupDN)
objGroup.GetInfo

arrMemberOf = objGroup.GetEx("member")

For Each strMember in arrMemberOf
Set objUser = GetObject ("LDAP://" & strMember)
' deleting $ from the right
ComputerName = TRIM(Left(objUser.sAMAccountName,Instr(objUser.sAMAccountName, "$")-1))
' writing a line with computer name
Shout.WriteLine ComputerName
objFile.writeline ComputerName
Next

objFile.close
Set objFile = Nothing
Set objFSO = Nothing
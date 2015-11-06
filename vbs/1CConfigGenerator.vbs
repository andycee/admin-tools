' Скрипт делает следующее:
' 1. Проверяет установлена ли 1С, если нет — скрипт завершается.
' 2. Проверяет существует ли файл ibases.v8i, и перезаписывает его пустым (или создает в случае отсутствия).
' 3. Извлекает все группы из AD, членом которых является пользователь.
' 4. Отбрасывает все, кроме тех, которые начинаются с 1C_82.
' 5. Получает значение атрибута «Notes».
' 6. Прописывает значение этого атрибута в файл 1CEStart.cfg
' Попутно пишется лог:
' Для Windows 7 — C:\Users\username\appdata\Local\Temp\_dbconn.log
' Для Windows XP — C:\Documents and Settings\username\Local Settings\Temp\_dbconn.log

On Error Resume Next
Const PROPERTY_NOT_FOUND  = &h8000500D
Dim sGroupNames
Dim sGroupDNs
Dim aGroupNames
Dim aGroupDNs
Dim aMemof
Dim oUser
Dim tgdn
Dim fso
Dim V8iConfigFile
Dim dir
Const ForReading = 1, ForWriting = 2, ForAppending = 8
'Настраиваем лог файл
Set fso = CreateObject("Scripting.FileSystemObject")
Set WshShell = WScript.CreateObject("Wscript.Shell")
strSysVarTEMP = WshShell.ExpandEnvironmentStrings("%TEMP%")
Set oScriptLog = fso.OpenTextFile(strSysVarTEMP + "\_dbconn.log",ForWriting,True)
oScriptLog.Write ""
strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "Start..."
oScriptLog.WriteLine(strToLog)

'Проверяем, что 1С установлена
Set objFSO = CreateObject("Scripting.FileSystemObject")
If Not (objFSO.FolderExists("C:\Program Files\1cv82") Or objFSO.FolderExists("C:\Program Files (x86)\1cv82")) Then
 strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "1C 8.2 not installed... Quit..."
 oScriptLog.WriteLine(strToLog)
    WScript.quit
End If

'Проверяем есть ли старый файл и удаляем в случае наличия'
 APPDATA = WshShell.ExpandEnvironmentStrings("%APPDATA%")
 v8i = APPDATA + "\1C\1CEStart\ibases.v8i"
 If fso.FileExists(v8i) Then 
    fso.DeleteFile(v8i)
    Set V8iConfigFile = fso.CreateTextFile(v8i ,True)
    strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "Удален файл v8i и создан новый"
    oScriptLog.WriteLine(strToLog)
' Если файла нет (1С только установлена), то создаем файла по указанному пути
 Else
    Set dir = fso.CreateFolder(APPDATA + "\1C")
    Set dir = fso.CreateFolder(dir + "\1CEStart")
    Set V8iConfigFile = fso.CreateTextFile(v8i ,True)
    strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "Создан файл v8i"
    oScriptLog.WriteLine(strToLog)
 End if

'
' Initialise strings. We make the assumption that every account is a member of two system groups
'
sGroupNames = "Authenticated Users(S),Everyone(S)"
'
' Enter the DN for the user account here
Set objSysInfo = CreateObject("ADSystemInfo")
strUserName = objSysInfo.UserName
strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "Logged user DN: "+strUserName
oScriptLog.WriteLine(strToLog)

'  Получаем имя залогиненного пользователя
Set oUser = GetObject("LDAP://" + strUserName)
If Err.Number <> 0 Then
        strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "There is an error retrieving the account. Please check your distinguished name syntax assigned to the oUser object."
        oScriptLog.WriteLine(strToLog)
  WScript.quit
End If
'
' Determine the DN of the primary group
' We make an assumption that every user account is a member of a primary group
' 
iPgid = oUser.Get("primaryGroupID")
sGroupDNs = primgroup(iPgid)
tgdn = sGroupDNs
'
' Call a subroutine to extract the group name and scope
' Add the result to the accumulated group name String
'
Call Getmemof(tgdn)
'
' Check the direct group membership for the User account
'
aMemOf = oUser.GetEx("memberOf")
If Err.Number <> PROPERTY_NOT_FOUND Then
'
' Call a recursive subroutine to retrieve all indirect group memberships
'
        Err.clear
    For Each GroupDN in aMemof
        Call AddGroups(GroupDN)
        Call Getmemof(GroupDN)
    Next
End If

aGroupNames = Split(sGroupNames,",")
aGroupDNs = Split(sGroupDNs,":")

'Откидываем все группы, кроме начинающихся с 1C_82
For Each strGroupDN in aGroupDNs
 if StrComp(Mid(strGroupDN,1,8), "CN=1C_82", vbTextCompare) = 0 Then
  strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "User is member of: " + strGroupDN
  oScriptLog.WriteLine(strToLog)
  Set objGroup = GetObject("LDAP://" & strGroupDN)
  If Err.Number <> 0 Then
   strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "There is an error retrieving the group. Please check your distinguished name syntax assigned to the objGroup object: " + strGroupDN
   oScriptLog.WriteLine(strToLog)
   WScript.quit
  End If
  strInfo = objGroup.Get("info")
  strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "Group " + strGroupDN +" info field: " + strInfo
  oScriptLog.WriteLine(strToLog)
  strAllInfo = strAllInfo & ":" & strInfo
    
    
 End If
Next

aInfoStrings = Split(strAllInfo,":")

Call WriteDBSettings()

Sub WriteDBSettings()
'Прописываем ссылки на v8i файлы в 1CEStart.cfg
strSysVarAPPDATA = WshShell.ExpandEnvironmentStrings("%APPDATA%")
strDBConfigFilePath = strSysVarAPPDATA + "\1C\1CEStart\1CEStart.cfg"
strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "1C Config file is: " + strDBConfigFilePath
oScriptLog.WriteLine(strToLog)

If (fso.FileExists(strDBConfigFilePath)) Then
 Set objDBConfigFile = fso.OpenTextFile(strDBConfigFilePath,ForWriting,True)
 objDBConfigFile.Write ""
 For each strInfo in aInfoStrings
  objDBConfigFile.WriteLine("CommonInfoBases=" + strInfo)
  strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "Add Line: " + "CommonInfoBases=" + strInfo
  oScriptLog.WriteLine(strToLog)
 next
'Изменить на 0, если аппаратные лицензии не используются
 objDBConfigFile.WriteLine("UseHWLicenses=1")
 strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "Add Line: " + "UseHWLicenses=1"
 oScriptLog.WriteLine(strToLog)
 strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "Ready"
 oScriptLog.WriteLine(strToLog)
 objDBConfigFile.Close
Else
 Set fso = CreateObject("Scripting.FileSystemObject")
 Set WshShell = WScript.CreateObject("Wscript.Shell")
 Set objDBConfigFile = fso.OpenTextFile(strDBConfigFilePath,ForWriting,True)
 objDBConfigFile.Write ""
 For each strInfo in aInfoStrings
  objDBConfigFile.WriteLine("CommonInfoBases=" + strInfo)
  strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "Add Line: " + "CommonInfoBases=" + strInfo
  oScriptLog.WriteLine(strToLog)
 next
 strToLog = CStr(Date())+" "+CStr(Time()) + " - " + "1C Config file" + strDBConfigFilePath + " Not Exist! Create!"
 oScriptLog.WriteLine(strToLog)
 WScript.Quit
End If

End Sub

'*************************************************************************************************
' End of mainline code
'*************************************************************************************************

Function primgroup(groupid)
' This function accepts a primary group id
' It binds to the local domain and returns the DN of the primary group
' David Zemdegs 6 May 2008
'
Dim oRootDSE,oConn,oCmd,oRset
Dim ADDomain,srchdmn
' Bind to loca domain
Set oRootDSE = GetObject("LDAP://RootDSE")
ADDomain = oRootDSE.Get("defaultNamingContext")
srchdmn = "<LDAP://" & ADDomain & ">"
'
' Initialise AD search and obtain the recordset of groups
' 
Set oConn = CreateObject("ADODB.Connection")
oConn.Open "Provider=ADsDSOObject;"
Set oCmd = CreateObject("ADODB.Command")
oCmd.ActiveConnection = oConn
oCmd.CommandText = srchdmn & ";(objectCategory=Group);" & _
        "distinguishedName,primaryGroupToken;subtree" 
Set oRset = oCmd.Execute
'
' Loop through the recordset and find the matching primary group token
' When found retrieve the DN and exit the loop
' 
Do Until oRset.EOF
    If oRset.Fields("primaryGroupToken") = groupid Then
        primgroup = oRset.Fields("distinguishedName")
        Exit Do
    End If
    oRset.MoveNext
Loop
'
' Close and tidy up objects
' 
oConn.Close
Set oRootDSE = Nothing
Set oConn = Nothing
Set oCmd = Nothing
Set oRset = Nothing
End Function
Sub Getmemof(sDN)
'
' This is recursive subroutine that calls itself for memberof Property
' David Zemdegs 6 May 2008
'
On Error Resume Next
Dim oGrp
Dim aGrpMemOf
Dim sGrpDN
Set oGrp = GetObject("LDAP://" & sDN)
aGrpMemOf = oGrp.GetEx("memberOf")
If Err.Number <> PROPERTY_NOT_FOUND Then
'
' Call a recursive subroutine to retrieve all indirect group memberships
'
        Err.clear
    For Each sGrpDN in aGrpMemOf
                Call AddGroups(sGrpDN)
        Call Getmemof(sGrpDN)
    Next
End If
Err.clear
Set oGrp = Nothing
End Sub
Sub AddGroups(sGdn)
'
' This subroutine accepts a disguished name
' It extracts the RDN as the group name and determines the group scope
' This is then appended to the group name String
' It also appends the DN to the DN String
'
Const SCOPE_GLOBAL = &h2
Const SCOPE_LOCAL = &h4
Const SCOPE_UNIVERSAL = &h8
Dim SNewgrp
'
' Retrieve the group name
'
iComma = InStr(1,sGdn,",")
sGrpName = Mid(sGdn,4,iComma-4)

'
' Add the results to the group name String
' Check that the group doesnt already exist in the list
'
sNewgrp = sGrpName
If InStr(1,sGroupNames,SNewgrp,1) = 0 Then
        sGroupNames = sGroupNames & "," & SNewgrp
End If
'
' Add the Groups DN to the string if not duplicate
'
If InStr(1,sGroupDNs,sGdn,1) = 0 Then
        sGroupDNs = sGroupDNs & ":" & sGdn
End If
End Sub
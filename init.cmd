@echo off
echo ======================
echo workstation: %~1
echo ======================

echo ========================step0
C:\PsTools\psexec.exe -s \\%~1 cmd /c "xcopy \\10.0.14.253\share\content\powershell\*.* c:\ /y"
if %ERRORLEVEL% equ 0 goto step1
goto end

:step1
echo ========================step1
C:\PsTools\psexec.exe \\%~1 cmd /c c:\NetFx20SP1_x86.exe /quiet> NUL
if %ERRORLEVEL% equ 0 goto step2
goto end

:step2
echo ========================step2
C:\PsTools\psexec.exe \\%~1 cmd /c c:\WindowsXP-KB968930-x86-RUS.exe /quiet /log:c:\install.log> NUL
if %ERRORLEVEL% equ 0 goto step3
if %ERRORLEVEL% equ 1603 goto step3
if %ERRORLEVEL% equ 9009 goto step4
goto end

:step3
echo ========================step3
C:\PsTools\psexec.exe -s \\%~1 cmd /c %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe Enable-PSRemoting -Force> NUL
if %ERRORLEVEL% equ 0 goto step4
if %ERRORLEVEL% equ 9009 goto step4
goto end

:step4
echo ========================step4
C:\PsTools\psexec.exe -s \\%~1 cmd /c winrm set winrm/config/service @{AllowUnencrypted="true"}> NUL
if %ERRORLEVEL% equ 0 goto step5
goto step5

:step5
echo ===========================
echo Initialization successfull!
echo ===========================
pause


:end
echo =====================
echo something goes wrong!
echo =====================
pause
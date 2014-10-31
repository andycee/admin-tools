@echo off
net use M: \\%~1\C$ 1> null
echo remote root filesystem successfully connected...
cd C:\pstools\
mkdir m:\tzfixp
copy tzfixp\*.* m:\tzfixp\
psexec \\%~1 C:\tzfixp\posready.cmd
psexec \\%~1 C:\tzfixp\fix.cmd
psexec \\%~1 C:\tzfixp\posnotready.cmd
psexec \\%~1 C:\tzfixp\tzchange.cmd
del m:\tzfixp /Q
net use m: /delete /y 1> null
echo remote root filesystem successfully disconnected...
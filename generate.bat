@echo off
net use M: \\%~1\C$ 1> null
echo remote root filesystem successfully connected...
cd C:\pstools\
copy key\keyfinder.* m:\
psexec \\%~1 C:\key\keyfinder.exe /save /close
move m:\wka*.txt C:\Code\admin-tools\osinfo
del m:\keyfinder*
net use m: /delete /y 1> null
echo remote root filesystem successfully disconnected...
@echo off
net use M: \\%~1\C$ 1> null
echo remote root filesystem successfully connected...
cd C:\pstools\
copy key\keyfinder.* m:\
psexec \\%~1 C:\keyfinder.exe /save /close
move m:\wka*.txt c:\pstools\osinfo\
del m:\keyfinder*
net use m: /delete /y 1> null
echo remote root filesystem successfully disconnected...
@echo off
net use U: /delete /y 1> null
net use U: \\skaidc01\users\%USERNAME% 1> null
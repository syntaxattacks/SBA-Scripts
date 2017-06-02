@echo off
:sourceloop
Echo
Echo
Echo ********************************************************
set /P sourcepath="Enter the path to be copied: "
IF NOT EXIST %sourcepath% (goto :sourceloop)
CLS

:destinationloop
Echo
Echo
Echo ********************************************************
set /P destinationpath="Enter the path being copied to: "
IF NOT EXIST %destinationpath% goto :destinationloop
CLS


::call :sourceloop
::call :destinationloop

pause

mkdir I:\"Transfer Logs"\%NAME%\

set options=/s /is
set triggers=/w:0 /r:0 /xj /MT:32
set exclusions=/xd *Appdata*
set logfile=/log:"C:\Software\Data Transfer Log.txt" /tee

robocopy  %sourcepath% %destinationpath% %options% %triggers% %exclusions% %logfile%
Find "ERROR " "C:\Software\Data Transfer Log.txt" > "C:\Software\Transfer Errors.txt"
Echo "Transfer has been completed. Press any key to show the transfer logs."
Pause > nul
Pause > nul

start notepad "C:\Software\Transfer Errors.txt"
start notepad "C:\Software\Data Transfer Log.txt"



Exit

@echo off
set /p name="Username = "
set /p oldpc="Old PC Name/IP Address = "
set /p newpc="New PC Name/IP Address = "

mkdir C:\Users\%USERNAME%\"Transfer Logs"\%name%\

set source=\\%oldpc%\c$\Users\%name%
set destination=\\%newpc%\c$\Users\%name%
set options=/s /is
set triggers=/w:0 /r:0 /xj /MT:64 /xd LocalService NetworkService *temp *"temporary internet files" *cache
set logfile=/log:C:\Users\%USERNAME%\"Transfer Logs"\%name%\"Data Transfer from %oldpc% to %newpc%.log" /tee

robocopy    
robocopy \\%oldpc%\c$\Scans\ \\%newpc%\c$\Scans\ /s /is /w:0 /r:0 /xj /MT:64 /xd LocalService NetworkService *temp *"temporary internet files" *cache /log:C:\Users\%USERNAME%\"Transfer Logs"\%name%\"Scans Transfer" /tee
robocopy \\%oldpc%\c$\Delorme\ \\%newpc%\c$\Delorme\ /s /is /w:0 /r:0 /xj /MT:64 /xd LocalService NetworkService *temp *"temporary internet files" *cache /log:C:\Users\%USERNAME%\"Transfer Logs"\%name%\"Delorme Transfer.log" /tee
Echo
Echo
Echo
echo *************************************************
echo Transfer complete. Press any key to continue
echo *************************************************
pause>nul
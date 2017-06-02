::Written by David Hann on 4/3/2015
@echo off
:prompt
color 1F
if exist del logging.txt /q
cls
:restart
echo ************************
echo ENTER TARGET HOST ID :
echo ************************
set /p host="HOST ID = "
:options
cls
echo.
echo HOST ID = %host%
echo ************************
echo      MAIN MENU
echo ************************
echo 1 - PING
echo 2 - NSLOOKUP
echo 3 - WIN EXPLORER TO C DRIVE
echo 4 - TRACERT
echo 5 - PING LOOP
echo 6 - NETVIEW
echo 7 - REMOTE DESKTOP
echo 8 - WINRS CMD Prompt
echo       **********
echo N - NET USE  W/Username
echo R - RESET TO ANOTHER IP
echo C - OPEN CMD WINDOW
echo X - EXIT PROGRAM
echo ************************
set /p input="Enter Options Here: "

if "%input%"=="1" goto:PING
if "%input%"=="2" goto:NSLOOKUP
if "%input%"=="3" goto:EXPLORER
if "%input%"=="4" goto:TRACERT
if "%input%"=="5" goto:PINGLOOP
if "%input%"=="6" goto:NETVIEW
if "%input%"=="7" goto:REMOTE
if "%input%"=="8" goto:WINRS
if "%input%"=="n" goto:NETUSEA
if "%input%"=="N" goto:NETUSEA
if "%input%"=="c" goto:CMD
if "%input%"=="C" goto:CMD
if "%input%"=="r" goto:RESET
if "%input%"=="R" goto:RESET
if "%input%"=="x" goto:exit
if "%input%"=="X" goto:exit
 
echo Please choose from the Options listed above!
pause
goto:options


:PING
ping "%host%"
pause
goto options


:NSLOOKUP
Nslookup "%host%" 
pause
goto options


:EXPLORER
explorer "\\%host%\C$"
goto options


:TRACERT
start cmd /k tracert %host%"
goto:options


:PINGLOOP
start cmd /k ping "%host%" -t
goto options


:NETVIEW
start cmd /k net view "%host%"
goto options


:REMOTE
mstsc.exe /v "%host%"
goto options

:WINRS
Winrs /r:"%host%" cmd

:NETUSEA
set /p name="Enter Username: "
net use /sbasite "%name%"
pause
goto options


:cmd
start cmd /k
goto:options
 
 
:RESET
del logging.txt /q
cls
goto:restart
 
 
:exit
exit
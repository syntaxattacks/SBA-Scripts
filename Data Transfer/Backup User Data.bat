::		.SYNOPSIS
::		The purpose of this script is to take all of a user's pertinent data and move it to a new PC for them. It will move all data from their user
::		profile as well as some other pertinent data like the Scans and Delorme folders on their C drive. If they keep any data outside their user
::		profile it will not be moved by this script. 
::
::		.DESCRIPTION
::		This script is smart. It will check to make sure the computers are online and we don't run any robocopy operations we don't need to. It
::		might also do your homework for you as long as you're not taking "Advanced Physics" or something crazy...
::
::		.NOTES
::		File Name      : Copy User Data PC to PC.bat
::      Author         : Dave Hann (dhann@sbasite.com)
::      Version        : 2.0, modified 8/5/2015
::
::
	
@echo off
::to avoid any ugly text in this beautiful script::



::		DIALOGUE BOXES - This calls up the boxes for user entry and sets  the variables for Username, Old PC, and New PC. These input boxes reference the functions at the bottom of this script. By calling the inputbox instead of using GOTO we don't have to worry about jumping around in the script.

call :inputbox "Please enter the username that is transferring data:" "Username"
echo %NAME% is migrating their data

call :inputbox2 "Please enter the Name or IP address of the computer:" "Old PC"
echo from %PC%


::		Here they have a chance to review their input to make sure everything is accurate and proceed.
echo.
echo.
echo.
echo If this information is correct, press any key to continue...
pause>nul

::		CHECK TO SEE IF THE COMPUTERS ARE ONLINE - If either of the computers are offline then it will output an error message. See :bad below.
ping -n 1 %PC% > nul
if errorlevel 1 goto OfflinePC
 
 

 
 ::		START OF SCRIPT - This is there the action starts. A folder will be created to contain the logfile on your PC for easy access. If it is already there it will probably tell you so.
 
mkdir C:\Users\%USERNAME%\"Backup Logs"\%name%\

::		Variables - This sets the variables used in the robocopy. Here you can modify the destination, source, triggers, exclusions, etc...
set source=\\%PC%\c$\Users\%name%
set destination=\\fl1hdnas1\workstationbackups$\%name%\
set options=/s /is
set triggers=/w:0 /r:0 /xj /MT:64
set exclusions=/xd LocalService NetworkService *temp* *"temporary internet files" *cache ntuser*
set logfile=/log:"C:\Users\%USERNAME%\Backup Logs\%name%\Data Backup from %PC%.log" /tee

::		USER PROFILE COPY - This is the copy of the user profile. Here we string together the variables we just set up.
robocopy  %source% %destination% %options% %triggers% %exclusions% %logfile%


::		SCANS FOLDER - This checks to see if the Scans folder exists on the C drive. If it isn't there it will jump down to :skip
IF NOT EXIST "C:\Scans\" (GOTO Skip)

set source=\\%PC%\c$\Scans
set destination=\\fl1hdnas1\workstationbackups$\%name%\Scans\
set logfile=/log:"C:\Users\%USERNAME%\Backup Logs\%name%\Scans Backup from %PC%.log" /tee

robocopy  %source% %destination% %options% %triggers% %logfile%

:skip

::		DELORME FOLDER - This checks to see if the Delorme folder exists on the C drive. If it isn't there it will jump down to :skip2. We use two skips so if they have Delorme but not scans it will get picked up.
IF NOT EXIST "C:\Delorme\" (GOTO Skip2)
set source=\\%PC%\c$\Delorme

set logfile=/log:"C:\Users\%USERNAME%\Backup Logs\%name%\Delorme Backup from %PC%.log" /tee
set destination=\\fl1hdnas1\workstationbackups$\%name%\Delorme\
robocopy  %source% %destination% %options% %triggers% %logfile%

:skip2

::		IT'S OVER! - The script is done. We echo a completion notice and prompt them to press a key to close it out, that way they 
Echo *
Echo *
Echo *
echo ****************************************************************
Echo *
Echo *
echo * Transfer complete. Press any key to continue...
Echo *
Echo *
echo ****************************************************************
pause>nul
pause>nul
pause>nul

exit


::		This is where the user will get kicked to when one of the PCs doesn't respond to a ping.
:OFFLINEPC
echo *
echo *
echo *
echo ****************************************************************
echo *	
echo *	
echo * One or more computers is offline. Please check the connections and try again
echo *	
echo *	
echo ****************************************************************
pause>nul
pause>nul
pause>nul
exit

:: INPUTBOX FUNCTIONS - Not much to see here. These are the mechanical part of the dialogue boxes and sets the input to the variables for Username, PC and Newpc

:InputBox
set input=
set heading=%~2
set message=%~1
echo wscript.echo inputbox(WScript.Arguments(0),WScript.Arguments(1)) >"%temp%\input.vbs"
for /f "tokens=* delims=" %%a in ('cscript //nologo "%temp%\input.vbs" "%message%" "%heading%"') do set name=%%a
exit /b

:InputBox2
set input=
set heading=%~2
set message=%~1
echo wscript.echo inputbox(WScript.Arguments(0),WScript.Arguments(1)) >"%temp%\input.vbs"
for /f "tokens=* delims=" %%a in ('cscript //nologo "%temp%\input.vbs" "%message%" "%heading%"') do set PC=%%a
exit /b
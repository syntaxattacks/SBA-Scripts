:: Welcome to the image wizard! For best results please load this bat onto your WinPE thumb drive and boot it up once the PE is loaded.
:: It uses a series of GOTO commands and functions to simulate a menu.


color 0A
@ECHO OFF
CLS
:: Colors to set the mood and clearing the screen to keep things tidy.



:MENU
CLS
type wizard.txt
ECHO.
ECHO ========== Imaging  Wizard ==========
ECHO -------------------------------------
ECHO 0.  Disk Wipe
ECHO 1.  New Image
ECHO 2.  Computer Backup
ECHO 3.  Computer Transfer
ECHO 4.  Open CMD
ECHO 5.  List Mounted Volumes
ECHO 6.  Backup User Profile To Network
ECHO -------------------------------------
ECHO.

SET INPUT=
SET /P INPUT=Please select a number:

IF /I '%INPUT%'=='0' GOTO Disk Wipe
IF /I '%INPUT%'=='1' GOTO New Image
IF /I '%INPUT%'=='2' GOTO Computer Backup
IF /I '%INPUT%'=='3' GOTO Computer Transfer
IF /I '%INPUT%'=='4' GOTO CMD
IF /I '%INPUT%'=='5' GOTO Drive List
IF /I '%INPUT%'=='6' GOTO Profile Backup

IF /I '%INPUT%'=='Q' GOTO Quit
IF /I '%INPUT%'=='q' GOTO Quit

CLS

ECHO ============INVALID INPUT============
ECHO -------------------------------------
ECHO Please select a number from the Main
echo Menu [0-5] or select 'Q' to quit.
ECHO -------------------------------------
ECHO ======PRESS ANY KEY TO CONTINUE======

PAUSE > NUL
GOTO MENU

:Computer Backup

net use Z: \\fl1hdnas1\workstationbackups$
ECHO.
ECHO Press any key to continue.
Pause>NUL
Z:
Ghost32 -split=745 -ntic -fro
GOTO :MENU

:Computer Transfer

net use X: \\fl1hdnas1\transfer$
ECHO.
ECHO Press any key to continue.
Pause>NUL
X:
Ghost32 -split=745 -ntic -fro
GOTO :MENU

:New Image

net use V: \\fl1image3\images$
ECHO.
ECHO Press any key to continue.
Pause>NUL
V:
Ghost32 -auto -rb
GOTO :MENU

:Disk Wipe

@echo off 
ECHO.
ECHO.
SET INPUT=
SET /P ANSWER=THIS ACTION WILL ERASE THE DISK!!!!!!!!!! ARE YOU SURE (Y/N)? 
if /i {%ANSWER%}=={y} (goto :yes) 
if /i {%ANSWER%}=={Y} (goto :yes) 
if /i {%ANSWER%}=={yes} (goto :yes) 
if /i {%ANSWER%}=={n} (goto :no)
if /i {%ANSWER%}=={N} (goto :no)
if /i {%ANSWER%}=={no} (goto :no)

:Profile Backup

@echo off
set /p name=Enter UserID:
net use Z: \\fl1hdnas1\workstationbackups$ 
mkdir Z:\%NAME%\
set source=C:\Users\%name%\
set destination=Z:\%name%\
set options=/s /is
set triggers=/w:0 /r:0 /xj /MT:32
set exclusions=/xd LocalService NetworkService *temp* *"temporary internet files" *cache ntuser*
set logfile=/log:"Z:\%NAME%\Transfer.log" /tee
robocopy  %source% %destination% %options% %triggers% %exclusions% %logfile%

IF NOT EXIST "C:\Scans\" (GOTO Skip)

set source=C:\Scans\
set destination=Z:\%name%\\Scans
set logfile=/log:"Z:\%NAME%\Scans.log" /tee

robocopy  %source% %destination% %options% %triggers% %logfile%

:skip

::		DELORME FOLDER - This checks to see if the Delorme folder exists on the C drive. If it isn't there it will jump down to :skip2. We use two skips so if they have Delorme but not scans it will get picked up.
IF NOT EXIST "C:\Delorme\" (GOTO Skip2)
set source=C:\Delorme\
set destination=Z:\%name%\Delorme\
set logfile=/log:"Z:\%NAME%\Delorme.log" /tee

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

Goto :Disk Wipe

:CMD

start cmd
GOTO :MENU

:Drive List

net use
PAUSE > NUL
GOTO MENU

:yes 

@echo off 
ECHO.
ECHO.
SET INPUT=
SET /P ANSWER2=Are you REALLY sure? The data CANNOT be recovered once cleaned (Y/N)? 
if /i {%ANSWER2%}=={y} (goto :yes yes) 
if /i {%ANSWER2%}=={Y} (goto :yes yes) 
if /i {%ANSWER2%}=={yes} (goto :yes yes) 
if /i {%ANSWER2%}=={n} (goto :no)
if /i {%ANSWER2%}=={N} (goto :no)
if /i {%ANSWER2%}=={no} (goto :no)

:Yes Yes

echo You chose YES
echo Your data will now be deleted... 
diskpart /s startdiskwipe.txt
echo Press any key to continue
PAUSE>NUL
CLS
GOTO :MENU



:no 
echo You chose NO
echo Press any key to return to the main menu.
PAUSE>NUL
@echo off
CLS
GOTO :MENU



:Quit
CLS

ECHO ==============THANKYOU===============
ECHO -------------------------------------
ECHO ======PRESS ANY KEY TO CONTINUE======

PAUSE>NUL
EXIT

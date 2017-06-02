:: Welcome to the image wizard! For best results please load this bat onto your WinPE thumb drive and boot it up once the PE is loaded.
:: It uses a series of GOTO commands and functions to simulate a menu.


color 0A
@ECHO OFF
CLS
:: Colors to set the mood and clearing the screen to keep things tidy.

ECHO Please remove thumb drive before continuing. Press enter when finished.
pause

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
PAUSE>NUL
exit
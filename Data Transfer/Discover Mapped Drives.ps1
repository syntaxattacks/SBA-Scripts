<#
.SYNOPSIS
    This script was made to generate a list of network drives the targeted user has mapped
.DESCRIPTION
    Just a simple script that takes your input, sets the username/computer variable and runs a gwmi win32_mappedlogicaldisk on it. Pretty straightforward.
.NOTES
    File Name      : Discover Mapped Drives.ps1
    Author         : Dave Hann (dhann@sbasite.com)
    Version        : 1.2, modified 8/26/2015
    Prerequisite   : PowerShell V3
#>


$userid = Read-Host 'Enter Username'
$pc1 = Read-Host 'Enter Host Name/IP Address'
    # This takes your input and sets the variables appropriately
$CurrentUser = @(Get-WmiObject -ComputerName $PC1 -Namespace root\cimv2 -Class Win32_ComputerSystem)[0].UserName;

New-Item -ItemType directory -Force -Path I:\"Transfer Logs"\"$userid"\ -erroraction 'silentlycontinue'
    # This is going to create the folder in your user directory that the logfile will dump to. If it's not there then the logfile won't generate.
    # I've tagged it with the -Force trigger so it doesn't generate any errors if the folder is already there.

clear-host
    # To tidy up the screen from any dialogue of creating the directory

if(!(Test-Connection -Cn $pc1 -BufferSize 16 -Count 1 -ea 0 -quiet)) {
  Write-Host "$PC1 is offline"
  Pause
  Exit
  }
  Else {Write-host "$PC1 is online"}

$FindDrive = gwmi win32_mappedlogicaldisk -ComputerName $pc1 |
  Select Name, ProviderName | out-string
$Export = gwmi win32_mappedlogicaldisk -ComputerName $pc1 |
  Select Name, ProviderName  |
  Out-file I:\"Transfer Logs"\"$userid"\""$pc1" Mapped Drives.log"
    # Dumps the file into the folder we just created.

$Export
Invoke-Item I:\"Transfer Logs"\"$userid"\""$pc1" Mapped Drives.log"
    # Open the file we just created so you can review the information
Write-Host 
Write-Host
Write-Host "Current Logged On User: $CurrentUser"
Write-Host 
Write-Host "The mapped drives have been identified:"
Write-Host
Write-Host  
Write-Host $FindDrive
Pause

#End
<#
.SYNOPSIS
    Gives you a list of printers that a specific user has mapped
.DESCRIPTION
    See above. Uses get win32_printer and refines the data to my liking and spits out a log file for you to enjoy.
.NOTES
    File Name      : Discover Mapped Printers.ps1
    Author         : Dave Hann (dhann@sbasite.com)
    Version        : 1.2, modified 8/26/2015
    Prerequisite   : PowerShell V3
#>

$userid = Read-Host 'Enter Username'
$pc1 = Read-Host 'Enter Host Name/IP Address'
# This takes your input and sets the variables appropriately

New-Item -ItemType directory -Force -Path I:\"Transfer Logs"\"$userid"\
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

$Printers = Get-WmiObject win32_printer -ComputerName $pc1 |
select Name,SystemName,ShareName | Format-List | Out-String

Get-WmiObject win32_printer -ComputerName $pc1 |
select Name,SystemName,ShareName |
# Line 24 gets the list of printers for the PC you specified and 25 filters out anything we don't need.

Out-file I:\"Transfer Logs"\"$userid"\""$pc1" Mapped Printers.log"
# Creates a log for you to review

Invoke-Item I:\"Transfer Logs"\"$userid"\""$pc1" Mapped Printers.log"
# Opens the log so you can immediately see the data.

Write-Host "The mapped printers have been identified:"
Write-Host
Write-Host
Write-Host $Printers
Pause

#end
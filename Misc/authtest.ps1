﻿<#
.SYNOPSIS
    You enter in the user you want to copy from and to, then it will generate all the authorization emails you need
.DESCRIPTION
    This script uses "get-adprinciplegroupmember" with filters to filter specifically the groups we need
    authorization for in new hires. It pulls this list with the "Managedby" property to show who has the
    power to grant access to these groups. It will generate emails by "Managedby" with all applicable groups so you just have to click send
.NOTES
    File Name      : New Hire Authorization.ps1
    Author         : Dave Hann (dhann@sbasite.com)
    Version        : 2.0, modified 8/25/2015
    Prerequisite   : PowerShell V3
#>

if ($OldUser -eq $null){$OldUser = Read-Host 'Userid of the user you are copying groups from'}
if ($NewUser -eq $null){$NewUser = Read-Host 'Userid of the user you are copying to'}
    # These variables accept the user input.

$YourName = Get-ADUser $env:username | Select Name |
 Format-Table -HideTableHeaders | Out-String
    #This is for your name in the email signature

$NewUserName = (Get-ADUser $NewUser -Properties DisplayName | Select Displayname |
  Format-Table -HideTableHeaders | Out-String).Trim()
$NewUserTitle = (Get-ADUser $NewUser -Properties Title | Select Title |
  Format-Table -HideTableHeaders | Out-String).Trim()
$NewUserDepartment = (Get-ADUser $NewUser -Properties Department | Select Department |
  Format-Table -HideTableHeaders | Out-String).Trim()
$NewUserManager = (Get-ADUser $NewUser -Properties Manager |
  Select @{n='Manager';e={$_.Manager -replace '^CN=(.+?),(?:CN|OU).+','$1'}} |
  Format-Table -HideTableHeaders | Out-String).Trim()
    #These are the variables for the new hire.

$Input = 
{Clear-Host
Write-Host
  Write-Host
  Write-Host
if (dsquery user -samid $OldUser){"$OldUser validated in Active Directory."}
  else {"$OldUser is not a recognized UserID."
  Pause
  $Input}
if (dsquery user -samid $NewUser){"$NewUser validated in Active Directory."}
  else {"$NewUser is not a recognized UserID."
  Pause
  $Input}
Write-Host
Write-Host
Write-Output  "This will copy security groups from $OldUser to $NewUser."
Pause
    # This validates the userids in AD and lets you know if you entered in something that doesn't exist.
    }

if ( (Get-Date -UFormat %p) -eq "AM" ) { 
  $Greeting = "Good morning," 
  } #End if
else {
  $Greeting = "Good afternoon,"
  } #end else
    # This checks time of day and sets the greeting

New-Item -ItemType directory -Force -Path I:\"New Hire Logs"\"$NewUser"\ -ea SilentlyContinue
    # So we can dump a logfile at the end of the script

Clear-Host
    # To tidy up the screen from any dialogue of creating the directory

Write-host The script is running. This is going to take a few minutes...
    # We want to make sure the user knows the script is doing its job.

$Groups = Get-ADPrincipalGroupMembership $OldUser |
  Get-ADGroup -Properties Name,managedby | 
  Select Name, @{n='ManagedBy';e={$_.ManagedBy -replace '^CN=(.+?),(?:CN|OU).+','$1'}} |
  Where-Object {$_.managedby -ne ""} | 
  group-object -property managedby
$GroupList = Get-ADPrincipalGroupMembership $OldUser |
  Get-ADGroup -Properties Name,managedby | 
  Select Name, @{n='ManagedBy';e={$_.ManagedBy -replace '^CN=(.+?),(?:CN|OU).+','$1'}} |
  Where-Object {$_.managedby -ne ""}
    # These pull the groups that need approval and groups them by managedby. 
  $OFS = "`t`n"  
  
foreach ($Group in $Groups)
  {
$ManagerMail = get-aduser -filter "displayname -like '$($Group.name)'" -properties Mail | Select Mail |
  Format-Table -HideTableHeaders | Out-String
$ManagerName = (get-aduser -filter "displayname -like '$($Group.name)'" -properties GivenName | 
  Select GivenName | Format-Table -HideTableHeaders | Out-String).Trim()
$Groupnames = ($group.group.name | Out-String).Trim()
    # These set the varialbe for each manager and the groups they own
if ($Groupnames -like  "*Application-Hyperion-Planning*"){
$Managermail = "SManas@sbasite.com"
$Managername = "Sergio"
 }
 if ($Groupnames -like  "*RSMPO*"){
$Managermail = "lcestare@sbasite.com"
 }

 [string]$emailbody = ""
$Outlook = New-Object -ComObject Outlook.Application
  $Mail = $Outlook.Application.CreateItemFromTemplate("H:\Helpdesk\Scripts\Template.oft")
  $Mail.To = $ManagerMail
  $Mail.Subject = "Security Group Access Request - $newusername"
  [string]$Mail.Body =  "$Greeting  $ManagerName


Please approve/deny $NewUserName for access to the following group(s): 
 
$groupnames

Their title is $NewUserTitle and they work in $NewUserDepartment for $NewUserManager"
  $Mail.Display()
  }
    # This is the email that goes to each approver. It uses the variables to fill in relavent information.

$Grouplist | Out-File I:\"New Hire Logs"\"$NewUser"\""$Olduser" Groups.log"
    #This dumps the logfile to your I Drive

Clear-Host 
Write-Host 'The script has completed. The following groups need authorization:' 
    Write-Host
$GroupList
    Write-Host 
    Write-Host  
Pause
    #The script is over! You get a confirmation and a list of all the groups that need approval. Enjoy!
<#
.SYNOPSIS
    This Script will take a user id and give you a list of all groups they are a member of that needs authorizing
    as well as the authorizing party.
.DESCRIPTION
    This script uses "get-adprinciplegroupmember" with filters to filter specifically the groups we need
    authorization for in new hires. It pulls this list with the "Managedby" property to show who has the
    power to grant access to these groups.
.NOTES
    File Name      : Get AD Auth Groups.ps1
    Author         : Dave Hann (dhann@sbasite.com)
    Version        : 1.0, modified 8/5/2015
    Prerequisite   : PowerShell V3
#>


$userid = Read-Host 'Username'
# This is just asking for the user inpput. It sets the input as the variable "$userid" and is used throughout the script


New-Item -ItemType directory -Force -Path C:\Users\$env:username\"Copy User Groups"
# This is going to create the folder in your user directory that the logfile will dump to. If it's not there then the logfile won't generate.
# I've tagged it with the -Force trigger so it doesn't generate any errors if the folder is already there.

clear-host
# To tidy up the screen from any dialogue of creating the directory

Get-ADPrincipalGroupMembership $userid |
Get-ADGroup -Properties Name,managedby |
select Name, @{n='ManagedBy';e={$_.ManagedBy -replace '^CN=(.+?),(?:CN|OU).+','$1'}} |
Where-Object {$_.name -like '*RSMPO*' -or $_.name -like '*Perceptive*' -or $_.name -like '*Hyperion*' -or $_.name -like '*-DOC*'} |
Sort ManagedBy |
Export-Csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv"
# This is the heart of the script. Line 26 pulls all groups the user is a member of. Like 27 pulls the additional properties for the group name and manager.
# Line 28 filters the data to only show the name and the Group Manager, or ManagedBy. All the extra stuff is to filder out the garbage text there, otherwise
# it would look like CN=Tiffany Tatar,OU=Accounting,OU=BocaRaton,DC=sbasite,DC=com.Line 29 is the group filter. It is set to target groups we need for new
# hire authorization but could easily be modified or expanded. Line 30 just sets it to sort by the manager for your own ease. Line 31 generated a CSV with
# the data we collected for ease of use. Eventually we will use this data to generate form emails.


Invoke-item C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv"
# This opens the CSV we just created so you don't have to go digging around for it.




#End

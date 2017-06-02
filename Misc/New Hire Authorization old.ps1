<#
.SYNOPSIS
    You enter in the user you want to copy from and to, then it will generate all the authorization emails you need
.DESCRIPTION
    This script uses "get-adprinciplegroupmember" with filters to filter specifically the groups we need
    authorization for in new hires. It pulls this list with the "Managedby" property to show who has the
    power to grant access to these groups. It will generate emails by "Managedby" with all applicable groups so you just have to click send
.NOTES
    File Name      : New Hire Authorization.ps1
    Author         : Dave Hann (dhann@sbasite.com)
    Version        : 1.0, modified 8/12/2015
    Prerequisite   : PowerShell V3
#>


$userid = Read-Host 'Userid of the user you are copying groups from'
$userid2 = Read-Host 'Userid of the user you are copying to'
# All our variables. Old user, new user, and your name for the signature in the email at the end.

New-Item -ItemType directory -Force -Path C:\Users\$env:username\"Copy User Groups"
# This is going to create the folder in your user directory that the logfile will dump to. If it's not there then the logfile won't generate.
# I've tagged it with the -Force trigger so it doesn't generate any errors if the folder is already there.

clear-host
# To tidy up the screen from any dialogue of creating the directory

Write-host The script is running. This is going to take a few minutes...
# We want to make sure the user knows the script is doing its job.

Get-ADUser $userid2 -Properties DisplayName, Title, Manager, Department  |
Select Displayname, Title, Department, @{n='Manager';e={$_.Manager -replace '^CN=(.+?),(?:CN|OU).+','$1'}} |
Export-CSV C:\Users\$env:username\"Copy User Groups"\""$userid2" Information.csv"
#This is to grab the new user and assigne variables for the emails we generate later.

Get-ADUser $env:username -Properties mail, givenname |
Select name, mail, givenname |
Export-CSV C:\Users\$env:username\"Copy User Groups"\"$env:username Information.csv"
$mycsv = Import-CSV C:\Users\$env:username\"Copy User Groups"\"$env:username Information.csv"
$yourname = $mycsv.name
$youremail = $mycsv.mail
# This collects your name to throw in the bottom of the email in the signature

Get-ADPrincipalGroupMembership $userid |
Get-ADGroup -Properties Name,managedby |
select Name, @{n='ManagedBy';e={$_.ManagedBy -replace '^CN=(.+?),(?:CN|OU).+','$1'}} |
Where-Object {$_.name -like '*RSMPO*' -or $_.name -like '*Perceptive*' -or $_.name -like '*Hyperion*' -or $_.name -like '*-DOC*'} |
Sort ManagedBy |
Export-Csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv"
# This is the heart of the script. It pulls all groups the user is a member of, pulls the additional properties for the group name and manager,
# filters the data to only show the name and the Group Manager, or ManagedBy. All the extra stuff is to filder out the garbage text there, otherwise
# it would look like CN=Tiffany Tatar,OU=Accounting,OU=BocaRaton,DC=sbasite,DC=com. Where-object is the group filter. It is set to target groups we need for new
# hire authorization but could easily be modified or expanded, then if generates a CSV with the data we collected for ease of use.
#



$ADUserInfo = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid2" Information.csv"
$Displayname = $ADUserInfo[0].Displayname
$Title = $ADUserInfo[0].Title
$Department = $ADUserInfo[0].Department
$Manager = $ADUserInfo[0].Manager
# AD User Info - This sets the variables for the user youa re copying to. We will use these in the body of our email to the authorizers.


if ( (Get-Date -UFormat %p) -eq "AM" ) {
    $Greeting = "Good morning,"
    } #End if
else {
    $Greeting = "Good afternoon,"
    } #end else
# Check Time of Day and sets the greeting variable accordingly. We will use this to start our email to the authorizers.


<# Variable to send email. This is a work in progress, I still need to work the manager variables into this.
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = $csv.manager[0]
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()

$Sendmail = $Outlook,$Mail
#>
<#

    This is where the script really does its thing. We import the CSV we just made with all the original user's groups and managers.
    Each manaer has their own script, each time we change the $csv variable to match the manager. This lets us use the $groupname variable
    to dump all groups associated with that manager into the body of the email.

#>


$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv"
# This sets the variable to import the csv with the group information.

<#

 Manager Emails:
    The following is broken out by possible managers. I have listed all security group managers from the "AD Group Managers" list in Sharepoint.
    At the beginning of each section the script will set the import the managedby data sorted by the manager. It will then reset the $groupname
    and $gmanager variables so it will fit into the emails appropriately. Once that is done it will generate an email to them using the variables
    we established earlier in the script. This is not the best solution and I am searching

#>

# Tiffany Tatar's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Tiffany Tatar"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby

if ($gmanager -like "Tiffany Tatar"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'ttatar@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Tiffany<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}


# Bill Sipes's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Bill Sipes"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Bill Sipes"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'bsipes@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Bill<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Alyssa Houlihan's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Alyssa Houlihan"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Alyssa Houlihan"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'ahoulihan@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Alyssa<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Bryan Robertson's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Bryan Robertson"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Bryan Robertson"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'brobertson@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Bryan<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Candice Puleo's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Candice Puleo"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Candice Puleo"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'cpuleo@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Candice<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Debbie Smith's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Debbie Smith"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Debbie Smith"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'dsmith@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Debbie<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# David Tribble's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "David Tribble"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "David Tribble"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'dtribble@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting David<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Glen Smellie's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Glen Smellie"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Glen Smellie"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'gsmellie@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Glen<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Jill Patterson's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Jill Patterson"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Jill Patterson"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'jpatterson@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Jill<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Jim Piper's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Jim Piper"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Jim Piper"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'jpiper@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Jim<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Jill Pontano's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Jill Pontano"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Jill Pontano"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'jpontano@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Jill<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Kurt Bagwell's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Kurt Bagwell"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Kurt Bagwell"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'kbagwell@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Kurt<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Mark Ciarfella's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Mark Ciarfella"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Mark Ciarfella"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'MCiarfella@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Mark<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Matthew Cupples's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Matthew Cupples"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Matthew Cupples"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'mcupples@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Matthew<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Maria Kaland's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Maria Kaland"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Maria Kaland"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'mkaland@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Maria<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Neer Saini's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Neer Saini"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Neer Saini"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'nsaini@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Neer<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Rachel Enfield's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Rachel Enfield"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Rachel Enfield"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'renfield@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Rachel<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Sergio Manas's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Sergio Manas"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Sergio Manas"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'smanas@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Sergio<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Theresa Thompson's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Theresa Thompson"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Theresa Thompson"){
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'tthompson@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Theresa<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Winnie Soler's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Winnie Soler"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Winnie Soler"){
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'wsoler@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Winnie<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}

# Nancy Caccavale's Groups
$csv = import-csv C:\Users\$env:username\"Copy User Groups"\""$userid" groups.csv" | where-object {$_.managedby -eq "Nancy Caccavale"}
$groupname = write-host -separator `n $csv.name
$gmanager = $csv.managedby
if ($gmanager -like "Nancy Caccavale"){
$Mail = $Outlook.CreateItem(0)
$Mail.To = 'ncaccavale@sbasite.com'
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting Nancy<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()
}


Clear-Host
Write-Host 'The script has finished running.'
Write-Host 'If no emails were generated then no authorization is required.'
Write-Host "Press any key to continue..."
cmd /c pause>nul

#End


<# Add this script to make emails more variable based

Get-ADUser -ldapfilter "(displayname=Tiffany Tatar)" -Properties mail, givenname |
Select mail, givenname

Assign variables to their email address and their first name so we can use those in the emails

#>

# Make all the emails variable based

# Eliminate $groupname and $gmanager and have everything pull from $csv.name and $csv.managedby

<#
This is the mail variable. It just puts the name in there instead of the email. If we can get the script to pull their AD info that will change

$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
$Mail.To = $gmanager[0]
$Mail.Subject = "Security Group Access Request - $Displayname"
$Mail.HTMLBody ="$Greeting<br>
<br>
Please approve/deny <b>$Displayname</b> for access to the following group(s):<br>
<br>
$groupname<br>
<br>
Their title is <b>$title</b> and they work in <b>$department</b> for <b>$manager</b>
<br>
<br>
<br>
<br>
$yourname<br>
Help Desk Support Services Specialist<br>
<br>
800.799.4722 x9222 + T<br>
561.989.2957 + F<br>
"
$Mail.Display()

$Sendmail = $Outlook,$Mail

#>

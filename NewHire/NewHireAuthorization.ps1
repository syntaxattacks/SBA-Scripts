function userinput {

$Global:OldUser = Read-Host -Prompt 'Userid of the user you are copying groups from'

while (-not(dsquery user -samid $olduser))
{
    $Global:OldUser = Read-Host -Prompt "$OldUser does not exist. Please enter a valid userid."
}

$Global:newuser = Read-Host -Prompt 'Userid of the user you are copying to'
while (-not(dsquery user -samid $newuser))
{
    $Global:newuser = Read-Host -Prompt "$newuser does not exist. Please enter a valid userid."
}

$Global:NewUserName = (Get-ADUser $newuser -Properties DisplayName |
        Select-Object -Property Displayname |
        Format-Table -HideTableHeaders |
    Out-String).Trim()
    $Global:NewUserTitle = (Get-ADUser $newuser -Properties Title |
        Select-Object -Property Title |
        Format-Table -HideTableHeaders |
    Out-String).Trim()
    $Global:NewUserDepartment = (Get-ADUser $newuser -Properties Department |
        Select-Object -Property Department |
        Format-Table -HideTableHeaders |
    Out-String).Trim()
    $Global:NewUserManager = (Get-ADUser $newuser -Properties Manager |
        Select-Object -Property @{
            n = 'Manager'
            e = {
                $_.Manager -replace '^CN=(.+?),(?:CN|OU).+', '$1'
            }
        } |
        Format-Table -HideTableHeaders |
    Out-String).Trim()
    #These are the variables for the new hire.

   $Global:oldUserName = (Get-ADUser $olduser -Properties DisplayName |
        Select-Object -Property Displayname |
        Format-Table -HideTableHeaders |
        Out-String).Trim()

if (!$newusertitle) {
$Global:NewUserTitle = Read-Host -Prompt 'Please enter the user title'
}
if (!$NewUserDepartment) {
$Global:NewUserDepartment = Read-Host -Prompt 'Please enter the user department'
}
if (!$newusermanager) {
$Global:NewUserManager = Read-Host -Prompt "Please enter the user's manager"
}


    $Global:answer = Read-Host "This will request security groups be copied from $OldUsername to:
    User ID: $newuser
    Name: $newusername
    Title: $newusertitle
    Department: $newuserdepartment
    Manager: $newusermanager
    Is this correct? (Yes or No)"

while("yes","no","y", "n", "Y", "N", "Yes", "No" -notcontains $answer)
{
	$Global:answer = Read-Host "Please enter Yes or No"
}
    }
    # These variables accept the user input.

do{
 userinput   
}
until (($answer -eq 'yes') -or ($answer -eq 'y') -or ($answer -eq 'Y') -or ($answer -eq 'Yes'))
   

    if ( (Get-Date -UFormat %p) -eq 'AM' )  {
        $Greeting = 'Good morning,'
    } #End if
    else {
        $Greeting = 'Good afternoon,'
    } #end else
    # This checks time of day and sets the greeting

    New-Item -ItemType directory -Force -Path I:\"New Hire Logs"\"$newuser"\ -ea SilentlyContinue
    # So we can dump a logfile at the end of the script

    Clear-Host
    # To tidy up the screen from any dialogue of creating the directory

    Write-Host 'Request is processing. Outlook will open emails to request authorization if needed.'
    # We want to make sure the user knows the script is doing its job.

    $Groups = Get-ADPrincipalGroupMembership -Identity $OldUser |
    Get-ADGroup -Properties Name, managedby | 
    Select-Object -Property Name, @{
        n = 'ManagedBy'
        e = {
            $_.ManagedBy -replace '^CN=(.+?),(?:CN|OU).+', '$1'
        }
    } |
    Where-Object -FilterScript {
        $_.managedby -ne ''-and $_.managedby -ne 'Benson Richeme'
    } | 
    Group-Object -Property managedby
    $GroupList = Get-ADPrincipalGroupMembership -Identity $OldUser |
    Get-ADGroup -Properties Name, managedby | 
    Select-Object -Property Name, @{
        n = 'ManagedBy'
        e = {
            $_.ManagedBy -replace '^CN=(.+?),(?:CN|OU).+', '$1'
        }
    } |  
    Where-Object -FilterScript {
        $_.managedby -ne '' -and $_.managedby -ne 'Benson Richeme'
    } | sort ManagedBy 
    # These pull the groups that need approval and groups them by managedby. 
    $OFS = "`t`n"  
  
    foreach ($Group in $Groups)
    {
        $ManagerMail = Get-ADUser -Filter "displayname -like '$($Group.name)'" -Properties Mail |
        Select-Object -Property Mail |
        Format-Table -HideTableHeaders |
        Out-String
        $ManagerName = (Get-ADUser -Filter "displayname -like '$($Group.name)'" -Properties GivenName | 
            Select-Object -Property GivenName |
            Format-Table -HideTableHeaders |
        Out-String).Trim()
        $Groupnames = ($Group.group.name | Out-String).Trim()
        # These set the varialbe for each manager and the groups they own
        if ($Groupnames -like '*Application-Hyperion-Planning*')
        {
            $ManagerMail = 'SManas@sbasite.com'
            $ManagerName = 'Sergio'
        }
        if ($Groupnames -like '*RSMPO*')
        {
            $ManagerMail = 'lcestare@sbasite.com'
        }

        [string]$emailbody = ''
        $Outlook = New-Object -ComObject Outlook.Application
        $Mail = $Outlook.Application.CreateItemFromTemplate('H:\Helpdesk\Scripts\Template.oft')
        $Mail.To = $ManagerMail
        $Mail.Subject = "Security Group Access Request - $NewUserName"
        [string]$Mail.Body = "$Greeting  $ManagerName


Please approve/deny $NewUserName for access to the following group(s): 
 
$Groupnames

Their title is $NewUserTitle and they work in $NewUserDepartment for $NewUserManager"
        $Mail.Display()
    }
    # This is the email that goes to each approver. It uses the variables to fill in relavent information.

    $GroupList | Export-CSV "I:\New Hire Logs\$newuser\$OldUser Groups.csv"
    #This dumps the logfile to your I Drive

   # Clear-Host 
    Write-Host 'The script has completed. The following groups need authorization:' 
    Write-Host
    $GroupList
    Invoke-Item "I:\New Hire Logs\$newuser\$OldUser Groups.csv"
    Write-Host 
    Write-Host  
    Pause
#requires -Version 2
$ErrorActionPreference = 'SilentlyContinue'

function UserInput
{
  $Global:firstname = Read-Host -Prompt 'First Name'
  $Global:lastname = Read-Host -Prompt 'Last Name'
  $Global:fndig = 1
  $Global:newuser = $Global:firstname.substring(0,$fndig) + $Global:lastname
  $Global:manager = Read-Host -Prompt 'Userid of Manager'
  while (-!(dsquery.exe user -samid $Global:manager))
  {
    $Global:manager = Read-Host   -Prompt "$Global:manager is invalid. Please try again."
  }
  $Global:ManagerName = (Get-ADUser $Manager -Properties DisplayName |
    Select-Object -Property Displayname |
    Format-Table -HideTableHeaders |
  Out-String).Trim()
  $Global:ManagerTitle = (Get-ADUser $Manager -Properties Title |
    Select-Object -Property Title |
    Format-Table -HideTableHeaders |
  Out-String).Trim()
  $Global:ManagerDepartment = (Get-ADUser $Manager -Properties Department |
    Select-Object -Property Department |
    Format-Table -HideTableHeaders |
  Out-String).Trim()

  while (dsquery.exe user -samid $newuser) 
  {
    if (dsquery.exe user -name "$Firstname $Lastname")
    {
      Write-Host -Object "User $newuser with name $Firstname $Lastname already exists."
      Pause
      UserInput
    }
    $Global:newuser = $Firstname.substring(0,$fndig++) + $Lastname
    if ($fndig -ge $Firstname.length) 
    {
      break
      Write-Host -Object 'Userid could not be generated based on first name'
      #todo prompt for manual entry here
    }    
  }
  $Global:answer = Read-Host -Prompt "This will create a user with the following information:
    Name: $Firstname $Lastname
    Department: $ManagerDepartment
    Manager: $Managername

    Is this data correct? (Yes or No)
  "
  while('yes', 'no', 'y', 'n', 'Y', 'N', 'Yes', 'No' -notcontains $answer)
  {
    $Global:answer = Read-Host -Prompt 'Please enter Yes or No'
  }
}

function createaccount
{
  new-aduser  `
  -samaccountname $newuser `
  -AccountPassword (ConvertTo-SecureString -AsPlainText 'Temp001' -Force) `
  -name "$Firstname $Lastname" `
  -givenname "$Firstname" `
  -surname "$Lastname" `
  -DisplayName "$Firstname $Lastname" `
  -UserPrincipalName "$newuser@sbasite.com"`
  -Enabled $true `
  -ChangePasswordAtLogon $true `
  -EmailAddress "$newuser@sbasite.com"`
  -Company 'SBA Network Services Inc.'`
  -Path 'OU=HR Onboarding,OU=IT Operations,DC=sbasite,DC=com'`
  -Manager $Manager `
  -Department $ManagerDepartment
  Set-ADUser $newuser -Add @{
    ProxyAddresses = "SMTP:$newuser@sbasite.com", "smtp:$newuser@sbacommunication.mail.onmicrosoft.com"
  } 
  Set-ADUser $newuser -Add @{
    targetAddress = "SMTP:$newuser@sbacommunication.mail.onmicrosoft.com"
  }
  Start-Process -FilePath "\\fl1fs1.sbasite.com\it$\Helpdesk\DirSync\DirSync.exe"
}

function CopyGroups 
{
  $Global:source = Read-Host -Prompt 'Userid of the user you are copying from'
  while (-!(dsquery.exe user -samid $Global:source))
  {
    $Global:source = Read-Host   -Prompt "$Source is invalid. Please try again."
  }
  $CopyFromUser = Get-ADUser $Source -prop MemberOf
  $CopyToUser = Get-ADUser $newuser -prop MemberOf

  $CopyFromUser.MemberOf |
  Where-Object -FilterScript {
    $CopyToUser.MemberOf -notcontains $_
  } |
  Add-ADGroupMember -Member $CopyToUser

  $targetou = Get-ADUser -Identity $Source -Properties distinguishedname, cn |
  Select-Object -Property @{
    n = 'ParentContainer'
    e = {
      $_.distinguishedname -replace '^.+?,(CN|OU.+)', '$1'
    }
  } | 
  Format-Table -HideTableHeaders |
  Out-String

  Get-ADUser $newuser | Move-ADObject -TargetPath "$targetou"
}

function RequestAuth
{
  if ( (Get-Date -UFormat %p) -eq 'AM' )  
  {
    $Greeting = 'Good morning,'
  } #End if
  else 
  {
    $Greeting = 'Good afternoon,'
  } #end else
  # This checks time of day and sets the greeting

  New-Item -ItemType directory -Force -Path I:\"New Hire Logs"\"$newuser"\ -ea SilentlyContinue
  # So we can dump a logfile at the end of the script

  Clear-Host
  # To tidy up the screen from any dialogue of creating the directory

  Write-Host -Object 'Request is processing. Outlook will open emails to request authorization if needed.'
  # We want to make sure the user knows the script is doing its job.

  $Groups = Get-ADPrincipalGroupMembership -Identity $Global:source |
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
  $GroupList = Get-ADPrincipalGroupMembership -Identity $Source |
  Get-ADGroup -Properties Name, managedby | 
  Select-Object -Property Name, @{
    n = 'ManagedBy'
    e = {
      $_.ManagedBy -replace '^CN=(.+?),(?:CN|OU).+', '$1'
    }
  } |
  Where-Object -FilterScript {
    $_.managedby -ne '' -and $_.managedby -ne 'Benson Richeme'
  }
  # These pull the groups that need approval and groups them by managedby. 
  $OFS = "`t`n"  
  
  foreach ($Group in $Groups)
  {
    $ManagerMail = Get-ADUser -Filter "displayname -like '$($Group.name)'" -Properties Mail |
    Select-Object -Property Mail |
    Format-Table -HideTableHeaders |
    Out-String
    $Managername = (Get-ADUser -Filter "displayname -like '$($Group.name)'" -Properties GivenName | 
      Select-Object -Property GivenName |
      Format-Table -HideTableHeaders |
    Out-String).Trim()
    $Groupnames = ($Group.group.name | Out-String).Trim()
    # These set the varialbe for each manager and the groups they own
    if ($Groupnames -like '*Application-Hyperion-Planning*')
    {
      $ManagerMail = 'SManas@sbasite.com'
      $Managername = 'Sergio'
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
    [string]$Mail.Body = "$Greeting  $Managername


      Please approve/deny $NewUserName for access to the following group(s): 
 
      $Groupnames

    Their title is $NewUserTitle and they work in $NewUserDepartment for $NewUserManager"
    $Mail.Display()
  }
  # This is the email that goes to each approver. It uses the variables to fill in relavent information.

  $GroupList | Out-File -FilePath I:\"New Hire Logs"\"$newuser"\""$OldUser" Groups.log"
  #This dumps the logfile to your I Drive

  Clear-Host 
  Write-Host -Object 'The script has completed. The following groups need authorization:' 
  Write-Host
  $GroupList
  Write-Host 
  Write-Host  
  Pause
}

do
{
  UserInput
}
until (($answer -eq 'yes') -or ($answer -eq 'y') -or ($answer -eq 'Y') -or ($answer -eq 'Yes'))

createaccount

$Global:answer = Read-Host -Prompt "The Process has completed. The user is ready.
The UserID assigned is $newuser. Would you like to copy groups? (Yes or No)"

while('yes', 'no', 'y', 'n', 'Y', 'N', 'Yes', 'No' -notcontains $answer)
{
  $Global:answer = Read-Host -Prompt 'Please enter Yes or No'
}
    
if ('yes', 'y', 'Y', 'Yes' -contains $answer)
{
  CopyGroups
  RequestAuth 
}

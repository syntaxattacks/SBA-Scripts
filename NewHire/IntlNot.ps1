$UserID = Read-Host 'Please enter the UserID'
$UserName = Get-ADUser $UserID -Properties DisplayName | Select Displayname |
  Format-Table -HideTableHeaders | Out-String
$Usermail = Get-ADUser $UserID -Properties UserPrincipalName | Select UserPrincipalName |
  Format-Table -HideTableHeaders | Out-String
$UserDepartment = Get-ADUser $UserID -Properties Department | Select Department |
  Format-Table -HideTableHeaders | Out-String

if ( (Get-Date -UFormat %p) -eq "AM" ) { 
  $Greeting = "Good morning," 
  } #End if
else {
  $Greeting = "Good afternoon,"
  } #end else
    # This checks time of day and sets the greeting

  if (dsquery user -samid $Userid){"$UserID validated in Active Directory."}
  else {"$Userid is not a recognized UserID."
  Pause
  Exit}

Write-Output  "This will generate Notification for $Username."
Pause


$Outlook = New-Object -ComObject Outlook.Application
  $Mail = $Outlook.Application.CreateItemFromTemplate("H:\Helpdesk\Scripts\Template.oft")
  $Mail.To = "internationalnewhires@sbasite.com"
  $Mail.Subject = "New International Hire"
  $Mail.HTMLBody ="$Greeting<br> <br>
  A new user account has been created for <b>$username</b> in <b>$userdepartment</b><br><br>
  Their information is as follows:<br><br>

  $usermail
  <br><br>
  Please contact the SBA Help Desk if you require additional assistance
"
  $Mail.Display()
  

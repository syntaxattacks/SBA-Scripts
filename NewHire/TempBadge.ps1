$NewUser = Read-Host 'Userid of the Temp needing badge access'
$NewUserName = Get-ADUser $NewUser -Properties DisplayName | Select Displayname |
  Format-Table -HideTableHeaders | Out-String
$NewUseremail = Get-ADUser $NewUser -Properties UserPrincipalName | Select UserPrincipalName |
  Format-Table -HideTableHeaders | Out-String

if ( (Get-Date -UFormat %p) -eq "AM" ) { 
  $Greeting = "Good morning," 
  } #End if
else {
  $Greeting = "Good afternoon,"
  } #end else
    # This checks time of day and sets the greeting


$Outlook = New-Object -ComObject Outlook.Application
  $Mail = $Outlook.Application.CreateItemFromTemplate("H:\Helpdesk\Scripts\Template.oft")
  $Mail.To = "DWhaley@sbasite.com; lbowen@sbasite.com; JLouis@sbasite.com; SEstevez@sbasite.com"
  $Mail.Subject = "Temp Hire Badge Access - $newuser"
  $Mail.HTMLBody ="$Greeting<br> <br>
 <b>$NewUsername</b> is a new temp hire currently being processed. Their email address is <b>$newuseremail</b>.<br><br>
 This information is being provided to you for the badge system.<br><br>
 "
  $Mail.Display()
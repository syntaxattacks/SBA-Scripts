if ( (Get-Date -UFormat %p) -eq "AM" ) { 
  $Greeting = "Good morning," 
  } #End if
else {
  $Greeting = "Good afternoon,"
}

[System.Windows.Forms.Clipboard]::GetText() | out-file c:\users\dhann\inventory.txt

$Outlook = New-Object -ComObject Outlook.Application
  $Mail = $Outlook.Application.CreateItemFromTemplate("H:\Helpdesk\Scripts\Template.oft")
  $Mail.To = "ithelpdesk@sbasite.com"
  $Mail.Subject = "Equipment Deployment Request"
  $Mail.HTMLBody ="Please see below for requested equipment.<br><br><br><br><br><br>"
  $Mail.Display()
  

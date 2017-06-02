if ( (Get-Date -UFormat %p) -eq "AM" ) { 
  $Greeting = "Good morning," 
  } #End if
else {
  $Greeting = "Good afternoon,"
}

[System.Windows.Forms.Clipboard]::GetText() | out-file c:\users\dhann\inventory.txt

$Outlook = New-Object -ComObject Outlook.Application
  $Mail = $Outlook.CreateItem(0)
  $Mail.To = "lcestare@sbasite.com;"
  $Mail.Subject = "Weekly Termination Report"
  $Mail.HTMLBody =""

  
  $Mail.Display()
  

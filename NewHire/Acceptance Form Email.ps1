$userid = 
    Read-Host 'Userid of the New Hire'
$FirstName = 
    get-aduser $userid |
    select name |
    Format-Table -HideTableHeaders |
    out-string
$UserMail = 
    get-aduser $userid -properties mail |
    select mail |
    Format-Table -HideTableHeaders |
    out-string
$Myname = 
    Get-ADUser $env:username |
    Select name |
    Format-Table -HideTableHeaders |
    out-string
$File = 
    "I:\My Checklists\Equipment Acceptance Forms\$userid Acceptance Form.pdf"
if ( (Get-Date -UFormat %p) -eq "AM" ) 
    {$Greeting = "Good morning,"}
        else 
    {$Greeting = "Good afternoon,"} 




$Outlook = New-Object -ComObject Outlook.Application
    $Mail = $Outlook.Application.CreateItemFromTemplate("H:\Helpdesk\Scripts\Template.oft")
    $Mail.To = $UserMail
    $Mail.Subject = "Equipment Acceptance Form"
    $Mail.Attachments.Add($File)
    $Mail.HTMLBody ="$Greeting $FirstName<br> 
    <br>
    <br>
    Please sign and return the attached Equipment Acceptance Form and retun it to me <u><b>today</b></u>
     so we can verify our inventory records.
    <br><br>
    Thank you,
    <br><br>
    "
    $Mail.Display()
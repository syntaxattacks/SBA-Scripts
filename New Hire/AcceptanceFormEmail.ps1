$userid = 
    Read-Host 'Userid of the New Hire'
$FirstName = 
    get-aduser $userid |
    select givenname |
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
    "I:\AcceptanceForm.pdf"
if ( (Get-Date -UFormat %p) -eq "AM" ) 
    {$Greeting = "Good morning,"}
        else 
    {$Greeting = "Good afternoon,"} 

$Outlook = New-Object -ComObject Outlook.Application
    $Mail = $Outlook.CreateItem(0)
    $Mail.To = $UserMail
    $Mail.Subject = "Welcome to SBA"
    $Mail.Attachments.Add($File)
    $Mail.HTMLBody ="$Greeting $FirstName<br> 
    <br>
    <br>
    Welcome to SBA!<br>
    If you are prompted to enter a Bitlocker Pin when boting your computer you can enter '<b>password</b>' and you will
    be able to log in.<br>
    Please sign and return the attached Equipment Acceptance Form and retun it to me <u><b>today</b></u>
     so we can verify our inventory records.
    <br><br>
    <br><br><br>
    Thank you, <br>
    $Myname<br>
    Help Desk Support Services Specialist<br>
    <br>    
    800.799.4722 x9222 + T<br>
    561.989.2957 + F<br>
    "
    $Mail.Display()
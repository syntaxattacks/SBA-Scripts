$userid = 
    Read-Host 'Userid of the new hire'
$NewHireName = 
    get-aduser $userid |
    select name |
    Format-Table -HideTableHeaders | 
    out-string   
$NewHireMail = 
    get-aduser $userid -properties mail |
    select mail |
    Format-Table -HideTableHeaders |
    out-string
$manager = 
    (get-aduser (get-aduser $userid -Properties manager).manager).samaccountName
$managermail = 
    get-aduser $manager -properties mail |
    select mail |
    Format-Table -HideTableHeaders |
    out-string
$managername = 
    get-aduser $manager -properties givenname |
    select givenname |
    Format-Table -HideTableHeaders |
    out-string
$Myname = 
    Get-ADUser $env:username |
    Select name |
    Format-Table -HideTableHeaders |
    out-string
if ( (Get-Date -UFormat %p) -eq "AM" ) {
    $Greeting = "Good morning," 
    } #End if
    else {
    $Greeting = "Good afternoon,"
    }

$Outlook = New-Object -ComObject Outlook.Application
    $Mail = $Outlook.CreateItem(0)
    $Mail.To = $managermail
    $Mail.Subject = "New Hire Information"
    $Mail.HTMLBody ="$Greeting $managername<br> 
    <br>
    <br>
    <br>
    $newhirename has been configured in our system. Their information is as follows:
    <br>
    <br>Username: $userid
    <br>Password: Temp001
    <br>Email: $NewHireMail
    <br>
    <br>If they are prompted for a BitLocker Pin when booting the computer it is '<b>password</b>'.
    <br>
    <br>
    <br>If you have any questions about this new hire please let me know. Thank you.
    <br>
    <br>
    $Myname<br>
    Help Desk Support Services Specialist<br>
    <br>    
    800.799.4722 x9222 + T<br>
    561.989.2957 + F<br>
    "
    $Mail.Display()
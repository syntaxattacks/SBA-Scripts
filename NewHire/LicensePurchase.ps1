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
    get-aduser $manager -properties telephoneNumber |
    select telephoneNumber |
    Format-Table -HideTableHeaders |
    out-string
$managername = 
    get-aduser $manager |
    select name |
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
    $Mail = $Outlook.Application.CreateItemFromTemplate("H:\Helpdesk\Scripts\Template.oft")
    $Mail.To = 'mbalok@sbasite.com'
    $Mail.Subject = "License Purchase Request"
    $Mail.HTMLBody =" 
    <br>    <br>    <br>     <br>
    Type of License:  
    <br>
    Name: $NewHireName
    <br>
    Approver (Name & #): $ManagerName; $Managermail
    <br>
    GL Code:  
    <br>
    Ticket #:   
    "
    $Mail.Display()
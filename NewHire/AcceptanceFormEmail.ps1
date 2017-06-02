$User = 
    Read-Host 'Userid of the New Hire'
$FirstName = 
    get-aduser $User |
    select givenname |
    Format-Table -HideTableHeaders |
    out-string
$UserMail = 
    get-aduser $User -properties mail |
    select mail |
    Format-Table -HideTableHeaders |
    out-string
$Myname = 
    Get-ADUser $env:username |
    Select name |
    Format-Table -HideTableHeaders |
    out-string
$File = 
    "I:\New Hire Logs\$User\$User Acceptance Form $Date.pdf"
if ( (Get-Date -UFormat %p) -eq "AM" ) 
    {$Greeting = "Good morning,"}
        else 
    {$Greeting = "Good afternoon,"} 

mkdir I:\"New Hire Logs"\$User\  -EA SilentlyContinue
Move-Item "I:\AcceptanceForm.pdf" I:\"New Hire Logs"\$User\
Rename-Item "I:\New Hire Logs\$User\AcceptanceForm.pdf" -NewName "$User Acceptance Form $Date.pdf"

Invoke-Item I:\"New Hire Logs"\$User\

<#
$Outlook = New-Object -ComObject Outlook.Application
    $Mail = $Outlook.Application.CreateItemFromTemplate("H:\Helpdesk\Scripts\Template.oft")
    $Mail.To = $UserMail
    $Mail.Subject = "Your Equipment Acceptance Form"
    $Mail.Attachments.Add($File)
    $Mail.Importance = 2
    $Mail.HTMLBody ="$Greeting $FirstName<br> 
    <br>
    <br>
    Please sign and return the attached Equipment Acceptance Form and return it to me <u><b>today</b></u>
    or on the day you receive your equipment so we can verify our inventory records.
    <br><br>
    Thank  you,
    <br><br>
    "
    $Mail.Display()

    #>
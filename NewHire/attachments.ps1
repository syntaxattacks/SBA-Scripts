$User = Read-Host 'Please enter the UserID'
$Date = Get-Date -Format "MM-dd-yyyy"
$File = "I:\New Hire Logs\$User\$User Checklist.pdf"
$Name = 
    get-aduser $User |
    select name |
    Format-Table -HideTableHeaders |
    out-string

mkdir I:\"New Hire Logs"\$User\  -EA SilentlyContinue
If (test-path $file) {Remove-Item $File}
Move-Item 'I:\Checklist.pdf I:\New Hire Logs\$User\'
Rename-Item 'I:\New Hire Logs\$User\Checklist.pdf' -NewName "$User Checklist.pdf"

Invoke-Item I:\"New Hire Logs"\$User\
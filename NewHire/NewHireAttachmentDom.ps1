$ticket = Read-Host 'Ticket Number'
$name = Read-Host 'Name of User'

New-Item -ItemType Directory -Force -Path "\\fl1fs1\it$\Helpdesk\New Hires\Domestics\00$ticket - $Name"

Copy-Item "\\fl1fs1\it$\IT_Heat_Attachments\00$ticket\*" "\\fl1fs1\it$\Helpdesk\New Hires\Domestics\00$ticket - $Name"

Invoke-Item "\\fl1fs1\it$\Helpdesk\New Hires\Domestics\00$ticket - $Name"


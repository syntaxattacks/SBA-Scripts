function UserInput{
$userid = Read-Host 'Username'
while (-not(dsquery.exe user -samid $Userid))
{
   $Global:UserID = Read-Host   "$UserID is invalid. Please try again." 
}

$oldpc = Read-Host 'Old PC Name/IP Address'
while (!(Test-Connection -Cn $OldPC -BufferSize 16 -Count 1 -ea 0 -quiet))
{
  $Global:OldPC = Read-Host   "$OldPC is Offline. Please try again."
}

$newpc = Read-Host 'New PC Name/IP Address'
while (!(Test-Connection -Cn $NewPC -BufferSize 16 -Count 1 -ea 0 -quiet))
{
  $Global:NewPC = Read-Host   "$NewPC is Offline. Please try again."

  }
  $Global:UserIDName = (Get-ADUser $UserID -Properties DisplayName |
        Select-Object -Property Displayname |
        Format-Table -HideTableHeaders |
    Out-String).Trim()
    $Global:UserIDTitle = (Get-ADUser $UserID -Properties Title |
        Select-Object -Property Title |
        Format-Table -HideTableHeaders |
    Out-String).Trim()
    $Global:UserIDDepartment = (Get-ADUser $UserID -Properties Department |
        Select-Object -Property Department |
        Format-Table -HideTableHeaders |
    Out-String).Trim()
    $Global:UserIDManager = (Get-ADUser $UserID -Properties Manager |
        Select-Object -Property @{
            n = 'Manager'
            e = {
                $_.Manager -replace '^CN=(.+?),(?:CN|OU).+', '$1'   
}
}
UserInput

$Global:answer = Read-Host "This will cop the data for  $OldPC to $NewPC for:
    User ID: $UserID
    Name: $UserIDname
    Title: $UserIDtitle
    Department: $UserIDdepartment
    Manager: $UserIDmanager
    Is this correct? (Yes or No)"

while("yes","no","y", "n", "Y", "N", "Yes", "No" -notcontains $answer)
{
	$Global:answer = Read-Host "Please enter Yes or No"
}
    }
    # These variables accept the user input.

do{
 UserInput   
}
until (($answer -eq 'yes') -or ($answer -eq 'y') -or ($answer -eq 'Y') -or ($answer -eq 'Yes'))
    



$oldlog = I:\"Transfer Logs"\"$userid"\""$oldpc" Software.log"
$newlog = I:\"Transfer Logs"\"$userid"\""$newpc" Software.log"
$CurrentUser = @(Get-WmiObject -ComputerName $OldPC -Namespace root\cimv2 -Class Win32_ComputerSystem)[0].UserName;
$FindDrive = gwmi win32_mappedlogicaldisk -ComputerName $OldPC |
  Select Name, ProviderName | out-string
$Export = gwmi win32_mappedlogicaldisk -ComputerName $OldPC |
  Select Name, ProviderName  |
  Out-file I:\"Transfer Logs"\"$userid"\""$OldPC" Mapped Drives.log"
$Printers = Get-WmiObject win32_printer -ComputerName $OldPC |
  select Name,SystemName,ShareName | Format-List | Out-String

New-Item -ItemType directory -Force -Path I:\"Transfer Logs"\"$userid"\
  Clear-Host



if(!(Test-Connection -Cn $OldPC -BufferSize 16 -Count 1 -ea 0 -quiet)) {
  Write-Host "$OldPC is offline"
  Pause
  Exit
  }
  Else {Write-host "$OldPC is online"}
  if(!(Test-Connection -Cn $NewPC -BufferSize 16 -Count 1 -ea 0 -quiet)) {
  Write-Host "$NewPC is offline"
  Pause
  Exit
  }
  Else {Write-host "$NewPC is online"}

Write-Host "Collecting Mapped Printers..."
Get-WmiObject win32_printer -ComputerName $OldPC |
select Name,SystemName,ShareName |
# Line 24 gets the list of printers for the PC you specified and 25 filters out anything we don't need.

Out-file I:\"Transfer Logs"\"$userid"\""$OldPC" Mapped Printers.log"
# Creates a log for you to review


Write-Host "Gathering Mapped Drives..."
$Export

Write-Host
Write-Host
Write-Host Gathering Information on installed software.
Write-Host
write-host This may take a few minutes...
# This script will take a while. I wanted there to be some type of confirmation the user did everything right and the script is working

Get-WmiObject -Class Win32_Product -ComputerName $oldpc |
Select-Object -Property Name | 
Out-file I:\"Transfer Logs"\"$userid"\""$oldpc" Software.log"
# This generates the software log from the old computer and puts the log where it needs to be

Get-WmiObject -Class Win32_Product -ComputerName $newpc | 
Select-Object -Property Name |
Out-file I:\"Transfer Logs"\"$userid"\""$newpc" Software.log"
# This generates the software log from the new computer and puts the log where it needs to be

Compare-Object -ReferenceObject (Get-Content I:\"Transfer Logs"\"$userid"\""$oldpc" Software.log") -DifferenceObject (Get-Content I:\"Transfer Logs"\"$userid"\""$newpc" Software.log") | 
Where-Object { $_.SideIndicator -eq '<=' }  |
select * -excludeproperty SideIndicator |
sort InputObject |
Out-file I:\"Transfer Logs"\"$userid"\"Software Audit.log"


Invoke-Item I:\"Transfer Logs"\"$userid"\""$OldPC" Mapped Drives.log"
invoke-item I:\"Transfer Logs"\"$userid"\"Software Audit.log"
Invoke-Item I:\"Transfer Logs"\"$userid"\""$OldPC" Mapped Printers.log"

$userid = Read-Host 'Username'
$oldpc = Read-Host 'Old PC Name/IP Address'
$newpc = Read-Host 'New PC Name/IP Address'
$oldlog = C:\Users\$env:username\"Transfer Logs"\"$userid"\""$oldpc" Software.log"
$newlog = C:\Users\$env:username\"Transfer Logs"\"$userid"\""$newpc" Software.log"
# Setting variables. I set $newpcaudit and $oldpcaudit to save space when we run the compare-object command

New-Item -ItemType directory -Force -Path  C:\Users\$env:username\"Transfer Logs"\"$userid"\
# This is going to create the folder in your user directory that the logfile will dump to. If it's not there then the logfile won't generate.
# I've tagged it with the -Force trigger so it doesn't generate any errors if the folder is already there.

clear-host
# To keep the screen nice and tidy
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
Write-Host
Write-Host
Write-Host Gathering Information on installed software.
Write-Host
write-host This may take a few minutes...
# This script will take a while. I wanted there to be some type of confirmation the user did everything right and the script is working

Get-WmiObject -Class Win32_Product -ComputerName $oldpc |
Select-Object -Property Name | 
Out-file C:\Users\$env:username\"Transfer Logs"\"$userid"\""$oldpc" Software.log"
# This generates the software log from the old computer and puts the log where it needs to be

Get-WmiObject -Class Win32_Product -ComputerName $newpc | 
Select-Object -Property Name |
Out-file C:\Users\$env:username\"Transfer Logs"\"$userid"\""$newpc" Software.log"
# This generates the software log from the new computer and puts the log where it needs to be

Compare-Object -ReferenceObject (Get-Content C:\Users\$env:username\"Transfer Logs"\"$userid"\""$oldpc" Software.log") -DifferenceObject (Get-Content C:\Users\$env:username\"Transfer Logs"\"$userid"\""$newpc" Software.log") | 
Where-Object { $_.SideIndicator -eq '<=' -and $_.Inputobject -notlike "Citrix*" -and $_.Inputobject -notlike "*.net*" -and 
  $_.Inputobject -notlike 'Citrix*' -and $_.Inputobject -notlike "*Excel*"-and $_.Inputobject -notlike "*Exchange*"-and $_.Inputobject -notlike "*mui*" -and
  $_.Inputobject -notlike "*C++*" -and $_.Inputobject -notlike "*Windows Assessment*" -and $_.Inputobject -notlike "Citrix*" -and $_.Inputobject -notlike "CCC*" `
  -and $_.Inputobject -notlike "*Catalyst*" -and $_.Inputobject -notlike "Google Update*" -and $_.Inputobject -notlike "Windows Live*" `
  -and $_.Inputobject -notlike "Roxio*" -and $_.Inputobject -notlike "Photoshow*" -and $_.Inputobject -notlike "Powerdvd*" -and $_.Inputobject -notlike "*visio viewer*"`
  -and $_.Inputobject -notlike "*cineplayer*" -and $_.Inputobject -notlike "*msxml*" -and $_.Inputobject -notlike "*reportviewer*" -and $_.Inputobject -notlike "*report viewer*"`
  -and $_.Inputobject -notlike "*microsoft online services*" -and $_.Inputobject -notlike "*office proof*" -and $_.Inputobject -notlike "*file validation*" `
  -and $_.Inputobject -notlike "RBVirtualFolder64Inst*" -and $_.Inputobject -notlike "*java*" -and $_.Inputobject -notlike "*lumension*" `
  -and $_.Inputobject -notlike "*error reporting*" -and $_.Inputobject -notlike "*adobe flash*" -and $_.Inputobject -notlike "adobe reader*" `
  -and $_.Inputobject -notlike "*webex*" -and $_.Inputobject -notlike "*components*" -and $_.Inputobject -notlike "*intel*" -and $_.Inputobject -notlike "*dameware*"`
  -and $_.Inputobject -notlike "*fileopen*" -and $_.Inputobject -notlike "*dwg trueview*" 
}  |
select @{Name="Software Missing From New PC";Expression={$_.Inputobject}} -excludeproperty SideIndicator |
sort InputObject |
Out-file C:\Users\$env:username\"Transfer Logs"\"$userid"\"Software Audit.log"
# This takes the two separate logs and compares them, then shows only what was on the old computer that is not on the new

invoke-item C:\Users\$env:username\"Transfer Logs"\"$userid"\"Software Audit.log"
# Pulls up the log for your viewing pleasure



# End
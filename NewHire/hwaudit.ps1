$PC = read-host -prompt "Please enter the machine name: "  

clear-host

$colItems = get-wmiobject -class "Win32_ComputerSystem" -namespace "root\CIMV2" -computername $PC




foreach ($objItem in $colItems){
write-host "System Name: " $PC

foreach ($objItem in $colItems){
write-host "Model: " $objItem.Model
$displayGB = [math]::round($objItem.TotalPhysicalMemory/1024/1024/1024, 0)
write-host "Total Physical Memory: " $displayGB "GB"
}


}
$disk = ([wmi]"\\$PC\root\cimv2:Win32_logicalDisk.DeviceID='c:'")
"C: has {0:#.0} GB free of {1:#.0} GB Total" -f ($disk.FreeSpace/1GB),($disk.Size/1GB) | write-output

Pause
$list = Get-ChildItem \\fl1image3\gpo$\Computer | select-object name | out-string -stream

foreach ($file in $list) {
Get-Content \\fl1image3\gpo$\Computer\$file | Select -last 16 
#write-host $file
#write-host This is a space
#

}
export-csv "c:\users\dhann\infolistpc.csv"
$file = import-csv i:\pclist.csv


foreach ($row in $file) {
Get-WmiObject -Class Win32_ComputerSystem -ComputerName $row.name |
    Select-Object Manufacturer,Model,Username, Name >> c:\users\dhann\nextlog.txt
 }
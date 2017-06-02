$source = read-host "Userid of the user you are transferring from"
$newuser = read-host "Userid of the user you are transferring to"
$user = get-aduser $source

$User = Get-ADUser -LDAPFilter "(sAMAccountName=$source)"
If ($User -eq $Null) {
"$source does not exist in AD"
pause
exit
}
$User = Get-ADUser -LDAPFilter "(sAMAccountName=$newuser)"
If ($User -eq $Null) {
"$source does not exist in AD"
pause
exit
}


$CopyFromUser = Get-ADUser $source -prop MemberOf
$CopyToUser = Get-ADUser $newuser -prop MemberOf

$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Member $CopyToUser

$targetou = Get-ADUser -Identity $source -Properties distinguishedname,cn |
    select @{n='ParentContainer';e={$_.distinguishedname -replace '^.+?,(CN|OU.+)','$1'}} | 
    ft -HideTableHeaders | out-string

Get-ADUser $newuser | Move-ADObject -TargetPath "$targetou"

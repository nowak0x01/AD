$groups = Get-NetGroup | Select-Object -ExpandProperty samaccountname

$permissions = @(
    "GenericAll",
    "GenericWrite",
    "WriteOwner",
    "WriteDACL",
    "AllExtendedRights",
    "ForceChangePassword",
    "Self"
)

foreach ($group in $groups) {
    Write-Host "[+] Group: $group [+]"
    
    foreach ($permission in $permissions) {
        Write-Host "[#] Permission: $permission [#]"
        
        Get-ObjectAcl -Identity $group | Where-Object {$_.ActiveDirectoryRights -eq $permission} | Select-Object -ExpandProperty SecurityIdentifier | ConvertFrom-SID
        Write-Host "`n------------------------------------------`n"
    }
}

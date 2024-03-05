Get-NetGroup | ForEach-Object {
    Write-Host "[#] Group: $($_.samaccountname) [#]"
    if ($groupInfo = Get-NetGroup $_.samaccountname) {
        if ($groupInfo.member) {
            $groupInfo.member -replace '^CN=([^,]+).+$','$1' | ForEach-Object {
                Write-Host "User: $_"
            }
        } else {
            Write-Host "No members found."
        }
    } else {
        Write-Host "Failed to retrieve group information."
    }
    Write-Host "`n--------------------------------------------`n"
}

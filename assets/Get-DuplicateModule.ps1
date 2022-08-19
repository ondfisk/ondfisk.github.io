Get-InstalledModule | ForEach-Object {
    $latestVersion = $PSItem.Version

    Write-Host "$($PSItem.Name) - $($PSItem.Version)" -ForegroundColor Green

    Get-InstalledModule $PSItem.Name -AllVersions | 
    Where-Object Version -NE $latestVersion | 
    ForEach-Object {
        Write-Host "- $($PSItem.Name) - $($PSItem.Version)" -ForegroundColor Magenta
    }
}

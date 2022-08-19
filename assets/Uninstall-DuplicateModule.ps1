Get-InstalledModule | ForEach-Object {
    $latestVersion = $PSItem.Version

    Write-Host "$($PSItem.Name) - $($PSItem.Version)" -ForegroundColor Green

    Get-InstalledModule $PSItem.Name -AllVersions | 
    Where-Object Version -NE $latestVersion | 
    ForEach-Object {
        Write-Host "- Uninstalling version $($PSItem.Version)..." -ForegroundColor Magenta -NoNewline
        $PSItem | Uninstall-Module -Force
        Write-Host "done"
    }
}

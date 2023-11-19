---
layout: post
title: Removing Duplicate PowerShell modules
date: 2020-01-07 18:05:04 +0100
categories: powershell
permalink: /removing-duplicate-powershell-modules/
---

Sometimes  installing or updating PowerShell modules will result in duplications where more than one version of the same module is installed.

This is typically not a problem but for things like Desired State Configuration (DSC) this can be an issue as DSC requires that you either specify a specific version or only have one version installed.

## Solution

To remedy this problem here's a set of scripts:

### Get Duplicate Modules

```powershell
Get-InstalledModule | ForEach-Object {
    $latestVersion = $PSItem.Version

    Write-Host "$($PSItem.Name) - $($PSItem.Version)" -ForegroundColor Green

    Get-InstalledModule $PSItem.Name -AllVersions |
    Where-Object Version -NE $latestVersion |
    ForEach-Object {
        Write-Host "- $($PSItem.Name) - $($PSItem.Version)" -ForegroundColor Magenta
    }
}
```

![Get-DuplicateModule.ps1 sample output](/assets/get-duplicatemodule-sample-output.png "Get-DuplicateModule.ps1 sample output")
*Get-DuplicateModule.ps1 sample output*

### Uninstall Duplicate Modules

```powershell
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
```

![Uninstall-DuplicateModule.ps1 sample output](/assets/uninstall-duplicatemodule-sample-output.png "Uninstall-DuplicateModule.ps1 sample output")
*Uninstall-DuplicateModule.ps1 sample output*

## Notes

- The `-AllVersions` switch of `Get-InstalledModule` is only available when specifying a specific module, thus these scripts suffer from the [*N+1 Query Problem*](https://www.sitepoint.com/silver-bullet-n1-problem/).

- Inspired by <http://sharepointjack.com/2017/powershell-script-to-remove-duplicate-old-modules/>.

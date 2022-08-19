---
layout: post
title: "Register Missing Azure Resource Providers"
date: 2020-03-16 09:15:00 +0100
categories: azure powershell
permalink: /register-missing-azure-resource-providers/
---

When creating a new Azure subscriptions chances are it will not have all the resource providers you want registered (enabled).

We often choose to register all the *Microsoft* resource providers (not *Classic*) by default.

## Get-MissingProvider.ps1

This script lists the missing providers:

```powershell
Get-AzResourceProvider -ListAvailable |
    Where-Object ProviderNameSpace -match "Microsoft" |
    Where-Object ProviderNameSpace -notmatch "Classic" |
    Where-Object RegistrationState -eq "NotRegistered" |
    Select-Object ProviderNamespace, RegistrationState, Locations
```

Download: [Get-MissingProvider.ps1](/assets/Get-MissingProvider.ps1)

## Register-MissingProvider.ps1

This script registers the missing providers:

```powershell
Get-AzResourceProvider -ListAvailable |
    Where-Object ProviderNameSpace -match "Microsoft" |
    Where-Object ProviderNameSpace -notmatch "Classic" |
    Where-Object RegistrationState -eq "NotRegistered" |
    Register-AzResourceProvider
```

Download: [Register-MissingProvider.ps1](/assets/Register-MissingProvider.ps1)

**Note**: You have to be *owner* of the subscription to do this.

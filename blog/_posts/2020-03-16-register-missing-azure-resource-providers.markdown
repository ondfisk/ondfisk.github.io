---
layout: post
title: Register Missing Azure Resource Providers
author: Rasmus Lystrøm
date: 2020-03-16 09:15:00 +0100
updated: 2023-05-04
update_message: to include AZ CLI commands
categories: azure
permalink: /register-missing-azure-resource-providers/
excerpt_separator: <!--more-->
type: blog
---

When creating a new Azure subscriptions chances are it will not have all the resource providers you want registered (enabled).

We often choose to register all the *Microsoft* resource providers (not *Classic*) by default.

<!--more-->

## Get Missing Providers

This command lists the missing providers:

```bash
az provider list --query "[?starts_with(namespace, 'Microsoft.') && (!(contains(namespace, 'Classic'))) && registrationState=='NotRegistered']" --output table
```

```powershell
Get-AzResourceProvider -ListAvailable |
    Where-Object ProviderNameSpace -match "Microsoft" |
    Where-Object ProviderNameSpace -notmatch "Classic" |
    Where-Object RegistrationState -eq "NotRegistered" |
    Select-Object ProviderNamespace, RegistrationState, Locations
```

## Register Missing Providers

This command registers the missing providers:

```bash
az provider list --query "[?starts_with(namespace, 'Microsoft.') && (!(contains(namespace, 'Classic'))) && registrationState=='NotRegistered'].namespace" --output tsv | xargs -L1 az provider register --namespace
```

```powershell
Get-AzResourceProvider -ListAvailable |
    Where-Object ProviderNameSpace -match "Microsoft" |
    Where-Object ProviderNameSpace -notmatch "Classic" |
    Where-Object RegistrationState -eq "NotRegistered" |
    Register-AzResourceProvider
```

**Note**: You have to be *owner* of the subscription to do this.

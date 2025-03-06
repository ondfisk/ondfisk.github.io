---
layout: post
title: Find Azure Resources By Tag
author: Rasmus Lystrøm
date: 2019-06-15 10:27:44 +0200
categories: azure
permalink: find-azure-resources-by-tag/
excerpt_separator: <!--more-->
type: blog
---

Now that you don't care about resource names in Azure any more. You have decided to tag all resource groups and resources with an appropriate set of tags:

<!--more-->

| Tag Name | Tag Value |
| --- | --- |
| Environment | Development / Test / Production |
| Cost Center | [number] |
| Owner | [email-address] |

Below are a number of options for both PowerShell and the Azure CLI.

## PowerShell

```powershell
# Get resource groups by tag(s)
Get-AzResourceGroup -Tag @{ "Owner" = "me" ; "Environment" = "Production" } | Format-Table

# Get resource group by name and list tags
Get-AzResourceGroup "<name>"

# Get resources by name
Get-AzResource -Name <name> | Format-Table

# Get resources by tag
Get-AzResource -TagName "Environment" -TagValue "Production"

# Get resources by tag(s)
Get-AzResource -Tag @{ "Owner" = "me" ; "Environment" = "Production" }

# Get resources by tag name
Get-AzResource -TagName "Environment"

# Get resources by tag value
Get-AzResource -TagValue "Production"

# Get resources by name and list tags
Get-AzResource -Name "<name>" | Select-Object Name, ResourceGroup, Location, Tags | Format-List
```

## Azure CLI

```bash
# Get resource groups by tag
az group list --tag 'Environment=Production'

# Get resource group by name and list tags
az group show --name '<name>'

# Get resources by name
az resource list --name <name> --output table

# Get resources by tag
az resource list --tag 'Environment=Production'

# Get resource by name and list tags
az resource list --name '<name>'
```

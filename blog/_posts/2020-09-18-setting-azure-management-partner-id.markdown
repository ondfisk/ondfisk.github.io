---
layout: post
title: "Setting Azure Management Partner Id"
date: 2020-09-18 10:28:00 +0200
categories: azure powershell
permalink: /setting-azure-management-partner-id/
---

If you are a Microsoft partner or if you are working with a Microsoft partner, a request to set the management partner id for each subscription sometimes comes up.

This would typically require you to log in to the [Azure Portal](https://portal.azure.com/), find the subscription and the *Partner Information* settings:

![Setting Azure Management Partner Id in the Azure Portal](/assets/set-azure-management-partner-id.png "Setting Azure Management Partner Id in the Azure Portal")
*Setting Azure Management Partner Id in the Azure Portal*

This is a tedious process especially if you have many subscriptions.

## Solution

Here is a script which will set the partner id for all subscriptions in a specific Azure AD tenant (or all your subscriptions):

```powershell
[CmdLetBinding()]
param(
    [string]
    $TenantId,

    [Parameter(Mandatory = $true)]
    [string]
    $PartnerId
)

if (-not (Get-InstalledModule -Name "Az.ManagementPartner")) {
    Install-Module -Name "Az.ManagementPartner" -Force
}

$subscriptions = Get-AzSubscription

if ($TenantId) {
    $subscriptions = $subscriptions | Where-Object TenantId -eq $TenantId
}

$subscriptions | ForEach-Object {
    $subscription = $PSItem | Set-AzContext | Select-Object -ExpandProperty Subscription | Select-Object -ExpandProperty Name
    $existing = Get-AzManagementPartner -ErrorAction SilentlyContinue | Select-Object -ExpandProperty PartnerId
    if (-not $existing) {
        Write-Verbose -Message "Setting partner id on subscription: $subscription..."
        New-AzManagementPartner -PartnerId $PartnerId | Out-Null
    }
    elseif ($existing -eq $PartnerId) {
        Write-Verbose -Message "Partner id already set on subscription: $subscription..."
    }
    else {
        Write-Verbose -Message "Another partner id: $existing is set on subscription: $subscription, updating..."
        Update-AzManagementPartner -PartnerId $PartnerId | Out-Null
    }
}
```

You can call the script like so:

```powershell
$TenantId = "..."
$PartnerId = "..."

.\Set-PartnerId.ps1 -TenantId $TenantId -PartnerId $PartnerId -Verbose
```

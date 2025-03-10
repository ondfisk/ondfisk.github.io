---
layout: post
title: A simplified Azure Landing Zones alternative
author: Rasmus Lystrøm
date: 2025-03-10 10:00:00 +0100
categories: azure
permalink: a-simplified-azure-landing-zones-alternative/
excerpt_separator: <!--more-->
type: blog
---

Since before the [plague](https://en.wikipedia.org/wiki/COVID-19_pandemic) a number of *reference architectures* for a [*Azure Landing Zones*](https://learn.microsoft.com/en-us/azure/architecture/landing-zones/landing-zone-deploy) have emerged. From a Microsoft perspective it seems to have started with the *North Star* project which eventually became [Azure Landing Zones (Enterprise-Scale) - Reference Implementation](https://github.com/Azure/Enterprise-Scale/) (first commit May 2020) using *ARM* templates. A *Terraform* version -- [Azure landing zones Terraform module](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale) -- and a *Bicep* version [Azure Landing Zones (ALZ) - Bicep](https://github.com/Azure/ALZ-Bicep) soon followed.

<!--more-->

The current guidance is to use [Azure Verified Modules (AVM)](https://github.com/Azure/bicep-registry-modules/) to deploy an *Azure Landing Zones* implementation.

To monitor your Azure platform, deploying an additional project: [Azure Monitor Baseline Alerts (AMBA)](https://github.com/Azure/azure-monitor-baseline-alerts/) seems to be the [*official*](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview#using-azure-policies-for-alerting-at-scale) recommendation.

## Complexity

All the reference implementations above suffer from the authors' incessant need to continuously add more *stuff*. All implementations have very large and daunting code bases, which means that they are almost impossible to get a grip on - let alone understand how to extend.

To remedy these challenges we introduce a *simplified* implementation which should allow platform teams to much more easily reason about and understand what they are trying to build.

The *simplified* version can be found at [Azure Landing Zones Demo](https://github.com/ondfisk/AzureLandingZonesDemo).

To compare the complexity and maintainability of the solutions mentioned, we can use [*cloc*](https://github.com/AlDanial/cloc) to get an overall idea of the number of files and lines of code in each implementation. We will only count *infrastructure as code* and scripts: `JSON`, `HCL`, `Bicep`, `Bash`, and `PowerShell`:

```bash
cloc --include-lang=JSON,PowerShell,Bourne\ Shell,HCL,Standard\ ML,YAML --force-lang="Standard ML,bicep" [path]
```

| Language    | ARM         | Terraform   | Bicep       | AVM         | AMBA        | Simplified  |
|-------------|------------:|------------:|------------:|------------:|------------:|------------:|
| Bicep       | 420         |             | 11,692      | 172,920     | 103,483     | 1,150       |
| HCL         |             | 9,142       |             |             |             |             |
| JSON        | 119,990     | 41,072      | 75,722      | 593,406     | 738,156     | 1,328       |
| YAML        | 740         | 801         | 3,063       | 17,225      | 18,120      | 886         |
| PowerShell  | 5,431       | 685         | 1,439       | 12,912      | 2,030       | 455         |
| Bash        |             | 406         | 13          | 331         |             |             |
| **SUM**     | **126,581** | **52,106**  | **91,929**  | **796,794** | **861,789** | **3,819**   |
| *Files*     | *441*       | *442*       | *690*       | *2,475*     | *3,066*     | *82*        |

Assuming you prefer *Terraform*, you need to *inherit*, *support*, *understand*, and *reason* about at least **52,106** lines of code across *442* files! Then extend the code with your own requirements. This is going to be really *hard* even with a reasonably sized team (4-6 people)

Worst case scenario: You have deployed the original *Enterprise Scale* version with *Baseline Alerts*. You now need to *support*, *understand*, and *reason* about *988,370* lines of code across *3,507* files! This is not *hard*. This is completely *impossible* regardless of team size.

Compare this to the *simplified* version with *3,819* lines of code across *82* files.

## What does *simplified* mean here?

To quote the docs:

> The conceptual architecture is greatly simplified compared to the official one, as we empower DevOps teams to build and run their own thing.
>
> We do not want to manage network from a centralized perspective. All applications will be deployed as islands with no inter-network connectivity.
>
> We adopt a [Zero Trust](https://learn.microsoft.com/en-us/security/zero-trust/zero-trust-overview) approach where identity and encryption trumps and often replaces Network Security.
>
> We do not require nor encourage the use of [Azure Private Link](https://azure.microsoft.com/en-gb/products/private-link/).
>
> We allow most services to have **Public Network Access: Enabled** because we rely on enforcing **Entra ID** authentication and TLS encryption.
>
> ### Online Landing Zones
>
> These are the most important landing zones - all newer applications should be deployed here - even if data resides on-premises.
>
> Connection to on-premises resources should be managed using zero-trust approaches with resources like:
>
> - [Azure Relay](https://learn.microsoft.com/en-us/azure/azure-relay/)
> - [Azure Service Bus](https://learn.microsoft.com/en-us/azure/service-bus-messaging/)
> - [Azure API Management](https://learn.microsoft.com/en-us/azure/api-management/)
> - [Azure Arc](https://azure.microsoft.com/en-us/products/azure-arc/)
>
> ### Corp Landing Zones
>
> Corp landing zones should exclusively be used for lift-and-shift scenarios (and avoided all together if possible). This is reserved for applications which do not support modern authentication and relies on Kerberos (Windows Active Directory).
>
> -- [Azure Landing Zones Demo](https://github.com/ondfisk/AzureLandingZonesDemo)

## Comparing policy-driven governance to *verified modules*

Using [Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/overview) we supply a number of number of policies for popular resources: [Web Apps](https://azure.microsoft.com/en-us/products/app-service/web), [Blob Storage](https://azure.microsoft.com/en-us/products/storage/blobs/), [Key Vault](https://azure.microsoft.com/en-us/products/key-vault/), and [SQL](https://azure.microsoft.com/en-us/products/azure-sql).

Having deployed these policies we enforce the following security defaults on storage accounts:

- HTTPS only (`supportsHttpsTrafficOnly`)
- TLS 1.2 (`minimumTlsVersion`)
- Disallow blob public access (`allowBlobPublicAccess`)
- Disallow cross tenant replication (`allowCrossTenantReplication`)
- Disallow shared key access (`allowSharedKeyAccess`)
- Default to OAuth (`defaultToOAuthAuthentication`)
- Enable [Defender for Storage](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-storage-introduction)

**NB**: We use [*modify*](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effect-modify) and [deploy if not exists](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effect-deploy-if-not-exists) policy effects to ensure that issues with existing storage accounts are automatically remediated.

**NBB**: Security relies on [*zero trust*](https://learn.microsoft.com/en-us/security/zero-trust/) principles of identity-based security (disabling keys) and encryption in transit (HTTPS/TLS 1.2).

Having done this, a storage account can be deployed with a very simple *Bicep* template:

```bicep
param location string = resourceGroup().location
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
}
```

or using [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/):

```bash
az storage account create -n storage42 -g group -l swedencentral --sku Standard_LRS
```

The policies ensure that the platform enforces a *reasonable* set of security defaults, relieving developers from the task.

Compare the **12** lines of code in *Bicep* above to the [*Azure Verified Module*](https://github.com/Azure/bicep-registry-modules/blob/main/avm/res/storage/storage-account) version which contains **3,531** lines of *Bicep* across **29** files (**738** lines in the root file).

Yes, the *official* module can do more stuff (mostly [YAGNI](https://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it)), however, which implementation would you rather reason about or support going forward?

The same principles apply for web apps, key vaults, and SQL. This can be extended quite easily but we deliberately want to keep the reference implementation *simple*. *Pull requests* are welcome, though.

## What about the corporate network?

Cloud applications should *never* be connected to the on-premises network on the network layer. Doing so adds an unnecessary  dependency and makes things way to hard. That said some legacy applications will move to the cloud eventually. To support this [Virtual WAN](https://azure.microsoft.com/en-us/products/virtual-wan/) and [ExpressRoute](https://azure.microsoft.com/en-us/products/expressroute/) can be deployed. This network setup is equal parts expensive and complex while completely tied into your organisation's existing network setup. Because of this we do not want to or mandate a *reference architecture*. This must be done bespoke every time.

However, we still recommend to *not* connect the corporate network at all and rely on *Azure Relay* and *Azure Service Bus* instead.

## Conclusion

We hope this project can serve as a reminder that often *less is more* and getting started should never require you to deploy up to a million lines of code you don't understand.

Check out [Azure Landing Zones Demo](https://github.com/ondfisk/AzureLandingZonesDemo) and let us know what you think using *Issues*, *Stars*, and *Pull Requests*.

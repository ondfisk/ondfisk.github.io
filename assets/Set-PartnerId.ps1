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
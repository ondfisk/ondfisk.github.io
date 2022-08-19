Get-AzResourceProvider -ListAvailable |
    Where-Object ProviderNameSpace -match "Microsoft" |
    Where-Object ProviderNameSpace -notmatch "Classic" |
    Where-Object RegistrationState -eq "NotRegistered" |
    Select-Object ProviderNamespace, RegistrationState, Locations

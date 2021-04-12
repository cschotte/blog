resource storageAccount_resource 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  kind: 'StorageV2'
  location: 'westeurope'
  name: 'clemens2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
  sku: {
    name: 'Standard_LRS'
  }
}

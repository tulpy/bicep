resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'my-azure-key-vault'
  location: 'westeurope'
  properties: {
    tenantId: tenant().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

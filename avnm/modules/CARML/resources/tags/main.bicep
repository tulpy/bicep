metadata name = 'Resources Tags'
metadata description = 'This module deploys a Resource Tag at a Subscription or Resource Group scope.'
metadata owner = 'Azure/module-maintainers'

targetScope = 'subscription'

@description('Optional. Tags for the resource group. If not provided, removes existing tags.')
param tags object?

resource tag 'Microsoft.Resources/tags@2024-03-01' = {
  name: 'default'
  properties: {
    tags: tags
  }
}

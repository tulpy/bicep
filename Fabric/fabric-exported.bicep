@description('Generated from /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/fabric/providers/Microsoft.Fabric/capacities/tulpyfabric')
resource tulpyfabric 'Microsoft.Fabric/capacities@2023-11-01' = {
  properties: {
    provisioningState: 'Succeeded'
    state: 'Active'
    administration: {
      members: [
        'stephen.tulp@xxxxxxxxxxx.onmicrosoft.com'
      ]
    }
  }
  name: 'tulpyfabric'
  location: 'Australia East'
  sku: {
    name: 'F2'
    tier: 'Fabric'
  }
  tags: {}
}

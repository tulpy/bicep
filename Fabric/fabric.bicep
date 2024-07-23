metadata name = 'Microsoft Fabric Module'
metadata description = 'Bicep Module used to deploy Microsoft Fabric Capacity'
metadata author = 'Insight APAC Platform Engineering'

// Parameters
@description('Required. The name of the Fabric Capacity, needs to be globally unique and lowercase.')
param name string

@description('Optional. The Azure Region to deploy the resources into.')
param location string = resourceGroup().location

@description('Optional. The SKU name of the Fabric Capacity.')
@allowed([
  'F2'
  'F4'
  'F8'
  'F16'
  'F32'
  'F64'
  'F128'
  'F256'
  'F512'
  'F1024'
  'F2048'
])
param skuName string = 'F2'

@description('Optional. The SKU tier of the Fabric Capacity instance.')
param skuTier string = 'Fabric'

@description('Required. The list of administrators for the Fabric Capacity instance.')
param adminUsers array

@description('Optional. Tags that will be applied to all resources in this module.')
param tags object = {}

// Resource: Microsoft Fabric Capacity
resource fabricCapacity 'Microsoft.Fabric/capacities@2022-07-01-preview' = {
  name: toLower(name)
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    administration: {
      members: adminUsers
    }
  }
}

// Outputs
@description('The ID of the Fabric Capacity.')
output resourceId string = fabricCapacity.id

@description('The name of the Fabric Capacity.')
output resourceName string = fabricCapacity.name

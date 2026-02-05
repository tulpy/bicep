import * as type from '../../configuration/shared/lz.type.bicep'

targetScope = 'resourceGroup'

metadata name = 'Azure Virtual Network Manager with IPAM'
metadata description = 'Azure Virtual Network Manager with IPAM Module.'
metadata version = '1.0.0'
metadata author = 'Insight APAC Platform Engineering'

@description('Optional. Location for the resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags type.tagsType?

@description('Required. Name of the Azure Virtual Network Manager.')
param name string

@description('Required. Configuration for the Azure Virtual Network Manager.')
param avnmConfiguration object

@description('Required. List of regions for the Ipam Pool.')
param regions array

@description('Resource. Azure Virtual Network Manager.')
resource avnm 'Microsoft.Network/networkManagers@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    networkManagerScopes: {
      managementGroups: avnmConfiguration.?managementGroupScopes
      subscriptions: avnmConfiguration.?subscriptionScopes
    }
  }
}

@description('Resource: IP Address Management (IPAM) Pool for the Azure Virtual Network Manager.')
resource rootIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = {
  name: 'rootIpamPool-${replace(avnmConfiguration.ipamRootSettings.azureCidr, '/', '-')}'
  parent: avnm
  location: location
  tags: tags
  properties: {
    addressPrefixes: [
      avnmConfiguration.ipamRootSettings.azureCidr
    ]
    displayName: avnmConfiguration.ipamRootSettings.rootIpamPoolName
    description: 'Root IPAM pool for the Azure Supernet - (${avnmConfiguration.ipamRootSettings.azureCidr})'
  }
}

@batchSize(1)
@description('Module: IPAM Pool for each region.')
module regionIpamPool './ipamPerRegion.bicep' = [
  for region in regions: {
    name: 'regionIpamPool-${region.name}'
    params: {
      avnmName: avnm.name
      rootIPAMpoolName: 'rootIpamPool-${replace(avnmConfiguration.ipamRootSettings.azureCidr, '/', '-')}'
      regionDisplayName: region.displayName
      regionCidr: region.cidr
      regionLzCidrSize: avnmConfiguration.ipamRootSettings.regionLzCidrSize
      platformAndApplicationSplitFactor: region.platformAndApplicationSplitFactor
      location: region.name
      tags: tags
    }
  }
]

// Outputs
output AzureCIDR string = avnmConfiguration.ipamRootSettings.azureCidr

// outputs per region:
output regionIpamPools array = [
  for (region, i) in regions: {
    Region: region.displayName
    value: {
      name: region.name
      regionCIDR: region.cidr
      platformLzCIDRs: regionIpamPool[i].outputs.platformCIDRs
      platformLzCIDRsCount: regionIpamPool[i].outputs.platformCIDRsCount
      applicationLzCIDRs: regionIpamPool[i].outputs.applicationCIDRs
      applicationLzCIDRsCount: regionIpamPool[i].outputs.applicationCIDRsCount
    }
  }
]

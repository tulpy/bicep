@description('Required. Location for the resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object?

@description('Required. Configuration for the Ipam AVNM.')
param avnmConfiguration object

@description('Required. List of regions for the Ipam Pool.')
param regions array

@description('Required. Set to true to deploy IPAM resources, false to only generate outputs.')
param deploy bool

@description('Required. Name of the existing Azure Virtual Network Manager.')
param avnmName string

@description('Resource: Existing Azure Virtual Network Manager.')
resource avnm 'Microsoft.Network/networkManagers@2024-05-01' existing = if (deploy) {
  name: avnmName
}

@description('Resource: Root IPAM Pool for the Azure Supernet.')
resource rootIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = if (deploy) {
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

@description('Module: IPAM Pool for each region.')
module regionIpamPool './ipamPerRegion.bicep' = [
  for region in regions: {
    name: 'regionIpamPool-${region.name}'
    params: {
      avnmName: avnmName
      deploy: deploy
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
@description('Azure Supernet CIDR.')
output AzureCIDR string = avnmConfiguration.ipamRootSettings.azureCidr

@description('Region Ipam Pools.')
output regionIpamPools array = [
  for (region, i) in regions: {
    Region: region.displayName
    value: {
      name: region.name
      regionCidr: region.cidr
      applicationCidrs: regionIpamPool[i].outputs.applicationCIDRs
      applicationCidrsCount: regionIpamPool[i].outputs.applicationCIDRsCount
      platformCidrs: regionIpamPool[i].outputs.platformCIDRs
      platformCidrsCount: regionIpamPool[i].outputs.platformCIDRs
    }
  }
]

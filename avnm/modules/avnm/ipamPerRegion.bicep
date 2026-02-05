@description('Required. Location for the resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object?

@description('Required. Display name of the region.')
param regionDisplayName string

@description('Required. CIDR for the region IPAM pool.')
param regionCidr string

@description('Required. Name of the root IPAM pool.')
param rootIPAMpoolName string

@description('Required. Name of the existing Azure Virtual Network Manager.')
param avnmName string

@maxValue(32)
@minValue(8)
@description('CIDR size for the region IPAM pool. This is used to determine how many subnets can be created within the region CIDR.')
param regionLzCidrSize int

@maxValue(100)
@minValue(0)
@description('Factor to divide the region CIDR into platform and application landing zones, in percentage.')
param platformAndApplicationSplitFactor int

// Calculate the total number of CIDR blocks available in the region
// Using the RegionCIDRsplitSize parameter to determine subdivision granularity
var powersOfTwo = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512]
var currentRegionCidrSplitSize = int(split(regionCidr, '/')[1])
var subdivisionSize = regionLzCidrSize // Use the parameter directly for subdivision
var totalSubnetCount = powersOfTwo[subdivisionSize - currentRegionCidrSplitSize]

// Generate all possible CIDR blocks for allocation
var allSubnets = [for i in range(0, totalSubnetCount): cidrSubnet(regionCidr, subdivisionSize, i)]

// Calculate how many subnets go to platform vs application based on the factor
var platformSubnetCount = max(1, totalSubnetCount * platformAndApplicationSplitFactor / 100)
var platformSubnets = take(allSubnets, platformSubnetCount)
var applicationSubnets = skip(allSubnets, platformSubnetCount)

// Calculate the CIDRs for application landing zones
var platformCIDRs = platformSubnets

// Calculate the CIDRs for application landing zones
var applicationCIDRs = applicationSubnets

@description('Resource: Existing Azure Virtual Network Manager.')
resource avnm 'Microsoft.Network/networkManagers@2024-05-01' existing = {
  name: avnmName
}

@description('Resource: Region IPAM Pool.')
resource regionIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = {
  name: 'regionIpamPool-${replace(location, ' ', '-')}-${replace(regionCidr, '/', '-')}'
  parent: avnm
  location: location
  tags: tags
  properties: {
    addressPrefixes: [
      regionCidr
    ]
    parentPoolName: rootIPAMpoolName
    displayName: regionDisplayName
    description: 'IPAM pool for ${regionDisplayName} region (${regionCidr})'
  }
}

@description('Resource: Platform Landing Zone IPAM Pool.')
resource platformIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = {
  name: 'platformIpamPool-${replace(location, ' ', '-')}'
  parent: avnm
  location: location
  tags: tags
  dependsOn: [
    regionIpamPool
  ]
  properties: {
    addressPrefixes: platformCIDRs
    parentPoolName: 'regionIpamPool-${replace(location, ' ', '-')}-${replace(regionCidr, '/', '-')}'
    displayName: 'Platform IPAM pool - ${regionDisplayName}'
    description: 'IPAM pool for Platform Landing Zones in the ${regionDisplayName} region'
  }
}

@description('Resource: Application IPAM Pool for the region.')
resource applicationIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-05-01' = {
  name: 'applicationIpamPool-${replace(location, ' ', '-')}'
  parent: avnm
  location: location
  tags: tags
  dependsOn: [
    platformIpamPool
  ]
  properties: {
    addressPrefixes: applicationCIDRs
    parentPoolName: 'regionIpamPool-${replace(location, ' ', '-')}-${replace(regionCidr, '/', '-')}'
    displayName: 'Application IPAM pool - ${regionDisplayName}'
    description: 'IPAM pool for Application Landing Zones in the ${regionDisplayName} region'
  }
}

// Outputs
@description('Region CIDR.')
output regionCIDR string = regionCidr

// Platform Landing Zone CIDRs
@description('Platform Landing Zone CIDRs.')
output platformCIDRs array = platformCIDRs

@description('Count of Platform Landing Zone CIDRs.')
output platformCIDRsCount int = length(platformCIDRs)

// Application Landing Zone CIDRs
@description('Application Landing Zone CIDRs.')
output applicationCIDRs array = applicationCIDRs

@description('Count of Application Landing Zone CIDRs.')
output applicationCIDRsCount int = length(applicationCIDRs)


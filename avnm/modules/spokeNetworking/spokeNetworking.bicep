import * as shared from '../../configuration/shared/shared.conf.bicep'

targetScope = 'resourceGroup'

metadata name = 'ALZ Bicep - Spoke Networking module'
metadata description = 'Deploy the Spoke Networking Module for Azure Landing Zones'
metadata version = '2.0.0'
metadata author = 'Insight APAC Platform Engineering'

// Parameters
@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object?

// Virtual Network Parameters
@description('Required. Configuration for Azure Virtual Network.')
param virtualNetworkConfiguration object

@description('Optional. The Resource ID of the remote virtual network or virtual hub that will be used.')
param hubVirtualNetworkResourceId string = ''

@description('Required. Network Security Group Id.')
param nsgId string

@description('Optional. User Defined Route Id.')
param udrId string = ''

@description('Required. Virtual Network Id.')
param vntId string

// Variables
var addressPrefix = first(virtualNetworkConfiguration.addressPrefixes) // Use the first address prefix for naming purposes
var isIpamPool = startsWith(addressPrefix, '/subscriptions/') // Check if the addressPrefix is an IPAM pool resource ID or a CIDR block
var vNetAddressSpace = isIpamPool ? uniqueString(resourceGroup().id) : replace(addressPrefix, '/', '_') // Use explicitly provided name if available, otherwise use the auto-generated name

var resourceNames = {
  virtualNetwork: virtualNetworkConfiguration.?name ?? '${vntId}${vNetAddressSpace}'
}

@description('Module: Virtual Network - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/virtual-network')
module virtualNetwork 'br/public:avm/res/network/virtual-network:0.7.2' = {
  name: take('virtualNetwork-${guid(deployment().name)}', 64)
  dependsOn: [
    networkSecurityGroup
    routeTable
  ]
  params: {
    // Required parameters
    addressPrefixes: virtualNetworkConfiguration.addressPrefixes
    name: resourceNames.virtualNetwork
    // Non-required parameters
    ddosProtectionPlanResourceId: virtualNetworkConfiguration.?ddosProtectionPlanId ?? null
    dnsServers: virtualNetworkConfiguration.?dnsServers ?? []
    // When using IPAM pools, we need to specify the number of IP addresses to allocate for the VNet
    ipamPoolNumberOfIpAddresses: virtualNetworkConfiguration.?ipamPoolNumberOfIpAddresses ?? null
    location: location
    peerings: [
      for (peering, index) in (virtualNetworkConfiguration.?peerings ?? []): {
        name: 'FROM-${resourceNames.virtualNetwork}-TO-${split(hubVirtualNetworkResourceId, '/')[8]}'
        allowForwardedTraffic: peering.?allowForwardedTraffic ?? true
        allowGatewayTransit: peering.?allowGatewayTransit ?? false
        allowVirtualNetworkAccess: peering.?allowVirtualNetworkAccess ?? true
        remotePeeringAllowForwardedTraffic: peering.?remotePeeringAllowForwardedTraffic ?? true
        remotePeeringAllowVirtualNetworkAccess: peering.?remotePeeringAllowVirtualNetworkAccess ?? true
        remotePeeringEnabled: peering.?remotePeeringEnabled ?? true
        remotePeeringName: 'FROM-${split(hubVirtualNetworkResourceId, '/')[8]}-TO-${resourceNames.virtualNetwork}'
        remoteVirtualNetworkResourceId: hubVirtualNetworkResourceId
        useRemoteGateways: peering.?useRemoteGateways ?? false
      }
    ]
    subnets: [
      for (subnet, index) in (virtualNetworkConfiguration.?subnets ?? []): {
        name: subnet.name
        addressPrefix: subnet.?addressPrefix
        addressPrefixes: subnet.?addressPrefixes
        ipamPoolPrefixAllocations: subnet.?ipamPoolPrefixAllocations
        applicationGatewayIPConfigurations: subnet.?applicationGatewayIPConfigurations
        delegation: subnet.?delegation
        natGatewayResourceId: subnet.?natGatewayResourceId
        networkSecurityGroupResourceId: resourceId('Microsoft.Network/networkSecurityGroups', '${nsgId}${subnet.name}')
        privateEndpointNetworkPolicies: subnet.?privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: subnet.?privateLinkServiceNetworkPolicies
        roleAssignments: subnet.?roleAssignments
        routeTableResourceId: (!empty(subnet.?routes) || !empty(shared.sharedRoutes)) // If either subnet routes or shared routes are not empty, link the route table.
          ? resourceId('Microsoft.Network/routeTables', '${udrId}${subnet.name}')
          : null
        serviceEndpointPolicies: subnet.?serviceEndpointPolicies
        serviceEndpoints: subnet.?serviceEndpoints
        defaultOutboundAccess: subnet.?defaultOutboundAccess
        sharingScope: subnet.?sharingScope
      }
    ]
    tags: tags
  }
}

@description('Module: Route Table - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/route-table')
module routeTable 'br/public:avm/res/network/route-table:0.5.0' = [
  for (subnet, i) in (virtualNetworkConfiguration.?subnets ?? []): if (!empty(subnet.?routes) || !empty(shared.?sharedRoutes)) {
    name: 'routeTable-${i}'
    params: {
      // Required parameters
      name: '${udrId}${subnet.name}'
      // Non-required parameters
      disableBgpRoutePropagation: subnet.?disableBgpRoutePropagation ?? true
      location: location
      routes: !(empty(shared.sharedRoutes)) ? concat(shared.sharedRoutes, subnet.?routes ?? []) : subnet.?routes ?? [] // If shared routes are not empty, use shared routes and subnet routes. If no routes are defined in subnets, pass an empty array
      tags: tags
    }
  }
]

@description('Module: Network Security Group - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/network-security-group')
module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.2' = [
  for (subnet, i) in (virtualNetworkConfiguration.?subnets ?? []): {
    name: 'NSG-${i}'
    params: {
      // Required parameters
      name: '${nsgId}${subnet.name}'
      // Non-required parameters
      location: location
      securityRules: concat(shared.sharedNSGrulesInbound, shared.sharedNSGrulesOutbound, subnet.securityRules)
      tags: tags
    }
  }
]

// Outputs
@description('The Virtual Network Resource Id.')
output virtualNetworkId string = virtualNetwork.outputs.resourceId

@description('The Virtual Network Name.')
output virtualNetworkName string = virtualNetwork.outputs.name

@description('The names of the deployed subnets.')
output subnetNames array = [for (subnet, i) in (virtualNetworkConfiguration.?subnets ?? []): subnet.name]

@description('An array of Route Tables.')
output routeTable array = [
  for (subnet, i) in (virtualNetworkConfiguration.?subnets ?? []): !empty(shared.sharedRoutes)
    ? {
        name: routeTable[i].outputs.name
        id: routeTable[i].outputs.resourceId
      }
    : null
]

@description('An array of Network Security Groups.')
output networkSecurityGroup array = [
  for (subnet, i) in (virtualNetworkConfiguration.?subnets ?? []): {
    name: networkSecurityGroup[i].outputs.name
    id: networkSecurityGroup[i].outputs.name
  }
]

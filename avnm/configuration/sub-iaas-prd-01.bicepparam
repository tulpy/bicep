using '../main.bicep'

param existingSubscriptionId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
param lzId = 'iaas'
param envId = 'prd'
param tags = {
  applicationName: 'Landing Zone'
  contactEmail: 'test@test.com'
  criticality: 'Tier1'
  dataClassification: 'Internal'
  environment: envId
  iac: 'Bicep'
  owner: 'IT'
  costCenter: '1234'
}
param virtualNetworkConfiguration = {
  location: 'australiaeast'
  addressPrefixes: [
    '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/arg-aue-plat-conn-network/providers/Microsoft.Network/networkManagers/avnm-aue-plat-conn-01/ipamPools/applicationIpamPool-australiaeast'
  ]
  ipamPoolNumberOfIpAddresses: '256' // /24
  dnsServers: [
    '10.4.0.68'
  ]
  deployPeering: true
  peeringSettings: {
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    remotePeeringAllowForwardedTraffic: true
    remotePeeringAllowVirtualNetworkAccess: true
    remotePeeringEnabled: true
    useRemoteGateways: true
  }
  subnets: [
    {
      name: 'web'
      ipamPoolPrefixAllocations: [
        {
          numberOfIpAddresses: '64' // /26
          pool: {
            id: '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/arg-aue-plat-conn-network/providers/Microsoft.Network/networkManagers/avnm-aue-plat-conn-01/ipamPools/applicationIpamPool-australiaeast'
          }
        }
      ]
      defaultOutboundAccess: false
      securityRules: []
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
    {
      name: 'apps'
      ipamPoolPrefixAllocations: [
        {
          numberOfIpAddresses: '64' // /26
          pool: {
            id: '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/arg-aue-plat-conn-network/providers/Microsoft.Network/networkManagers/avnm-aue-plat-conn-01/ipamPools/applicationIpamPool-australiaeast'
          }
        }
      ]
      defaultOutboundAccess: false
      securityRules: []
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
    {
      name: 'data'
      ipamPoolPrefixAllocations: [
        {
          numberOfIpAddresses: '64'
          pool: {
            id: '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/arg-aue-plat-conn-network/providers/Microsoft.Network/networkManagers/avnm-aue-plat-conn-01/ipamPools/applicationIpamPool-australiaeast'
          }
        }
      ]
      defaultOutboundAccess: false
      securityRules: []
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
    {
      name: 'privateEndpoints'
      ipamPoolPrefixAllocations: [
        {
          numberOfIpAddresses: '64'
          pool: {
            id: '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/arg-aue-plat-conn-network/providers/Microsoft.Network/networkManagers/avnm-aue-plat-conn-01/ipamPools/applicationIpamPool-australiaeast'
          }
        }
      ]
      defaultOutboundAccess: false
      securityRules: []
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  ]
}

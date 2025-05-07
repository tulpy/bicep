@description('Optional. The Azure Region to deploy the resources into.')
param location string = resourceGroup().location

@description('Required. The IP address range for all virtual networks to use.')
param addressPrefixes string = '10.52.0.0/16'

@description('Required. The name, IP address range, network security group, route table and delegation serviceName for each subnet in the virtual networks.')
param subnets array = [
  {
    name: 'AzureBastionSubnet'
    ipAddressRange: '10.52.0.0/26'
  }
  {
    name: 'GatewaySubnet'
    ipAddressRange: '10.52.0.64/26'
  }
  {
    name: 'AzureFirewallSubnet'
    ipAddressRange: '10.52.0.128/26'
  }
  {
    name: 'inboundDNSSubnet'
    ipAddressRange: '10.52.0.192/27'
  }
  {
    name: 'outboundDNSSubnet'
    ipAddressRange: '10.52.0.224/27'
  }
]

var subnetMap = map(range(0, length(subnets)), i => {
  name: subnets[i].name
  ipAddressRange: subnets[i].ipAddressRange
})

var subnetProperties = [
  for subnet in subnetMap: {
    name: subnet.name
    properties: {
      addressPrefix: subnet.ipAddressRange
    }
  }
]

// Resource: Virtual Network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnt-01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixes
      ]
    }
    subnets: subnetProperties
  }
}

var gatewaySubnetCIDR = subnetProperties[1].properties.addressPrefix

var GatewaySubnetNoHa = parseCidr(gatewaySubnetCIDR).lastUsable

var GatewaySubnetHA = [for i in range(3, 2): cidrHost(gatewaySubnetCIDR, i)]


output outGatewaySubnetNoHa string = GatewaySubnetNoHa
output outGatewaySubnetHA array = GatewaySubnetHA

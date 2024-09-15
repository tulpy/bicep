using './esan.bicep'

param tags = {
  environment: 'sbx'
  applicationName: 'Microsoft Elastic SAN'
  owner: 'Stephen Tulp'
  criticality: 'Tier1'
  costCenter: '1234'
  contactEmail: 'stephen.tulp@xxxxxxxxxxx.onmicrosoft.com'
  dataClassification: 'Internal'
  iac: 'Bicep'
}

param elasticSan = {
  name: 'test'
  baseSizeTiB: 2
  extendedCapacitySizeTiB: 5
  skuName: 'Premium_LRS'
  publicNetworkAccess: 'Enabled'
  availabilityZones: [
    '1'
  ]
  volumeGroup: {
    name: 'volumeGroup1'
    protocolType: 'Iscsi'
    subnetIds: [
      '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/arg-syd-lz-prd-network/providers/Microsoft.Network/virtualNetworks/vnt-syd-lz-prd-10.15.0.0_24/subnets/app'
    ]
  }
  volumes: [
    {
      name: 'volume1'
      sizeGiB: 500
    }
    {
      name: 'volume2'
      sizeGiB: 500
    }
  ]
}

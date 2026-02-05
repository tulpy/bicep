using '../modules/avnm/avnm.bicep'

param tags = {
  environment: 'conn'
  applicationName: 'Azure Virtual Network Manager'
  owner: 'Platform Team'
  criticality: 'Tier0'
  costCenter: '1234'
  contactEmail: 'test@outlook.com'
  dataClassification: 'Internal'
  iac: 'Bicep'
}
param name = 'avnm-aue-plat-conn-01'
param avnmConfiguration = {
  subscriptionScopes: []
  managementGroupScopes: [
    '/providers/Microsoft.Management/managementGroups/mg-alz'
  ]
  ipamRootSettings: {
    rootIpamPoolName: 'AU-RootPool'
    azureCidr: '10.10.0.0/16'
    regionCidrSize: 17 // This number needs to be smaller than or equal to the Azure CIDR size. Each region needs to fit within this CIDR.
    regionLzCidrSize: 22
  }
}
param regions = [
  {
    displayName: 'Australia East'
    name: 'australiaeast'
    cidr: cidrSubnet(avnmConfiguration.ipamRootSettings.azureCidr, avnmConfiguration.ipamRootSettings.regionCidrSize, 0)
    platformAndApplicationSplitFactor: 5
  }
  {
    displayName: 'Australia Southeast'
    name: 'australiasoutheast'
    cidr: cidrSubnet(avnmConfiguration.ipamRootSettings.azureCidr, avnmConfiguration.ipamRootSettings.regionCidrSize, 1)
    platformAndApplicationSplitFactor: 5
  }
]

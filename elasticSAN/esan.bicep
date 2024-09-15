targetScope = 'resourceGroup'

metadata name = 'Azure Elastic SAN Module'
metadata description = 'Deploy the Azure Elastic SAN Module.'
metadata version = '1.0.0'
metadata author = 'Insight Platform Engineering Team'

// Parameters
@description('Optional. The Azure Region to deploy the resources into.')
param location string = resourceGroup().location

@description('Basic configuration for the Elastic SAN resource.')
param elasticSan elasticSanType

@description('The tags to be associated with the resources.')
param tags tagsType

// Resource: Microsoft.ElasticSan/elasticSans
resource eSan 'Microsoft.ElasticSan/elasticSans@2024-05-01' = {
  name: toLower(elasticSan.name)
  location: location
  tags: tags
  properties: {
    baseSizeTiB: elasticSan.baseSizeTiB
    extendedCapacitySizeTiB: elasticSan.extendedCapacitySizeTiB
    availabilityZones: elasticSan.availabilityZones
    publicNetworkAccess: elasticSan.publicNetworkAccess
    sku: {
      name: elasticSan.skuName
      tier: 'Premium'
    }
  }

  // Resource: Microsoft.ElasticSan/elasticSans/volumeGroups
  resource volumeGroup 'volumegroups@2024-05-01' = {
    name: toLower(elasticSan.volumeGroup.name)
    properties: {
      protocolType: elasticSan.volumeGroup.protocolType
      networkAcls: {
        virtualNetworkRules: [
          for subnetId in elasticSan.volumeGroup.subnetIds: {
            id: subnetId
          }
        ]
      }
    }

    // Resource: Microsoft.ElasticSan/elasticSans/volumeGroups/volumes
    resource volumes 'volumes@2024-05-01' = [
      for volume in elasticSan.volumes: {
        name: toLower(volume.name)
        properties: {
          sizeGiB: volume.sizeGiB
        }
      }
    ]
  }
}

// Outputs
@description('The ID of the Elastic SAN.')
output elasticSanResourceId string = eSan.id

@description('The name of the Elastic SAN.')
output elasticSanName string = eSan.name

// Definitions
type elasticSanType = {
  @minLength(3)
  @maxLength(24)
  @description('Required. Specify the name of the Elastic SAN resource.')
  name: string
  @description('Required. Base size of the Elastic San appliance in TiB..')
  baseSizeTiB: int
  @description('Required. Extended size of the Elastic San appliance in TiB..')
  extendedCapacitySizeTiB: int
  @description('Required. Specify the name of the Elastic SAN SKU.')
  skuName: 'Premium_LRS' | 'Premium_ZRS'
  @description('Optional. Logical zone for Elastic San resource; example: ["1"].')
  availabilityZones: array?
  @description('Optional. Allow or disallow public network access to ElasticSan. Value is optional but if passed in, must be "Enabled" or "Disabled".')
  publicNetworkAccess: 'Disabled' | 'Enabled'

  @description('Required. The Elastic SAN Volume Group object.')
  volumeGroup: {
    @minLength(3)
    @maxLength(63)
    @description('Required. The name of the Elastic SAN Volume Group.')
    name: string
    @description('Optional. Type of storage target.')
    protocolType: 'Iscsi' | 'None'
    @description('Optional. Specify the name of the subnet Ids for access to the Elastic SAN volume group.')
    subnetIds: array
  }

  @description('Required. Specify the name of the Elastic SAN Volume array.')
  volumes: {
    @description('Required. Specify the name of the Elastic SAN volume.')
    name: string
    @description('Required. The size of the volume.')
    sizeGiB: int
  }[]
}

type tagsType = {
  environment: 'sbx' | 'dev' | 'tst' | 'prd'
  applicationName: 'Microsoft Elastic SAN'
  owner: string
  criticality: 'Tier0' | 'Tier1' | 'Tier2' | 'Tier3'
  costCenter: string
  contactEmail: string
  dataClassification: 'Internal' | 'Confidential' | 'Secret' | 'Top Secret'
  iac: 'Bicep'
  *: string
}

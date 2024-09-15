param elasticSans_test_name string = 'test'
param virtualNetworks_vnt_syd_lz_prd_10_15_0_0_24_externalid string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/arg-syd-lz-prd-network/providers/Microsoft.Network/virtualNetworks/vnt-syd-lz-prd-10.15.0.0_24'

resource elasticSans_test_name_resource 'Microsoft.ElasticSan/elasticSans@2024-05-01' = {
  name: elasticSans_test_name
  location: 'australiaeast'
  tags: {
    environment: 'sbx'
    applicationName: 'Microsoft Elastic SAN'
    owner: 'Stephen Tulp'
    criticality: 'Tier1'
    costCenter: '1234'
    contactEmail: 'stephen.tulp@xxxxxxxxxxx.onmicrosoft.com'
    dataClassification: 'Internal'
    iac: 'Bicep'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    sku: {
      name: 'Premium_LRS'
      tier: 'Premium'
    }
    availabilityZones: []
    baseSizeTiB: 2
    extendedCapacitySizeTiB: 5
  }
}

resource elasticSans_test_name_volumegroup1 'Microsoft.ElasticSan/elasticSans/volumeGroups@2024-05-01' = {
  parent: elasticSans_test_name_resource
  name: 'volumegroup1'
  properties: {
    networkAcls: {
      virtualNetworkRules: [
        {
          action: 'Allow'
          id: '${virtualNetworks_vnt_syd_lz_prd_10_15_0_0_24_externalid}/subnets/app'
        }
      ]
    }
    protocolType: 'iSCSI'
    encryption: 'EncryptionAtRestWithPlatformKey'
  }
}

resource elasticSans_test_name_volumegroup1_volume1 'Microsoft.ElasticSan/elasticSans/volumeGroups/volumes@2024-05-01' = {
  parent: elasticSans_test_name_volumegroup1
  name: 'volume1'
  properties: {
    managedBy: {
      resourceId: 'None'
    }
    creationData: {
      createSource: 'None'
    }
    sizeGiB: 500
  }
  dependsOn: [
    elasticSans_test_name_resource
  ]
}

resource elasticSans_test_name_volumegroup1_volume2 'Microsoft.ElasticSan/elasticSans/volumeGroups/volumes@2024-05-01' = {
  parent: elasticSans_test_name_volumegroup1
  name: 'volume2'
  properties: {
    managedBy: {
      resourceId: 'None'
    }
    creationData: {
      createSource: 'None'
    }
    sizeGiB: 500
  }
  dependsOn: [
    elasticSans_test_name_resource
  ]
}

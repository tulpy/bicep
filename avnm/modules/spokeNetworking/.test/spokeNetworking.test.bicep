targetScope = 'resourceGroup'

metadata name = 'Test and Validation Deployment'
metadata description = 'Test and Validation of the spoke Networking Module.'

module testDeployment '../spokeNetworking.bicep' = {
  name: take('testDeployment-${guid(deployment().name)}', 64)
  params: {
    #disable-next-line no-hardcoded-location
    location: 'australiaeast'
    vntId: 'vnet-syd-sap-prd'
    nsgId: 'nsg-syd-sap-prd-app'
    udrId: 'udr-syd-sap-prd-app'
    virtualNetworkConfiguration: {
      name: 'vnet-syd-sap-prd'
      addressPrefixes: ['10.0.0.0/16']
    }
    tags: {
      applicationName: 'Test'
      contactEmail: 'test@test.com'
      criticality: 'Tier3'
      dataClassification: 'Internal'
      environment: 'sbx'
      iac: 'Bicep'
      owner: 'test@test.com'
      purchaseOrder: '12345'
    }
  }
}

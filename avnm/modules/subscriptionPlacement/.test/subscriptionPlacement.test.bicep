targetScope = 'managementGroup'

metadata name = 'Test and Validation Deployment'
metadata description = 'Test and Validation of the subscriptionPlacement Module.'

module testDeployment '../subscriptionPlacement.bicep' = {
  name: take('testDeployment-${guid(deployment().name)}', 64)
  params: {
    subscriptionIds: [
      '00000000-0000-0000-0000-000000000000'
    ]
    targetManagementGroupId: 'mg-alz'
  }
}

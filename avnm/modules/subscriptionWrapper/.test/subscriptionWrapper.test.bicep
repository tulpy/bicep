targetScope = 'managementGroup'

metadata name = 'Test and Validation Deployment'
metadata description = 'Test and Validation of the subscriptionWrapper Module.'

param subscriptionId string = '00000000-0000-0000-0000-000000000000'
param subscriptionMgPlacement string = 'mg-alz1-landingzones-corp'
param lzId string = 'sap'
param envId string = 'prd'

module testDeployment '../subscriptionWrapper.bicep' = {
  name: take('testDeployment-${guid(deployment().name)}', 64)
  params: {
    #disable-next-line no-hardcoded-location
    location: 'australiaeast'
    subscriptionId: subscriptionId
    subscriptionManagementGroupAssociationEnabled: true
    subscriptionMgPlacement: subscriptionMgPlacement
    lzId: lzId
    envId: envId
    roleAssignments: []
    tags: {
      applicationName: 'Test'
      contactEmail: 'test@test.com'
      criticality: 'Tier3'
      dataClassification: 'Internal'
      environment: envId
      iac: 'Bicep'
      owner: 'test@test.com'
      purchaseOrder: '12345'
    }
    budgetConfiguration: {
      budgets: [
        {
          name: 'testBudget'
          category: 'Cost'
          amount: 500
          thresholdType: 'Actual'
          thresholds: [
            80
            100
          ]
          startDate: '2024-01-01'
          contactEmails: [
            'test@outlook.com'
          ]
        }
      ]
    }
    hubVirtualNetworkResourceId: ''
  }
}

targetScope = 'tenant'

metadata name = 'Test and Validation Deployment'
metadata description = 'Test and Validation of the subscriptionCreation Module.'

module testDeployment '../subscriptionCreation.bicep' = {
  name: take('testDeployment-${guid(deployment().name)}', 64)
  params: {
    subscriptionDisplayName: 'test-subscription'
    subscriptionAliasName: 'test-subscription'
    subscriptionBillingScope: '/providers/Microsoft.Billing/billingAccounts/00000000-0000-0000-0000-000000000000'
    subscriptionWorkload: 'DevTest'
    subscriptionTenantId: '00000000-0000-0000-0000-000000000000'
    subscriptionOwnerId: '00000000-0000-0000-0000-000000000000'
  }
}

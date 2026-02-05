// Workload User Defined Types
import {
  recoveryVaultType
} from './configuration/shared/workload.type.bicep'

// Base Landing Zone User Defined Types
import {
  tagsType
  roleAssignmentsType
  budgetType
  actionGroupType
  virtualNetworkType
  vwanPeeringType
} from './configuration/shared/lz.type.bicep'
targetScope = 'managementGroup'

metadata name = 'ALZ Bicep - Subscription Vending Orchestration'
metadata description = 'Orchestration used to create a new Azure Subscription and/or parse in an existing subscription.'
metadata version = '2.1.0'
metadata author = 'Insight APAC Platform Engineering'

// Subscription Creation Module Parameters
@description('Optional. Whether to create a new Azure Subscription using the subscriptionCreation module. If false, then supply the existingSubscriptionId parameter instead to deploy resources to an existing subscription.')
param subscriptionAliasEnabled bool = false

@maxLength(63)
@description('Optional. The name of the subscription alias. The string must be comprised of a-z, A-Z, 0-9, - and _. The maximum length is 63 characters.')
param subscriptionDisplayName string = ''

@maxLength(63)
@description('Optional. The name of the Subscription Alias, that will be created by this module.')
param subscriptionAliasName string = ''

@description('Optional. The Billing Scope for the new Subscription alias, that will be created by this module.')
param subscriptionBillingScope string = ''

@allowed([
  'DevTest'
  'Production'
])
@description('Optional. The workload type can be either `Production` or `DevTest` and is case sensitive.')
param subscriptionWorkload string = 'Production'

@maxLength(36)
@description('Optional. The Microsoft Entra Tenant ID (GUID) to which the Subscription should be attached to.')
param subscriptionTenantId string = ''

@maxLength(36)
@description('Optional. The Azure Active Directory principals object ID (GUID) to whom should be the Subscription Owner.')
param subscriptionOwnerId string = ''

// Subscription Wrapper Module Parameters
@maxLength(36)
@description('Optional. An existing subscription ID. Use this when you do not want the module to create a new subscription. But do want to manage the management group membership. A subscription ID should be provided in the example format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`.')
param existingSubscriptionId string = ''

@description('Optional. Whether to move the Subscription to the specified Management Group supplied in the parameter `subscriptionMgPlacement`.')
param subscriptionManagementGroupAssociationEnabled bool = true

@description('Optional. The destination Management Group ID for the new Subscription that will be created by this module (or the existing one provided in the parameter `existingSubscriptionId`')
param subscriptionMgPlacement string = ''

@description('Optional. The Azure Region to deploy the Landing Zone into.')
param location string = deployment().location

@maxLength(10)
@description('Required. Specifies the Landing Zone Id for the deployment and Azure resources. This is the function of the Landing Zone AIS, SAP, AVD etc.')
param lzId string

@allowed([
  'dev'
  'tst'
  'prd'
  'sbx'
  'nprd'
])
@description('Required. Specifies the environment Id for the deployment.')
param envId string

@description('Optional. Tags of the resource.')
param tags tagsType?

@description('Optional. Supply an array of objects containing the details of the role assignments to create.')
param roleAssignments roleAssignmentsType?

@description('Optional. Configuration for Action Groups.')
param actionGroupConfiguration actionGroupType?

@description('Optional. Configuration for Azure Budgets.')
param budgetConfiguration budgetType?

@description('Optional. Configuration for Azure Virtual Network.')
param virtualNetworkConfiguration virtualNetworkType?

@description('Optional. Configuration for Azure vWAN peering.')
param vwanPeeringConfiguration vwanPeeringType?

@description('Optional. Configuration for Azure Recovery Services Vault.')
param recoveryVaultConfiguration recoveryVaultType?

@description('Optional. The Resource ID of the remote virtual network or virtual hub that will be used.')
param hubVirtualNetworkResourceId string = ''

@description('Optional. Switch for Azure Budgets.')
param deployBudgets bool = true

@description('Optional. Switch for Azure Recovery Services Vault for Azure Backup.')
param deployRecoveryVault bool = true

@description('Optional. Switch for Virtual Networks.')
param deployVirtualNetwork bool = true

// Orchestration Variables
var existingSubscriptionIDEmptyCheck = empty(existingSubscriptionId)
  ? 'No Subscription Id Provided'
  : existingSubscriptionId

@description('Subscription Creation')
module subscriptionCreation './modules/subscriptionCreation/subscriptionCreation.bicep' = if (subscriptionAliasEnabled && empty(existingSubscriptionId)) {
  scope: tenant()
  name: take('subscriptionCreation-${guid(deployment().name)}', 64)
  params: {
    subscriptionAliasName: subscriptionAliasName
    subscriptionBillingScope: subscriptionBillingScope
    subscriptionDisplayName: subscriptionDisplayName
    subscriptionOwnerId: subscriptionOwnerId
    subscriptionTenantId: subscriptionTenantId
    subscriptionWorkload: subscriptionWorkload
  }
}

@description('Module: Subscription Wrapper')
module subscriptionWrapper './modules/subscriptionWrapper/subscriptionWrapper.bicep' = if (subscriptionAliasEnabled || !empty(existingSubscriptionId)) {
  name: take('subscriptionWrapper-${guid(deployment().name)}', 64)
  params: {
    actionGroupConfiguration: actionGroupConfiguration
    budgetConfiguration: budgetConfiguration
    envId: envId
    deployBudgets: deployBudgets
    deployRecoveryVault: deployRecoveryVault
    deployVirtualNetwork: deployVirtualNetwork
    hubVirtualNetworkResourceId: hubVirtualNetworkResourceId
    location: location
    lzId: lzId
    recoveryVaultConfiguration: recoveryVaultConfiguration
    roleAssignments: roleAssignments
    subscriptionId: (subscriptionAliasEnabled && empty(existingSubscriptionId))
      ? subscriptionCreation!.outputs.subscriptionId
      : existingSubscriptionId
    subscriptionManagementGroupAssociationEnabled: subscriptionManagementGroupAssociationEnabled
    subscriptionMgPlacement: subscriptionMgPlacement
    tags: tags
    virtualNetworkConfiguration: virtualNetworkConfiguration
    vwanPeeringConfiguration: vwanPeeringConfiguration
  }
}

// Output
@description('The subscription Id that has either been created or provided.')
output subscriptionId string = (subscriptionAliasEnabled && empty(existingSubscriptionId))
  ? subscriptionCreation!.outputs.subscriptionId
  : contains(existingSubscriptionIDEmptyCheck, 'No Subscription Id Provided')
      ? existingSubscriptionIDEmptyCheck
      : '${existingSubscriptionId}'

@description('The subscription Resource Id that has been created or provided.')
output subscriptionResourceId string = (subscriptionAliasEnabled && empty(existingSubscriptionId))
  ? subscriptionCreation!.outputs.subscriptionResourceId
  : contains(existingSubscriptionIDEmptyCheck, 'No Subscription Id Provided')
      ? existingSubscriptionIDEmptyCheck
      : '/subscriptions/${existingSubscriptionId}'

@description('The Subscription Owner State. Only used when creating MCA Subscriptions across tenants')
output subscriptionAcceptOwnershipState string = (subscriptionAliasEnabled && empty(existingSubscriptionId) && !empty(subscriptionTenantId) && !empty(subscriptionOwnerId))
  ? subscriptionCreation!.outputs.subscriptionAcceptOwnershipState
  : 'N/A'

@description('The Subscription Ownership URL. Only used when creating MCA Subscriptions across tenants')
output subscriptionAcceptOwnershipUrl string = (subscriptionAliasEnabled && empty(existingSubscriptionId) && !empty(subscriptionTenantId) && !empty(subscriptionOwnerId))
  ? subscriptionCreation!.outputs.subscriptionAcceptOwnershipUrl
  : 'N/A'

import * as shared from '../../configuration/shared/shared.conf.bicep'

// Workload User Defined Types
import {
  recoveryVaultType
} from '../../configuration/shared/workload.type.bicep'

// Base Landing Zone User Defined Types
import {
  tagsType
  roleAssignmentsType
  budgetType
  actionGroupType
  virtualNetworkType
  vwanPeeringType
} from '../../configuration/shared/lz.type.bicep'

targetScope = 'managementGroup'

metadata name = 'ALZ Bicep - Subscription Wrapper Module'
metadata description = 'Module used to wrap the Azure Landing Zone deployment.'
metadata version = '3.0.0'
metadata author = 'Insight APAC Platform Engineering'

@description('Optional. The Azure Region to deploy the resources into.')
param location string = deployment().location

@description('Required. The Subscription Id for the deployment.')
@maxLength(36)
param subscriptionId string

@description('Optional. Whether to move the Subscription to the specified Management Group supplied in the parameter `subscriptionManagementGroupId`.')
param subscriptionManagementGroupAssociationEnabled bool = true

@description('Optional. The Management Group Id to place the subscription in.')
param subscriptionMgPlacement string = ''

@maxLength(10)
@description('Required. Specifies the Landing Zone Id for the deployment and Azure resources. This is the function of the Landing Zone AIS, SAP, AVD etc.')
param lzId string

@description('Required. Specifies the environment Id for the deployment.')
param envId string

@description('Optional. Tags of the resource.')
param tags tagsType?

// Boolean Parameters
@description('Optional. Switch for Azure Budgets.')
param deployBudgets bool = true

@description('Optional. Switch for Azure Recovery Services Vault for Azure Backup.')
param deployRecoveryVault bool = true

@description('Optional. Switch for Virtual Networks.')
param deployVirtualNetwork bool = true

// User Defined Type Parameters
@description('Optional. Supply an array of objects containing the details of the role assignments to create.')
param roleAssignments roleAssignmentsType?

@description('Optional. Configuration for Azure Budgets.')
param budgetConfiguration budgetType?

@description('Optional. Configuration for Action Groups.')
param actionGroupConfiguration actionGroupType?

@description('Optional. Configuration for Azure Virtual Network.')
param virtualNetworkConfiguration virtualNetworkType?

@description('Optional. Configuration for Azure vWAN peering.')
param vwanPeeringConfiguration vwanPeeringType?

@description('Optional. Configuration for Azure Recovery Services Vault.')
param recoveryVaultConfiguration recoveryVaultType?

@description('Optional. The Resource ID of the remote virtual network or virtual hub that will be used.')
param hubVirtualNetworkResourceId string = ''

// Local Development Parameters
@description('Optional. The JSON payload for the name prefixes, if wanting to override that in the ../configuration/shared/ folder.')
param namePrefixesPayload object = {}

@description('Optional. The JSON payload for the location prefixes, if wanting to override that in the ../configuration/shared/ folder.')
param locationPrefixesPayload object = {}

// Variables
var namePrefixes = !empty(namePrefixesPayload) ? namePrefixesPayload : shared.resPrefixes
var locationPrefixes = !empty(locationPrefixesPayload) ? locationPrefixesPayload : shared.locPrefixes

var rgId = toLower('${namePrefixes.resourceGroup}${shared.delimiter.dash}${locationPrefixes[location]}${shared.delimiter.dash}${lzId}${shared.delimiter.dash}${envId}${shared.delimiter.dash}')
var nsgId = toLower('${namePrefixes.networkSecurityGroup}${shared.delimiter.dash}${locationPrefixes[location]}${shared.delimiter.dash}${lzId}${shared.delimiter.dash}${envId}${shared.delimiter.dash}')
var udrId = toLower('${namePrefixes.routeTable}${shared.delimiter.dash}${locationPrefixes[location]}${shared.delimiter.dash}${lzId}${shared.delimiter.dash}${envId}${shared.delimiter.dash}')
var vntId = toLower('${namePrefixes.virtualNetwork}${shared.delimiter.dash}${locationPrefixes[location]}${shared.delimiter.dash}${lzId}${shared.delimiter.dash}${envId}${shared.delimiter.dash}')
var rsvId = toLower('${namePrefixes.recoveryVault}${shared.delimiter.dash}${locationPrefixes[location]}${shared.delimiter.dash}${lzId}${shared.delimiter.dash}${envId}${shared.delimiter.dash}')
var uniqueSuffix = toLower(uniqueString(subscriptionId, envId, location))

var deployVwanPeering = vwanPeeringConfiguration.?enabled ?? false
var deployRoutingIntent = vwanPeeringConfiguration.?routingIntentEnabled ?? true

// Check hubVirtualNetworkResourceId to see if it's a virtual WAN connection instead of normal virtual network peering
var virtualHubResourceIdChecked = (!empty(hubVirtualNetworkResourceId) && contains(
    hubVirtualNetworkResourceId,
    '/providers/Microsoft.Network/virtualHubs/'
  )
  ? hubVirtualNetworkResourceId
  : '')
var hubVirtualNetworkResourceIdChecked = (!empty(hubVirtualNetworkResourceId) && contains(
    hubVirtualNetworkResourceId,
    '/providers/Microsoft.Network/virtualNetworks/'
  )
  ? hubVirtualNetworkResourceId
  : '')

var virtualWanHubName = (!empty(virtualHubResourceIdChecked) ? split(virtualHubResourceIdChecked, '/')[8] : '')
var virtualWanHubSubscriptionId = (!empty(virtualHubResourceIdChecked) ? split(virtualHubResourceIdChecked, '/')[2] : '')
var virtualWanHubResourceGroupName = (!empty(virtualHubResourceIdChecked)
  ? split(virtualHubResourceIdChecked, '/')[4]
  : '')
var virtualWanHubConnectionAssociatedRouteTable = !empty(vwanPeeringConfiguration.?associatedRouteTableResourceId)
  ? vwanPeeringConfiguration.?associatedRouteTableResourceId
  : '${virtualHubResourceIdChecked}/hubRouteTables/defaultRouteTable'
var virutalWanHubDefaultRouteTableId = {
  id: '${virtualHubResourceIdChecked}/hubRouteTables/defaultRouteTable'
}
var virtualWanHubConnectionPropogatedRouteTables = !empty(vwanPeeringConfiguration.?propagatedRouteTablesResourceIds)
  ? vwanPeeringConfiguration.?propagatedRouteTablesResourceIds
  : array(virutalWanHubDefaultRouteTableId)
var virtualWanHubConnectionPropogatedLabels = !empty(vwanPeeringConfiguration.?propagatedLabels)
  ? vwanPeeringConfiguration.?propagatedLabels
  : ['default']

var resourceGroups = {
  network: '${rgId}network'
  lzMgmt: '${rgId}lzmgmt'
}

var resourceNames = {
  actionGroup: actionGroupConfiguration.?name ?? '${lzId}${envId}ActionGroup'
  actionGroupShort: actionGroupConfiguration.?name ?? '${lzId}${envId}AG'
  recoveryServicesVault: recoveryVaultConfiguration.?name ?? '${rsvId}${uniqueSuffix}'
}

@description('Module: Subscription Placement')
module subscriptionPlacement '../../modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (subscriptionManagementGroupAssociationEnabled && !empty(subscriptionMgPlacement)) {
  scope: managementGroup(subscriptionMgPlacement)
  name: take('subscriptionPlacement-${guid(deployment().name)}', 64)
  params: {
    targetManagementGroupId: subscriptionMgPlacement
    subscriptionIds: [
      subscriptionId
    ]
  }
}

@description('Module: Subscription Tags')
module subscriptionTags '../../modules/CARML/resources/tags/main.bicep' = if (!empty(tags)) {
  scope: subscription(subscriptionId)
  name: take('subTags-${guid(deployment().name)}', 64)
  params: {
    tags: tags
  }
}

@description('Module: Azure Budgets - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/consumption/budget')
module budget 'br/public:avm/res/consumption/budget:0.3.8' = [
  for (bg, index) in (budgetConfiguration.?budgets ?? []): if (!empty(budgetConfiguration) && deployBudgets) {
    name: take('budget-${guid(deployment().name)}-${index}', 64)
    scope: subscription(subscriptionId)
    params: {
      name: bg.name
      startDate: bg.startDate
      location: location
      amount: bg.amount
      thresholdType: bg.thresholdType
      thresholds: bg.thresholds
      contactEmails: bg.contactEmails
    }
  }
]

@description('Module: Azure Role Assignments - https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/authorization/role-assignment')
module roleAssignment 'br/public:avm/ptn/authorization/role-assignment:0.2.4' = [
  for assignment in (roleAssignments ?? []): if (!empty(roleAssignments)) {
    name: take('roleAssignments-${uniqueString(assignment.principalId)}', 64)
    params: {
      location: location
      principalId: assignment.principalId
      roleDefinitionIdOrName: assignment.roleDefinitionIdOrName
      principalType: assignment.principalType
      subscriptionId: assignment.subscriptionId
      resourceGroupName: !empty(assignment.resourceGroupName) ? assignment.resourceGroupName : ''
    }
  }
]

@description('Resource Groups (Common) - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/resources/resource-group')
module commonResourceGroups 'br/public:avm/res/resources/resource-group:0.4.3' = [
  for commonResourceGroup in shared.commonResourceGroupNames: {
    name: take('sharedResourceGroups-${commonResourceGroup}', 64)
    scope: subscription(subscriptionId)
    params: {
      name: commonResourceGroup
      location: location
      tags: tags
    }
  }
]

@description('Module: Action Group - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/insights/action-group')
module actionGroup 'br/public:avm/res/insights/action-group:0.8.0' = if (!empty(actionGroupConfiguration.?emailReceivers)) {
  name: take('actionGroup-${guid(deployment().name)}', 64)
  scope: resourceGroup(subscriptionId, 'alertsRG')
  dependsOn: [
    commonResourceGroups
  ]
  params: {
    // Required parameters
    groupShortName: resourceNames.actionGroupShort
    name: resourceNames.actionGroup
    // Non-required parameters
    emailReceivers: [
      for email in actionGroupConfiguration.?emailReceivers ?? []: {
        emailAddress: email
        name: split(email, '@')[0]
        useCommonAlertSchema: true
      }
    ]
    location: 'Global'
    tags: tags
  }
}

@description('Resource Groups (Network) - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/resources/resource-group')
module resourceGroupForNetwork 'br/public:avm/res/resources/resource-group:0.4.3' = if (deployVirtualNetwork) {
  name: take('resourceGroupForNetwork-${guid(deployment().name)}', 64)
  scope: subscription(subscriptionId)
  params: {
    name: resourceGroups.network
    location: location
    tags: tags
  }
}

@description('Module: Network Watcher - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/network-watcher')
module networkWatcher 'br/public:avm/res/network/network-watcher:0.5.0' = if (deployVirtualNetwork) {
  name: take('networkWatcher-${guid(deployment().name)}', 64)
  scope: resourceGroup(subscriptionId, 'networkWatcherRG')
  dependsOn: [
    commonResourceGroups
  ]
  params: {
    location: location
    tags: tags
  }
}

@description('Module: Spoke Networking')
module spokeNetworking '../spokeNetworking/spokeNetworking.bicep' = if (deployVirtualNetwork && !empty(virtualNetworkConfiguration.?addressPrefixes)) {
  name: take('spokeNetworking-${guid(deployment().name)}', 64)
  scope: resourceGroup(subscriptionId, resourceGroups.network)
  dependsOn: [
    resourceGroupForNetwork
  ]
  params: {
    location: location
    nsgId: nsgId
    tags: tags
    udrId: udrId
    virtualNetworkConfiguration: virtualNetworkConfiguration ?? {}
    hubVirtualNetworkResourceId: hubVirtualNetworkResourceIdChecked
    vntId: vntId
  }
}

@description('Module: Virtual Network Connection (vWAN)')
module spokePeeringToVwanHub '../CARML/network/virtual-hub/hub-virtual-network-connection/main.bicep' = if (bool(deployVirtualNetwork) && bool(deployVwanPeering) && !empty(virtualHubResourceIdChecked) && !empty(virtualNetworkConfiguration.?addressPrefixes) && !empty(virtualWanHubResourceGroupName) && !empty(virtualWanHubSubscriptionId)) {
  dependsOn: [
    resourceGroupForNetwork
  ]
  scope: resourceGroup(virtualWanHubSubscriptionId, virtualWanHubResourceGroupName)
  name: take('spokePeeringToVwanHub-${guid(deployment().name)}', 64)
  params: {
    name: 'vhc-${guid(virtualHubResourceIdChecked, spokeNetworking!.outputs.virtualNetworkName, resourceGroups.network, location, subscriptionId)}'
    virtualHubName: virtualWanHubName
    remoteVirtualNetworkId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroups.network}/providers/Microsoft.Network/virtualNetworks/${spokeNetworking!.outputs.virtualNetworkName}'
    enableInternetSecurity: vwanPeeringConfiguration.?enableInternetSecurity ?? true
    routingConfiguration: deployRoutingIntent
      ? {}
      : {
          associatedRouteTable: {
            id: virtualWanHubConnectionAssociatedRouteTable
          }
          propagatedRouteTables: {
            ids: virtualWanHubConnectionPropogatedRouteTables
            labels: virtualWanHubConnectionPropogatedLabels
          }
        }
  }
}

@description('Resource Groups (Landing Zone Management) - https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/resources/resource-group')
module resourceGroupForLzMgmt 'br/public:avm/res/resources/resource-group:0.4.3' = if (deployRecoveryVault) {
  name: take('resourceGroupForBackup-${guid(deployment().name)}', 64)
  scope: subscription(subscriptionId)
  params: {
    // Required parameters
    name: resourceGroups.lzMgmt
    // Non-required parameters
    location: location
    tags: tags
  }
}

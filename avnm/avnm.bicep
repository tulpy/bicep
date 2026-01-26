import {
  // Base Landing Zone User Defined Types
  tagsType
} from './configuration/shared/lz.type.bicep'

targetScope = 'resourceGroup'

metadata name = 'Azure Virtual Network Manager with IPAM'
metadata description = 'Azure Virtual Network Manager with IPAM Module.'
metadata version = '1.0.0'
metadata author = 'Insight APAC Platform Engineering'

@description('Optional. Location for the resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags tagsType?

@description('Required. Configuration for the Azure Virtual Network Manager.')
param avnmConfiguration avnmType

@description('Required. List of regions for the Ipam Pool.')
param regions ipamRegionType

@description('Required. Set to true to deploy IPAM resources, false to only generate outputs.')
param deploy bool

@description('Resource. Azure Virtual Network Manager.')
module networkManagers 'br/public:avm/res/network/network-manager:0.5.3' = if (deploy) {
  params: {
    location: location
    name: avnmConfiguration.name
    networkManagerScopes: {
      managementGroups: avnmConfiguration.?managementGroupScopes
      subscriptions: avnmConfiguration.?subscriptionScopes
    }
    tags: tags
  }
}

@description('Module: IPAM')
module ipam './ipam.bicep' = if (deploy) {
  params: {
    avnmConfiguration: avnmConfiguration
    avnmName: networkManagers.?outputs.name ?? ''
    deploy: deploy
    location: location
    regions: regions
    tags: tags
  }
}

// Outputs
@description('The resource ID of the network manager.')
output avnmNameResourceId string = networkManagers.?outputs.resourceId ?? ''

@description('The name of the network manager.')
output avnmName string = networkManagers.?outputs.name ?? ''

// User Defined Types
import { networkGroupType, securityAdminConfigurationType } from 'br/public:avm/res/network/network-manager:0.5.3'
type avnmType = {
  @minLength(1)
  @maxLength(64)
  @description('Required. Name of the Network Manager.')
  name: string

  @description('Optional. Subscription scopes for the Network Manager.')
  subscriptionScopes: string[]?

  @description('Optional. Management group scopes for the Network Manager.')
  managementGroupScopes: string[]?

  @description('Optional. Security Admin Configurations requires enabling the "SecurityAdmin" feature on Network Manager. A security admin configuration contains a set of rule collections. Each rule collection contains one or more security admin rules. You then associate the rule collection with the network groups that you want to apply the security admin rules to.')
  securityAdminConfigurations: securityAdminConfigurationType[]?

  @description('Conditional. Network Groups and static members to create for the network manager. Required if using "connectivityConfigurations" or "securityAdminConfigurations" parameters. A network group is global container that includes a set of virtual network resources from any region. Then, configurations are applied to target the network group, which applies the configuration to all members of the group. The two types are group memberships are static and dynamic memberships. Static membership allows you to explicitly add virtual networks to a group by manually selecting individual virtual networks, and is available as a child module, while dynamic membership is defined through Azure policy. See [How Azure Policy works with Network Groups](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-azure-policy-integration) for more details.')
  networkGroups: networkGroupType[]?

  @description('Required. IPAM Root Settings.')
  ipamRootSettings: ipamRootType
}

type ipamRootType = {
  @minLength(1)
  @maxLength(64)
  @description('Required. Name of the root IPAM pool.')
  rootIpamPoolName: string

  @minLength(9)
  @maxLength(18)
  @description('Required. CIDR block for the Azure Supernet.')
  azureCidr: string

  @maxValue(32)
  @minValue(8)
  @description('Required. CIDR size for the region IPAM pools.')
  regionCidrSize: int

  @maxValue(32)
  @minValue(8)
  @description('Required. CIDR split size for the region IPAM pools.')
  regionLzCidrSize: int
}

@maxLength(16)
type ipamRegionType = {
  @minLength(1)
  @maxLength(64)
  @description('Required. Name of the Azure region.')
  name: string

  @minLength(1)
  @maxLength(256)
  @description('Required. Display name of the Azureregion.')
  displayName: string

  @maxValue(100)
  @minValue(0)
  @description('Required. Factor to divide the Azureregion CIDR into platform and application landing zones, in percentage.')
  platformAndApplicationSplitFactor: int

  @minLength(9)
  @maxLength(18)
  @description('Required. CIDR block for the Azure region.')
  cidr: string
}[]

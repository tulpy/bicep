// Core Landing Zone User Defined Types for Azure Services https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/user-defined-data-types
import {
  lockType
  roleAssignmentType
} from 'br/public:avm/utl/types/avm-common-types:0.6.1' // Common Types including Locks, Managed Identities, Role Assignments, etc.

///////////////////////////////////////////////

// 1.0 Core Landing Zone Types
// 1.1 Resource Tags
// 1.2 Azure Virtual Network Type (Subnets / Peering / vWAN Peering / Security Rules / Route Table)
// 1.3 Azure Action Group Type
// 1.4 Azure Budget Type
// 1.5 Role Assignment Types
// 1.6 Privileged Identity Management Role Assignment Types
// 1.7 Azure Storage Account Type
// 1.8 Azure Key Vault Type
// 1.9 Azure User Assigned Identity Type

///////////////////////////////////////////////

// 1.0 Core Landing Zone Types
// 1.1 Resource Tags Type
@export()
@description('The type for Azure Resource tags.')
type tagsType = {
  applicationName: string
  contactEmail: string
  costCenter: string
  criticality: 'Tier0' | 'Tier1' | 'Tier2' | 'Tier3'
  dataClassification: 'Internal' | 'Confidential' | 'Secret' | 'Top Secret'
  environment: 'sbx' | 'dev' | 'tst' | 'prd' | 'idam' | 'mgmt' | 'conn' | 'sec'
  iac: 'Bicep'
  owner: string
  *: string
}

// 1.2 Azure Virtual Network Type
@export()
@description('The type for Azure Virtual Network configuration.')
type virtualNetworkType = {
  @minLength(1)
  @maxLength(64)
  @description('Optional. The name of the virtual network resource.')
  name: string?

  @description('Required. The address prefix of the virtual network to create.')
  addressPrefixes: array

  @description('Required. The location of the virtual network.')
  location: string

  @description('Optional. Number of IP addresses allocated from the pool. To be used only when the addressPrefix param is defined with a resource ID of an IPAM pool.')
  ipamPoolNumberOfIpAddresses: string?

  @description('Optional. The DDoS protection plan ID to associate with the virtual network.')
  ddosProtectionPlanId: string?

  @description('Optional. DNS Servers associated to the Virtual Network.')
  dnsServers: string[]?

  @description('Optional. A value indicating whether this route overrides overlapping BGP routes regardless of LPM.')
  disableBgpRoutePropagation: bool?

  @description('Optional. The resource ID of the hub virtual network or virtual hub to peer with.')
  hubVirtualNetworkResourceId: string?

  @description('Required. The subnet type.')
  subnets: subnetType

  @description('Required. Deploy VNet peering for the virtual network.')
  deployPeering: bool

  @description('Optional. Virtual Network Peering configurations.')
  peeringSettings: peeringSettingsType?

  @description('Optional. The lock settings of the service.')
  lock: lockType?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType[]?
}

@description('The type for subnets within a virtual network.')
type subnetType = {
  @minLength(1)
  @maxLength(80)
  @description('Required. The Name of the subnet resource.')
  name: string

  @description('Conditional. The address prefix for the subnet. Required if `addressPrefixes` is empty.')
  addressPrefix: string?

  @description('Conditional. List of address prefixes for the subnet. Required if `addressPrefix` is empty.')
  addressPrefixes: string[]?

  @description('Conditional. The address space for the subnet, deployed from IPAM Pool. Required if `addressPrefixes` and `addressPrefix` is empty and the VNet address space configured to use IPAM Pool.')
  ipamPoolPrefixAllocations: [
    {
      @description('Required. The Resource ID of the IPAM pool.')
      pool: {
        @description('Required. The Resource ID of the IPAM pool.')
        id: string
      }
      @description('Required. Number of IP addresses allocated from the pool.')
      numberOfIpAddresses: string
    }
  ]?

  @description('Optional. Application gateway IP configurations of virtual network resource.')
  applicationGatewayIPConfigurations: object[]?

  @description('Optional. The delegation to enable on the subnet.')
  delegation: string?

  @description('Optional. The resource ID of the NAT Gateway to use for the subnet.')
  natGatewayResourceId: string?

  @description('Optional. The resource ID of the network security group to assign to the subnet.')
  networkSecurityGroupResourceId: string?

  @description('Optional. enable or disable apply network policies on private endpoint in the subnet.')
  privateEndpointNetworkPolicies: ('Disabled' | 'Enabled' | 'NetworkSecurityGroupEnabled' | 'RouteTableEnabled')?

  @description('Optional. enable or disable apply network policies on private link service in the subnet.')
  privateLinkServiceNetworkPolicies: ('Disabled' | 'Enabled')?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType[]?

  @description('Optional. The resource ID of the route table to assign to the subnet.')
  routeTableResourceId: string?

  @description('Optional. An array of custom routes.')
  routes: routes?

  @description('Optional. The security group rules to apply to the subnet.')
  securityRules: securityRules?

  @description('Optional. An array of service endpoint policies.')
  serviceEndpointPolicies: object[]?

  @description('Optional. The service endpoints to enable on the subnet.')
  serviceEndpoints: string[]?

  @description('Optional. Set this property to false to disable default outbound connectivity for all VMs in the subnet. This property can only be set at the time of subnet creation and cannot be updated for an existing subnet.')
  defaultOutboundAccess: bool?

  @description('Optional. Set this property to Tenant to allow sharing subnet with other subscriptions in your AAD tenant. This property can only be set if defaultOutboundAccess is set to false, both properties can only be set if subnet is empty.')
  sharingScope: ('DelegatedServices' | 'Tenant')?
}[]

@description('The type for Route Table routes.')
type routes = {
  @description('Required. Name of the route table route.')
  name: string

  @description('Required. Properties of the route table route.')
  properties: {
    @description('Required. The type of Azure hop the packet should be sent to.')
    nextHopType: ('VirtualAppliance' | 'VnetLocal' | 'Internet' | 'VirtualNetworkGateway' | 'None')

    @description('Optional. The destination CIDR to which the route applies.')
    addressPrefix: string?

    @description('Optional. A value indicating whether this route overrides overlapping BGP routes regardless of LPM.')
    hasBgpOverride: bool?

    @description('Optional. The IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance.')
    nextHopIpAddress: string?
  }
}[]?

@description('The type for NSG security Rules.')
type securityRules = {
  @description('Required. The name of the security rule.')
  name: string

  @description('Required. The properties of the security rule.')
  properties: {
    @description('Required. Whether network traffic is allowed or denied.')
    access: ('Allow' | 'Deny')

    @description('Optional. The description of the security rule.')
    description: string?

    @description('Optional. The destination address prefix. CIDR or destination IP range. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used.')
    destinationAddressPrefix: string?

    @description('Optional. The destination address prefixes. CIDR or destination IP ranges.')
    destinationAddressPrefixes: string[]?

    @description('Optional. The resource IDs of the application security groups specified as destination.')
    destinationApplicationSecurityGroupResourceIds: string[]?

    @description('Optional. The destination port or range. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports.')
    destinationPortRange: string?

    @description('Optional. The destination port ranges.')
    destinationPortRanges: string[]?

    @description('Required. The direction of the rule. The direction specifies if rule will be evaluated on incoming or outgoing traffic.')
    direction: ('Inbound' | 'Outbound')

    @minValue(100)
    @maxValue(4096)
    @description('Required. Required. The priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule.')
    priority: int

    @description('Required. Network protocol this rule applies to.')
    protocol: ('Ah' | 'Esp' | 'Icmp' | 'Tcp' | 'Udp' | '*')

    @description('Optional. The CIDR or source IP range. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used. If this is an ingress rule, specifies where network traffic originates from.')
    sourceAddressPrefix: string?

    @description('Optional. The CIDR or source IP ranges.')
    sourceAddressPrefixes: string[]?

    @description('Optional. The resource IDs of the application security groups specified as source.')
    sourceApplicationSecurityGroupResourceIds: string[]?

    @description('Optional. The source port or range. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports.')
    sourcePortRange: string?

    @description('Optional. The source port ranges.')
    sourcePortRanges: string[]?
  }
}[]?

// Azure Virtual Network Peering Type
@export()
@description('The type for peering configuration.')
type peeringSettingsType = {
  @description('Optional. The Name of VNET Peering resource. If not provided, default value will be peer-localVnetName-remoteVnetName.')
  name: string?

  @description('Optional. Whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network. Default is true.')
  allowForwardedTraffic: bool?

  @description('Optional. If gateway links can be used in remote virtual networking to link to this virtual network. Default is false.')
  allowGatewayTransit: bool?

  @description('Optional. Whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space. Default is true.')
  allowVirtualNetworkAccess: bool?

  @description('Optional. Do not verify the provisioning state of the remote gateway. Default is true.')
  doNotVerifyRemoteGateways: bool?

  @description('Optional. If remote gateways can be used on this virtual network. If the flag is set to true, and allowGatewayTransit on remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway. Default is false.')
  useRemoteGateways: bool?

  @description('Optional. Deploy the outbound and the inbound peering.')
  remotePeeringEnabled: bool?

  @description('Optional. The name of the VNET Peering resource in the remove Virtual Network. If not provided, default value will be peer-remoteVnetName-localVnetName.')
  remotePeeringName: string?

  @description('Optional. Whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network. Default is true.')
  remotePeeringAllowForwardedTraffic: bool?

  @description('Optional. If gateway links can be used in remote virtual networking to link to this virtual network. Default is false.')
  remotePeeringAllowGatewayTransit: bool?

  @description('Optional. Whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space. Default is true.')
  remotePeeringAllowVirtualNetworkAccess: bool?

  @description('Optional. Do not verify the provisioning state of the remote gateway. Default is true.')
  remotePeeringDoNotVerifyRemoteGateways: bool?

  @description('Optional. If remote gateways can be used on this virtual network. If the flag is set to true, and allowGatewayTransit on remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway. Default is false.')
  remotePeeringUseRemoteGateways: bool?
}?

@export()
@description('The type for Azure Virtual WAN peering configuration (vWAN).')
type vwanPeeringType = {
  @description('Optional. Whether to create virtual hub connection.')
  enabled: bool?

  @description('Optional. Enable internet security.')
  enableInternetSecurity: bool?

  @description('Optional. Indicates whether routing intent is enabled on the Virtual HUB within the virtual WAN.')
  routingIntentEnabled: bool?

  @description('Optional. The resource ID of the virtual hub route table to associate to the virtual hub connection (this virtual network). If left blank/empty default route table will be associated.')
  associatedRouteTableResourceId: string?

  @description('Optional. An array of virtual hub route table resource IDs to propagate routes to. If left blank/empty default route table will be propagated to only.')
  propagatedRouteTablesResourceIds: array[]

  @description('Optional. An array of virtual hub route table labels to propagate routes to. If left blank/empty default label will be propagated to only.')
  propagatedLabels: array[]
}

// 1.3 Azure Action Group Type
@export()
@description('The type for Azure Action Group configuration.')
type actionGroupType = {
  @minLength(1)
  @maxLength(260)
  @description('Optional. The name of the Action Group.')
  name: string?

  @description('Optional. The shortname of the Action Group.')
  groupShortName: string?

  @description('Optional. The list of email receivers that are part of this action group.')
  emailReceivers: array?

  @description('Optional. Tags of the resource.')
  tags: resourceInput<'Microsoft.Insights/actionGroups@2024-10-01-preview'>.tags?

  @description('Optional. The lock settings of the service.')
  lock: lockType?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType[]?
}

// 1.4 Azure Budget Type
@export()
@description('The type for Azure Budgets')
type budgetType = {
  budgets: {
    @minLength(1)
    @maxLength(63)
    @description('Required. The name of the budget.')
    name: string

    @description('Optional. The category of the budget, whether the budget tracks cost or usage.')
    category: ('Cost' | 'Usage')?

    @description('Optional. The start date for the budget. Start date should be the first day of the month and cannot be in the past (except for the current month).')
    startDate: string?

    @description('Required. The total amount of cost or usage to track with the budget.')
    amount: int

    @description('Optional. The type of threshold to use for the budget. The threshold type can be either `Actual` or `Forecasted`.')
    thresholdType: ('Actual' | 'Forecasted')?

    @maxLength(5)
    @description('Optional. Percent thresholds of budget for when to get a notification. Can be up to 5 thresholds, where each must be between 1 and 1000.')
    thresholds: array?

    @description('Conditional. The list of email addresses to send the budget notification to when the thresholds are exceeded. Required if neither `contactRoles` nor `actionGroups` was provided.')
    contactEmails: array?
  }[]
}

// 1.5 Role Assignment Types
@export()
@description('The type for Role Assignment configuration.')
type roleAssignmentsType = roleAssignments[]?

@description('The type for Role Assignments.')
type roleAssignments = {
  @description('Optional. The name (as GUID) of the role assignment. If not provided, a GUID will be generated.')
  name: string?

  @description('Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: ('ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device')?

  @description('Optional. The description of the role assignment.')
  description: string?

  @maxLength(36)
  @description('Subscription ID of the subscription to assign the RBAC role to. If no Resource Group name is provided, the module deploys at subscription level, therefore assigns the provided RBAC role to the subscription.')
  subscriptionId: string?

  @description('Name of the Resource Group to assign the RBAC role to. If Resource Group name is provided, and Subscription ID is provided, the module deploys at resource group level, therefore assigns the provided RBAC role to the resource group.')
  resourceGroupName: string?

  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".')
  condition: string?

  @description('Optional. Version of the condition.')
  conditionVersion: '2.0'?

  @description('Optional. The Resource Id of the delegated managed identity resource.')
  delegatedManagedIdentityResourceId: string?
}

// 1.6 Privileged Identity Management Role Assignment Types
import {
  requestTypeType
  ticketInfoType
} from 'br/public:avm/ptn/authorization/pim-role-assignment:0.1.2'
@export()
@description('The type for Privileged Identity Management role assignment configuration.')
type pimRoleAssignmentsType = pimRoleAssignments[]?

@description('The type for Privileged Identity Management role assignment.')
type pimRoleAssignments = {
  @description('Principal (user or service principal) object ID.')
  principalId: string

  @description('Required. You can provide either the display name of the role definition (must be configured in the variable `builtInRoleNames`), or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
  roleDefinitionIdOrName: string

  @description('Optional. Name of the Resource Group to assign the RBAC role to. If Resource Group name is provided, and Subscription ID is provided, the module deploys at resource group level, therefore assigns the provided RBAC role to the resource group.')
  resourceGroupName: string?

  @description('Optional. Subscription ID of the subscription to assign the RBAC role to. If no Resource Group name is provided, the module deploys at subscription level, therefore assigns the provided RBAC role to the subscription.')
  subscriptionId: string?

  @description('Optional. Group ID of the Management Group to assign the RBAC role to. If not provided, will use the current scope for deployment.')
  managementGroupId: string?

  @description('Required. The type of the PIM role assignment whether its active or eligible.')
  pimRoleAssignmentType: object

  @description('Optional. The justification for the role eligibility.')
  justification: string?

  @description('Required. The type of the role assignment eligibility request.')
  requestType: requestTypeType

  @description('Optional. The resultant role eligibility assignment id or the role eligibility assignment id being updated.')
  targetRoleEligibilityScheduleId: string?

  @description('Optional. The role eligibility assignment instance id being updated.')
  targetRoleEligibilityScheduleInstanceId: string?

  @description('Optional. The resultant role assignment schedule id or the role assignment schedule id being updated.')
  targetRoleAssignmentScheduleId: string?

  @description('Optional. The role assignment schedule instance id being updated.')
  targetRoleAssignmentScheduleInstanceId: string?

  @description('Optional. Ticket Info of the role eligibility.')
  ticketInfo: ticketInfoType?

  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to.')
  condition: string?

  @description('Optional. Version of the condition. Currently accepted value is "2.0".')
  conditionVersion: ('2.0')?
}

// 1.7 Azure Storage Account Type
import {
  networkAclsType as storageNetworkAclsType
  secretsExportConfigurationType as storageSecretsExportConfigurationType
  localUserType
} from 'br/public:avm/res/storage/storage-account:0.30.0'
@export()
@description('The type for Azure Storage Account configuration.')
type storageAccountType = {
  @maxLength(24)
  @description('Name of the Storage Account. Must be lower-case.')
  name: string?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType[]?

  @description('Optional. The lock settings of the service.')
  lock: lockType?

  @description('Optional. Type of Storage Account to create.')
  kind: 'StorageV2' | 'Storage' | 'BlobStorage' | 'FileStorage' | 'BlockBlobStorage'?

  @description('Optional. Storage account SKU. Defaults to \'Standard_ZRS\'.')
  sku:
    | 'Standard_LRS'
    | 'Standard_ZRS'
    | 'Standard_GRS'
    | 'Standard_GZRS'
    | 'Standard_RAGRS'
    | 'Standard_RAGZRS'
    | 'StandardV2_LRS'
    | 'StandardV2_ZRS'
    | 'StandardV2_GRS'
    | 'StandardV2_GZRS'
    | 'Premium_LRS'
    | 'Premium_ZRS'
    | 'PremiumV2_LRS'
    | 'PremiumV2_ZRS'

  @description('Conditional. Required if the Storage Account kind is set to BlobStorage. The access tier is used for billing. The "Premium" access tier is the default value for premium block blobs storage account type and it cannot be changed for the premium block blobs storage account type.')
  accessTier: 'Hot' | 'Cool' | 'Cold' | 'Premium'

  @description('Optional. Allow large file shares if set to \'Enabled\'. It cannot be disabled once it is enabled. Only supported on locally redundant and zone redundant file shares. It cannot be set on FileStorage storage accounts (storage accounts for premium file shares).')
  largeFileSharesState: 'Disabled' | 'Enabled'?

  @description('Optional. Provides the identity based authentication settings for Azure Files.')
  azureFilesIdentityBasedAuthentication: resourceInput<'Microsoft.Storage/storageAccounts@2024-01-01'>.properties.azureFilesIdentityBasedAuthentication?

  @description('Optional. A boolean flag which indicates whether the default authentication is OAuth or not.')
  defaultToOAuthAuthentication: bool?

  @description('Optional. Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). The default value is null, which is equivalent to true.')
  allowSharedKeyAccess: bool?

  @description('Optional. The Storage Account ManagementPolicies Rules.')
  managementPolicyRules: array?

  @description('Optional. Networks ACLs, this value contains IPs to whitelist and/or Subnet information. If in use, bypass needs to be supplied. For security reasons, it is recommended to set the DefaultAction Deny.')
  networkAcls: storageNetworkAclsType?

  @description('Optional. A Boolean indicating whether or not the service applies a secondary layer of encryption with platform managed keys for data at rest. For security reasons, it is recommended to set it to true.')
  requireInfrastructureEncryption: bool?

  @description('Optional. Allow or disallow cross AAD tenant object replication.')
  allowCrossTenantReplication: bool?

  @description('Optional. Sets the custom domain name assigned to the storage account. Name is the CNAME source.')
  customDomainName: string?

  @description('Optional. Indicates whether indirect CName validation is enabled. This should only be set on updates.')
  customDomainUseSubDomainName: bool?

  @description('Optional. Allows you to specify the type of endpoint. Set this to AzureDNSZone to create a large number of accounts in a single subscription, which creates accounts in an Azure DNS Zone and the endpoint URL will have an alphanumeric DNS Zone identifier.')
  dnsEndpointType: 'AzureDnsZone' | 'Standard'?

  @description('Optional. Indicates whether public access is enabled for all blobs or containers in the storage account. For security reasons, it is recommended to set it to false.')
  allowBlobPublicAccess: bool?

  @description('Optional. Set the minimum TLS version on request to storage. The TLS versions 1.0 and 1.1 are deprecated and not supported anymore.')
  minimumTlsVersion: 'TLS1_2'

  @description('Conditional. If true, enables Hierarchical Namespace for the storage account. Required if enableSftp or enableNfsV3 is set to true.')
  enableHierarchicalNamespace: bool?

  @description('Optional. If true, enables Secure File Transfer Protocol for the storage account. Requires enableHierarchicalNamespace to be true.')
  enableSftp: bool?

  @description('Optional. Local users to deploy for SFTP authentication.')
  localUsers: localUserType[]?

  @description('Optional. Enables local users feature, if set to true.')
  isLocalUserEnabled: bool?

  @description('Optional. If true, enables NFS 3.0 support for the storage account. Requires enableHierarchicalNamespace to be true.')
  enableNfsV3: bool?

  @description('Optional. Tags of the resource.')
  tags: resourceInput<'Microsoft.Storage/storageAccounts@2024-01-01'>.tags?

  @description('Optional. Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet.')
  allowedCopyScope: 'AAD' | 'PrivateLink'?

  @description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkAcls are not set.')
  publicNetworkAccess: 'Enabled' | 'Disabled'?

  @description('Optional. Allows HTTPS traffic only to storage service if sets to true.')
  supportsHttpsTrafficOnly: bool?

  @description('Optional. The SAS expiration period. DD.HH:MM:SS.')
  sasExpirationPeriod: string?

  @description('Optional. The SAS expiration action. Allowed values are Block and Log.')
  sasExpirationAction: 'Log' | 'Block'?

  @description('Optional. The keyType to use with Queue & Table services.')
  keyType: 'Account' | 'Service'?

  @description('Optional. Key vault reference and secret settings for the module\'s secrets export.')
  secretsExportConfiguration: storageSecretsExportConfigurationType?
}

// 1.8 Azure Key Vault Type
import {
  networkAclsType as keyVaultNetworkAclsType
  accessPolicyType
  secretType
} from 'br/public:avm/res/key-vault/vault:0.13.3'
@export()
@description('The type for Azure Key Vault configuration.')
type keyVaultType = {
  @minLength(3)
  @maxLength(24)
  @description('Optional. Name of the Azure Key Vault. Must be globally unique.')
  name: string?

  @description('Optional. Specifies the SKU for the vault.')
  sku: ('standard' | 'premium')?

  @description('Optional. Switch to enable/disable Key Vault\'s soft delete feature.')
  enableSoftDelete: bool?

  @description('Optional. Property that controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, and the access policies specified in vault properties will be ignored. When false, the key vault will use the access policies specified in vault properties, and any policy stored on Azure Resource Manager will be ignored. Note that management actions are always authorized with RBAC.')
  enableRbacAuthorization: bool?

  @description('Optional. The vault\'s create mode to indicate whether the vault need to be recovered or not. - recover or default.')
  createMode: ('default' | 'recover')?

  @minValue(7)
  @maxValue(90)
  @description('Optional. softDelete data retention days. It accepts >=7 and <=90.')
  softDeleteRetentionInDays: int?

  @description('Optional. Provide \'true\' to enable Key Vault\'s purge protection feature.')
  enablePurgeProtection: bool?

  @description('Optional. This value can be set to \'Enabled\' to avoid breaking changes on existing customer resources and templates. If set to \'Disabled\', traffic over public interface is not allowed, and private endpoint connections would be the exclusive access method.')
  publicNetworkAccess: ('Enabled' | 'Disabled' | '')?

  @description('Optional. All access policies to create.')
  accessPolicies: accessPolicyType[]?

  @description('Optional. All secrets to create.')
  secrets: secretType[]?

  @description('Optional. Rules governing the accessibility of the resource from specific network locations.')
  networkAcls: keyVaultNetworkAclsType?

  @description('Optional. Resource tags.')
  tags: resourceInput<'Microsoft.KeyVault/vaults@2024-11-01'>.tags?

  @description('Optional. The lock settings of the service.')
  lock: lockType?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType[]?
}

// 1.9 Azure User Assigned Identity Type
@export()
@description('The type for Azure User Assigned Identity configuration.')
type userAssignedIdentityType = {
  @minLength(5)
  @maxLength(128)
  @description('Optional. The name of the User Assigned Identity.')
  name: string?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType[]?

  @description('Optional. The lock settings of the service.')
  lock: lockType?

  @description('Required. The name of the resource group containing the user assigned identity.')
  resourceGroupName: string

  @description('Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: /providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11')
  roleDefinitionIdOrName: string
}

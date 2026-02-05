// Workload Landing Zone User Defined Types for Azure Services https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/user-defined-data-types
import * as commonTypes from 'br/public:avm/utl/types/avm-common-types:0.6.1' // Common Types including Locks, Managed Identities, Role Assignments, etc.

///////////////////////////////////////////////

// 1.0 Workload Landing Zone Types
// 1.1 Azure Virtual Machine Type
// 1.2 Azure Recovery Services Vault Type

///////////////////////////////////////////////

// 1.0 Workload Landing Zone Types
// 1.1 Azure Virtual Machine Type
import {
  nicConfigurationType
  imageReferenceType
  planType
  osDiskType
  dataDiskType
} from 'br/public:avm/res/compute/virtual-machine:0.20.0'
@export()
@description('The type for Azure Virtual Machine configuration.')
type virtualMachineType = {
  @maxLength(15)
  @description('Required. The name of the virtual machine to be created. You should use a unique prefix to reduce name collisions in Active Directory.')
  name: string

  @description('Required. If set to 1, 2 or 3, the availability zone is hardcoded to that value. If set to -1, no zone is defined. Note that the availability zone numbers here are the logical availability zone in your Azure subscription. Different subscriptions might have a different mapping of the physical zone and logical zone. To understand more, please refer to [Physical and logical availability zones](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview?tabs=azure-cli#physical-and-logical-availability-zones).')
  availabilityZone: (-1 | 1 | 2 | 3)

  @description('Required. Specifies the size for the VMs.')
  vmSize: string

  @description('Conditional. The username for the administrator account on the virtual machine. Required if a virtual machine is created as part of the module.')
  adminUsername: string

  @description('Conditional. The password for the administrator account on the virtual machine. Required if a virtual machine is created as part of the module.')
  @secure()
  adminPassword: string?

  @description('Required. Configures NICs and PIPs.')
  nicConfigurations: nicConfigurationType[]

  @description('Optional. This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to \'true\'.')
  encryptionAtHost: bool?

  @description('Optional. Specifies the SecurityType of the virtual machine. It has to be set to any specified value to enable UefiSettings. The default behavior is: UefiSettings will not be enabled unless this property is set.')
  securityType: 'confidentialVM' | 'trustedLaunch' | ''?

  @description('Optional. Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. SecurityType should be set to TrustedLaunch to enable UefiSettings.')
  secureBootEnabled: bool?

  @description('Optional. Indicates whether Automatic Updates is enabled for the Windows virtual machine. Default value is true. When patchMode is set to Manual, this parameter must be set to false. For virtual machine scale sets, this property can be updated and updates will take effect on OS reprovisioning.')
  enableAutomaticUpdates: bool?

  @description('Optional. Specifies whether vTPM should be enabled on the virtual machine. This parameter is part of the UefiSettings.  SecurityType should be set to TrustedLaunch to enable UefiSettings.')
  vTpmEnabled: bool?

  @description('Required. OS image reference. In case of marketplace images, it\'s the combination of the publisher, offer, sku, version attributes. In case of custom images it\'s the resource ID of the custom image.')
  imageReference: imageReferenceType

  @description('Optional. Specifies information about the marketplace image used to create the virtual machine. This element is only used for marketplace images. Before you can use a marketplace image from an API, you must enable the image for programmatic use.')
  plan: planType?

  @description('Required. Specifies the OS disk. For security reasons, it is recommended to specify DiskEncryptionSet into the osDisk object.  Restrictions: DiskEncryptionSet cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
  osDisk: osDiskType

  @description('Optional. Specifies the data disks. For security reasons, it is recommended to specify DiskEncryptionSet into the dataDisk object. Restrictions: DiskEncryptionSet cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
  dataDisks: dataDiskType[]?

  @description('Optional. Specifies that the image or disk that is being used was licensed on-premises.')
  licenseType: ('RHEL_BYOS' | 'SLES_BYOS' | 'Windows_Client' | 'Windows_Server')?

  @description('Optional. VM guest patching orchestration mode. Refer to \'https://learn.microsoft.com/en-us/azure/virtual-machines/automatic-vm-guest-patching\'.')
  patchMode: 'AutomaticByPlatform' | 'AutomaticByOS' | 'Manual'?

  @description('Optional. Whether to enable the Microsoft.Azure.ActiveDirectory AADLoginForWindows extension, allowing users to log in to the virtual machine using Microsoft Entra. Defaults to \'false\'.')
  enableAadLoginExtension: bool?

  @description('Optional. Whether to enable the Microsoft.Azure.Monitor AzureMonitorWindowsAgent extension. Defaults to \'false\'.')
  enableAzureMonitorAgent: bool?

  @description('Required. The chosen OS type.')
  osType: 'Windows' | 'Linux'

  @description('Optional. The resource Id of a maintenance configuration for the virtual machine.')
  maintenanceConfigurationResourceId: string?

  @description('Optional. Tags of the resource.')
  tags: resourceInput<'Microsoft.Compute/virtualMachines@2024-11-01'>.tags?

  @description('Optional. The lock settings of the service.')
  lock: commonTypes.lockType?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: commonTypes.roleAssignmentType[]?
}

// 1.2 Azure Recovery Services Vault Type
import {
  backupPolicyType
  backupConfigType
  protectedItemType
  replicationFabricType
  replicationPolicyType
  replicationAlertSettingsType
  monitoringSettingsType
  softDeleteSettingType
  redundancySettingsType
  restoreSettingsType
} from 'br/public:avm/res/recovery-services/vault:0.10.1'
@export()
@description('The type for Azure Recovery Services Vault configuration.')
type recoveryVaultType = {
  @description('Optional. Name of the Azure Recovery Service Vault.')
  name: string?

  @description('Optional. List of all backup policies.')
  backupPolicies: backupPolicyType[]?

  @description('Optional. The backup configuration.')
  backupConfig: backupConfigType?

  @description('Optional. List of all protection containers.')
  protectedItems: protectedItemType[]?

  @description('Optional. List of all replication fabrics.')
  replicationFabrics: replicationFabricType[]?

  @description('Optional. List of all replication policies.')
  replicationPolicies: replicationPolicyType[]?

  @description('Optional. Replication alert settings.')
  replicationAlertSettings: replicationAlertSettingsType?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: commonTypes.roleAssignmentType[]?

  @description('Optional. The lock settings of the service.')
  lock: commonTypes.lockType?

  @description('Optional. Tags of the Recovery Service Vault resource.')
  tags: resourceInput<'Microsoft.RecoveryServices/vaults@2024-04-01'>.tags?

  @description('Optional. Monitoring Settings of the vault.')
  monitoringSettings: monitoringSettingsType?

  @description('Optional. The soft delete related settings.')
  softDeleteSettings: softDeleteSettingType?

  @description('Optional. The immmutability setting state of the recovery services vault resource.')
  immutabilitySettingState: 'Disabled' | 'Locked' | 'Unlocked'?

  @description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled.')
  publicNetworkAccess: 'Disabled' | 'Enabled'?

  @description('Optional. The redundancy settings of the vault.')
  redundancySettings: redundancySettingsType?

  @description('Optional. The restore settings of the vault.')
  restoreSettings: restoreSettingsType?
}

param location string = resourceGroup().location

@description('Name of the managed application definition.')
param managedApplicationDefinitionName string = 'tulpyManagedApplication'

@description('The URI of the .zip package file.')
param packageFileUri string

@description('Publishers Principal ID that needs permissions to manage resources in the managed resource group.')
param principalId string

@description('Role ID for permissions to the managed resource group.')
param roleId string

var definitionLockLevel = 'ReadOnly'
var definitionDisplayName = 'Sample Bicep managed application'
var definitionDescription = 'Sample Bicep managed application that deploys web resources'

resource managedApplicationDefinition 'Microsoft.Solutions/applicationDefinitions@2021-07-01' = {
  name: managedApplicationDefinitionName
  location: location
  properties: {
    lockLevel: definitionLockLevel
    description: definitionDescription
    displayName: definitionDisplayName
    packageFileUri: packageFileUri
    authorizations: [
      {
        principalId: principalId
        roleDefinitionId: roleId
      }
    ]
  }
}

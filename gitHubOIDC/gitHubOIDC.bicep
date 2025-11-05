extension microsoftGraphV1

targetScope = 'managementGroup'

metadata name = 'GitHub OIDC Creation '
metadata description = 'GitHub OIDC setup, including Microsoft Entra Enterprise Apps and Service Principals, Federated Identity Credentials and Azure Role Assignments.'
metadata version = '1.0.0'
metadata author = 'Insight APAC Platform Engineering'

@description('The type for GitHub OIDC configuration.')
type gitHubOIDCType = {
  @maxLength(256)
  @description('Required. The unique identifier that can be assigned to an application and used as an alternate key. Immutable.')
  applicationName: string

  @maxLength(256)
  @description('Required. The display name for the application. Maximum length is 256 characters.')
  applicationDisplayName: string

  @maxLength(600)
  @description('Optional. The unvalidated description of the federated identity credential, provided by the user. It has a limit of 600 characters.')
  ficDescription: string?

  @description('Required. You can provide either the display name of the role definition (must be configured in the variable `builtInRoleNames`), or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
  roleDefinitions: array

  @description('Required. The name of the GitHub environment, should be lowercase and underscore-separated.')
  gitHubEnvironment: string

  @maxLength(90)
  @description('Required. The group IDs of the Management groups.')
  managementGroupIds: array
}

@description('Required. Configuration for GitHub OIDC workload identities')
param gitHubConfiguration gitHubOIDCType[]

@description('Optional. The Azure Region to deploy the resources into.')
param location string = deployment().location

@description('Required. The owner of the Github organisation that is assigned to a workload identity')
param gitHubOwner string

@description('Required. The GitHub repository that is assigned to a workload identity')
param gitHubRepo string

//Variables
var githubOIDCProvider = 'https://token.actions.githubusercontent.com'
var microsoftEntraAudience = 'api://AzureADTokenExchange'

// Flatten role assignments: create one entry for each management group and role definition combination in each configuration
var flattenedGitHubConfiguration = flatten(map(
  range(0, length(gitHubConfiguration)),
  i => flatten(
    map(range(0, length(gitHubConfiguration[i].managementGroupIds)), k =>
      map(range(0, length(gitHubConfiguration[i].roleDefinitions)), j => {
        configIndex: i
        managementGroupIndex: k
        roleIndex: j
        applicationName: gitHubConfiguration[i].applicationName
        managementGroupId: gitHubConfiguration[i].managementGroupIds[k]
        roleDefinitions: gitHubConfiguration[i].roleDefinitions[j]
      })
    )
  )
))

@description('Resource: Microsoft Graph Application')
resource identityGithubActionsApplications 'Microsoft.Graph/applications@v1.0' = [
  for (item, i) in gitHubConfiguration: {
    displayName: item.applicationDisplayName
    uniqueName: replace(replace(toLower(item.applicationName), ' ', '-'), '_', '-')
  }
]

@description('Resource: Microsoft Graph Federated Identity Credential')
resource githubFederatedIdentityCredential 'Microsoft.Graph/applications/federatedIdentityCredentials@v1.0' = [
  for (item, i) in gitHubConfiguration: {
    name: '${identityGithubActionsApplications[i].uniqueName}/github-federated-credential-${i}'
    description: gitHubConfiguration[i].?ficDescription ?? ''
    audiences: [
      microsoftEntraAudience
    ]
    issuer: githubOIDCProvider
    subject: 'repo:${gitHubOwner}/${gitHubRepo}:environment:${gitHubConfiguration[i].gitHubEnvironment}'
    dependsOn: [
      identityGithubActionsApplications
    ]
  }
]

@description('Resource: Microsoft Graph Service Principal')
resource githubActionsSp 'Microsoft.Graph/servicePrincipals@v1.0' = [
  for (item, i) in gitHubConfiguration: {
    appId: identityGithubActionsApplications[i].appId
    dependsOn: [
      githubFederatedIdentityCredential
    ]
  }
]

@description('Module: Azure Role Assignments - https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/authorization/role-assignment')
module roleAssignment 'br/public:avm/ptn/authorization/role-assignment:0.2.2' = [
  for (assignment, idx) in flattenedGitHubConfiguration: {
    name: take('roleAssignment-${uniqueString(assignment.applicationName, assignment.roleDefinitions, string(idx))}', 64)
    dependsOn: [
      githubActionsSp
    ]
    params: {
      // Required parameters
      principalId: githubActionsSp[assignment.configIndex].id
      roleDefinitionIdOrName: assignment.roleDefinitions
      // Non-required parameters
      description: 'Role Assignment (management group scope)'
      location: location
      managementGroupId: assignment.managementGroupId
      principalType: 'ServicePrincipal'
    }
  }
]

@description('The Application IDs of the created GitHub Actions applications')
output githubActionsAppIds array = [
  for (item, i) in gitHubConfiguration: {
    applicationName: item.applicationName
    appId: identityGithubActionsApplications[i].appId
    objectId: identityGithubActionsApplications[i].id
  }
]

// Outputs
@description('The Service Principal IDs of the created GitHub Actions service principals')
output githubActionsSpIds array = [
  for (item, i) in gitHubConfiguration: {
    applicationName: item.applicationName
    servicePrincipalId: githubActionsSp[i].id
    servicePrincipalObjectId: githubActionsSp[i].id
  }
]

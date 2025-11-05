using './gitHubOIDC.bicep'

param gitHubOwner = 'Insight-Services-APAC'
param gitHubRepo = 'azure-landing-zones-perth-extended-zone'

param gitHubConfiguration = [
  {
    applicationName: 'app-registration-gh-epac-plan'
    applicationDisplayName: 'app-registration-gh-epac-plan'
    roleDefinitions: [
      'Reader'
    ]
    ficDescription: 'Used to plan Azure Policies using EPAC'
    gitHubEnvironment: 'epac_plan'
    managementGroupIds: [
      'mg-alz-canary'
      'mg-alz'
    ]
  }
  {
    applicationName: 'app-registration-gh-epac-canary'
    applicationDisplayName: 'app-registration-gh-epac-canary'
    roleDefinitions: [
      'Role Based Access Control Administrator'
      'Resource Policy Contributor'
    ]
    ficDescription: 'Used for deployment of Azure Policies and Azure Roles for EPAC Canary'
    gitHubEnvironment: 'epac_canary'
    managementGroupIds: [
      'mg-alz-canary'
    ]
  }
  {
    applicationName: 'app-registration-gh-epac-tenant-policy'
    applicationDisplayName: 'app-registration-gh-epac-tenant-policy'
    roleDefinitions: [
      'Resource Policy Contributor'
    ]
    ficDescription: 'Used for deployment of Azure Policies for EPAC Tenant'
    gitHubEnvironment: 'epac_tenant_policy'
    managementGroupIds: [
      'mg-alz'
    ]
  }
  {
    applicationName: 'app-registration-gh-epac-tenant-roles'
    applicationDisplayName: 'app-registration-gh-epac-tenant-roles'
    roleDefinitions: [
      'Role Based Access Control Administrator'
    ]
    ficDescription: 'Used for deployment of Azure Roles for EPAC tenant'
    gitHubEnvironment: 'epac_tenant_roles'
    managementGroupIds: [
      'mg-alz'
    ]
  }
]

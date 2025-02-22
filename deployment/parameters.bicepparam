using 'br/public:avm/res/resources/resource-group:0.4.1'

// Required parameters
param name = 'test'
// Non-required parameters
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}

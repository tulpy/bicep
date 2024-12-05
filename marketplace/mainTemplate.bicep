param location string = resourceGroup().location

@description('App Service plan name.')
@maxLength(40)
param appServicePlanName string

@description('App Service name prefix.')
@maxLength(47)
param appServiceNamePrefix string

var appServicePlanSku = 'B1'
var appServicePlanCapacity = 1
var appServiceName = '${appServiceNamePrefix}${uniqueString(resourceGroup().id)}'
var linuxFxVersion = 'DOTNETCORE|8.0'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
    capacity: appServicePlanCapacity
  }
  kind: 'linux'
  properties: {
    zoneRedundant: false
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    redundancyMode: 'None'
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
  }
}

output appServicePlan string = appServicePlanName
output appServiceApp string = appService.properties.defaultHostName

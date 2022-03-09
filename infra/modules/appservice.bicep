param name string
param planName string
param planSku string
param appSettings array
param location string

//Describe App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: planName
  location: location
  sku: {
    name: planSku
  }
}

//Describe App Service
resource appService 'Microsoft.Web/sites@2018-11-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      alwaysOn: (planSku == 'F1' || planSku == 'D1') ? null : true
      appSettings: [for appSetting in appSettings: {
        name: appSetting.name
        value: appSetting.value
      }]
    }
  }
}

output name string  = appService.name
output identityPrincipalId string = appService.identity.principalId

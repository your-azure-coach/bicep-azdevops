//Define parameters
@maxLength(3)
param env string
@maxLength(5)
param resourcePrefix string
param appName string
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageAccountSku string
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1v2'
  'P2v2'
  'P3v2'
  'P1v3'
  'P2v3'
  'P3v3'
])
param appServicePlanSku string
param location string = resourceGroup().location

//Define variables
var prefix = '${resourcePrefix}-${env}-${appName}'
var storageAccountName = '${replace(prefix, '-', '')}st'
var appServicePlanName = '${prefix}-plan'
var appServiceName = '${prefix}-app'

var secretName = '${storageAccountName}-connectionstring'
var keyVaultName = '${prefix}-vault'
var keyVaultSoftDelete = env == 'prd' ? true : false

//Describe Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind:  'StorageV2'
}

//Describe App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
  }
}


//Describe App Service
resource appService 'Microsoft.Web/sites@2021-01-15' = {
  name: appServiceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}


//Describe Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    enableRbacAuthorization: true
    enableSoftDelete: keyVaultSoftDelete
    tenantId: subscription().tenantId
    accessPolicies: [
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

//Add Storage Account connection string to Key Vault
resource storageSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: secretName
  parent: keyVault
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys('${resourceGroup().id}/providers/Microsoft.Storage/storageAccounts/${storageAccount.name}','2019-06-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  }
}

//Grant the App Service Key Vault Secrets User rights
resource keyvaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appService.id, 'Key Vault Secrets User')
  scope: keyVault
  properties: {
    principalId: appService.identity.principalId
    roleDefinitionId: '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6'
  }
}

//Configure connection string as a Key Vault reference app setting
resource appSettings 'Microsoft.Web/sites/config@2021-01-15' = {
  name: 'appsettings'
  parent: appService
  properties: {
    'BLOB_STORAGE_CONNECTION_STRING' : '@Microsoft.KeyVault(SecretUri=https://${keyVault.name}${environment().suffixes.keyvaultDns}/secrets/${storageSecret.name}/)'
  }
  dependsOn: [
    keyvaultRoleAssignment
  ]
}


//Configure outputs
output appServiceName string = appServiceName

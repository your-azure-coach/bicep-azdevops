targetScope = 'subscription'

/* ########################################## Parameters ########################################### */
@maxLength(3)
@description('Provide environment abbreviation')
param env string
@description('Provide SKU for storage account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageAccountSku string
@description('Provide SKU for app service plan')
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
  'I1'
  'I2'
  'I3'
  'I1v2'
  'I2v2'
  'I3v2'
])
param appServicePlanSku string
@allowed([
  'westeurope'
  'northeurope'
])
@description('Provide location for all resources')
param location string = 'westeurope'
@description('Provide an URL to the release pipeline')
param releaseUrl string = 'NA'
@description('Provide unique identifier for release')
param releaseId string = newGuid()


/* ########################################## Variables ############################################ */
var applicationName = 'document-api'
var prefix = 'yac-${env}-${applicationName}'
var resourceGroupName = '${prefix}-rg'
var appServiceName = '${prefix}-app'
var appServicePlanName = '${prefix}-app-plan'
var storageAccountName = '${replace(prefix, '-', '')}st'
var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var blobContainers = [
  {
    name: 'manuals'
    enablePublicAccess: true
  }
  {
    name: 'documents'
    enablePublicAccess: false
  }
]


/* ########################################## Resources ############################################ */

//Describe Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01'  = {
  name: resourceGroupName
  location: location
  tags: {
    environment: env
    application: applicationName
    owner: 'toon@yourazurecoach.com'
    releaseUrl: releaseUrl
  }
}

// //Describe Storage Account
// module storageAccount 'modules/storageaccount.bicep' = {
//   scope: resourceGroup
//   name: 'storageAccount-${releaseId}'
//   params: {
//     name: storageAccountName
//     location: location
//     sku: storageAccountSku    
//     blobContainers: blobContainers
//     roleAssignments: [
//       {
//         principalId: appService.outputs.identityPrincipalId
//         roleId: storageBlobDataContributorRoleId
//       }
//     ]
//   }
// }

// //Describe App Service
// module appService 'modules/appservice.bicep' = {
//   scope: resourceGroup
//   name: 'appService-${releaseId}'
//   params: {
//     name: appServiceName
//     planName: appServicePlanName
//     planSku: appServicePlanSku
//     appSettings: [
//       {
//         name: 'STORAGE_ACCOUNT_NAME'
//         value: storageAccountName
//       }
//       {
//         name: 'ASPNETCORE_ENVIRONMENT'
//         value: 'Development'
//       }
//     ]
//     location: location
//   }
// }

/* ########################################## Outputs ############################################ */

output resourceGroupName string = resourceGroupName
output appServiceName string = appServiceName
output appServicePlanName string = appServicePlanName
output storageAccountName string = storageAccountName

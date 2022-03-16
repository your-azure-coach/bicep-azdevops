param name string
param sku string
param location string
param blobContainers array
param roleAssignments array

//Describe storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2' 
}

//Describe blob service and containers
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  name:  'default'
  parent: storageAccount
  resource containers 'containers' = [for container in blobContainers: {
    name: container.name
    properties: {
      publicAccess: (container.enablePublicAccess) ? 'Container' : 'None'
    }
  }]
}

//Describe role assignments
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for roleAssignment in roleAssignments: {
  scope: storageAccount
  name: guid(storageAccount.id, roleAssignment.principalId, roleAssignment.roleId)
  properties: {
    principalId: roleAssignment.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleId)
    principalType: (contains(roleAssignment, 'principalType')) ? roleAssignment.principalType : 'ServicePrincipal'
  }
}]

output name string = storageAccount.name

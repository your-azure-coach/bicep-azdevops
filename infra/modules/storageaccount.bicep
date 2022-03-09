param name string
param sku string
param location string
param blobContainers array

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2' 
}

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

output name string = storageAccount.name

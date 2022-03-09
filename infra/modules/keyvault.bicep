param name string
@secure()
param secrets object = {}
param roleAssignments array = []
param location string

//Describe Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  properties: {
    enableRbacAuthorization: true
    enableSoftDelete: false
    tenantId: subscription().tenantId
    accessPolicies: [
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

//Describe Key Vault Secrets
resource keyVaultSecrets 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = [for secret in items(secrets):{
  name: secret.key
  parent: keyVault
  properties: {
    value: secret.value
  }
}]

//Describe Role Assignments
resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for roleAssignment in roleAssignments: {
  scope: keyVault
  name: guid(keyVault.id, roleAssignment.principalId, roleAssignment.roleId)
  properties: {
    principalId: roleAssignment.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleId)
    principalType: (contains(roleAssignment, 'principalType')) ? roleAssignment.principalType : 'ServicePrincipal'
  }
}]

output name string = keyVault.name

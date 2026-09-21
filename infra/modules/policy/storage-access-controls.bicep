targetScope = 'subscription'

@allowed([ 'audit', 'deny' ])
@description('Policy effect')
param effect string = 'audit'

@description('Policy name')
param policyName string = 'storage-access-controls-policy-14'

@description('Assignment name')
param assignmentName string = '${policyName}-assignment'

resource policyDef 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Audit storage account anonymous blob access and account key access'
    description: 'Ensures storage accounts do not allow anonymous blob access and do not permit shared key access.'
    metadata: {
      category: 'Storage'
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Storage/storageAccounts'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Storage/storageAccounts/allowBlobPublicAccess'
                equals: true
              }
              {
                field: 'Microsoft.Storage/storageAccounts/allowSharedKeyAccess'
                equals: true
              }
            ]
          }
        ]
      }
      then: {
        effect: effect
      }
    }
  }
}

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: assignmentName
  properties: {
    displayName: 'Audit storage account anonymous blob access and account key access'
    policyDefinitionId: policyDef.id
  }
}

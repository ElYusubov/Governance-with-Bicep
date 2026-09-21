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
    displayName: 'Audit storage account access and minimum TLS version'
    description: 'Ensures storage accounts do not allow anonymous blob access, do not permit shared key access, and require TLS 1.2.'
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
              {
                field: 'Microsoft.Storage/storageAccounts/minimumTlsVersion'
                notEquals: 'TLS1_2'
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
    displayName: 'Audit storage account access and minimum TLS version'
    policyDefinitionId: policyDef.id
  }
}

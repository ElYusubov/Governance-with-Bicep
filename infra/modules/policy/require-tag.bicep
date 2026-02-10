targetScope = 'subscription'

@description('Tag name to enforce or audit')
param tagName string = 'Environment'

@allowed([ 'audit', 'deny' ])
@description('Policy effect')
param effect string = 'audit'

@description('Policy name')
param policyName string = 'require-tag-policy-03'

@description('Assignment name')
param assignmentName string = '${policyName}-assignment'

resource policyDef 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Require or audit tag: ${tagName}'
    description: 'Ensures resources include the required tag or flags when missing.'
    metadata: { category: 'Tags' }
    policyRule: {
      if: { field: 'tags[\'${tagName}\']', exists: 'false' }
      then: { effect: effect }
    }
  }
}

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: assignmentName
  properties: {
    displayName: 'Require or audit tag: ${tagName} (assignment)'
    policyDefinitionId: policyDef.id
    enforcementMode: 'Default'
  }
}

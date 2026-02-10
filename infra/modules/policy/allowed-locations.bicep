targetScope = 'subscription'

@description('Allowed locations list')
param allowedLocations array = ['eastus2', 'westus2']

@allowed([ 'audit', 'deny' ])
@description('Policy effect')
param effect string = 'audit'

@description('Policy name')
param policyName string = 'allowed-locations-policy-03'

@description('Assignment name')
param assignmentName string = '${policyName}-assignment'

resource policyDef 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: 'Allowed locations (parameterized)'
    metadata: { category: 'General' }
    policyRule: {
      'if': { 'not': { 'field': 'location', 'in': allowedLocations } }
      'then': { 'effect': effect }
    }
  }
}

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: assignmentName
  properties: {
    displayName: 'Allowed locations assignment'
    policyDefinitionId: policyDef.id
  }
}

targetScope = 'subscription'

@description('List of allowed VM SKUs (e.g., Standard_DS1_v2)')
param allowedSkus array

@allowed([ 'Audit', 'Deny' ])
@description('Policy effect for non-compliant resources')
param effect string = 'Audit'

@description('Policy name')
param policyName string = 'allowed-vm-skus-policy-03'

@description('Assignment name')
param assignmentName string = '${policyName}-assignment'

resource policyDef 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Allowed virtual machine SKUs'
    metadata: { category: 'Compute' }
    parameters: {
      listOfAllowedSKUs: {
        type: 'Array'
        metadata: {
          description: 'The list of VM SKUs that can be specified for virtual machines and scale sets.'
          displayName: 'Allowed VM SKUs'
        }
      }
      effect: {
        type: 'String'
        metadata: {
          description: 'Policy effect for non-compliant resources'
          displayName: 'Effect'
        }
        allowedValues: [
          'Audit'
          'Deny'
        ]
        defaultValue: 'Audit'
      }
    }
    policyRule: {
      'if': {
        'anyOf': [
          { 'allOf': [ { 'field': 'type', 'equals': 'Microsoft.Compute/virtualMachines' }, { 'field': 'Microsoft.Compute/virtualMachines/sku.name', 'notIn': '[parameters(\'listOfAllowedSKUs\')]' } ] }
          { 'allOf': [ { 'field': 'type', 'equals': 'Microsoft.Compute/virtualMachineScaleSets' }, { 'field': 'Microsoft.Compute/virtualMachineScaleSets/sku.name', 'notIn': '[parameters(\'listOfAllowedSKUs\')]' } ] }
        ]
      }
      'then': { 'effect': '[parameters(\'effect\')]' }
    }
  }
}

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: assignmentName
  properties: {
    displayName: 'Allowed virtual machine SKUs (assignment)'
    policyDefinitionId: policyDef.id
    parameters: { 
      listOfAllowedSKUs: { value: allowedSkus }
      effect: { value: effect }
    }
  }
}

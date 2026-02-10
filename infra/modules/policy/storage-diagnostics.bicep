targetScope = 'subscription'

@description('Resource ID of the target Log Analytics workspace')
param logAnalyticsWorkspaceId string = '41ec1d49-6147-4367-924f-00ac9b771345'

@allowed([ 'auditIfNotExists', 'deployIfNotExists' ])
@description('Effect to use for enforcing diagnostics')
param effect string = 'auditIfNotExists'

@description('Name for the diagnostic setting that will be created when enforcing')
param diagnosticSettingName string = 'storage-to-law-03'

@description('Policy name')
param policyName string = 'storage-diagnostics-policy'

@description('Assignment name')
param assignmentName string = '${policyName}-assignment'

@description('Location for the policy assignment (required for managed identity with deployIfNotExists)')
param location string = 'eastus2'

resource policyDef 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Ensure Storage Accounts send diagnostics to Log Analytics'
    description: 'Deploy or audit diagnostic settings on Storage Accounts to send logs and metrics to a specified Log Analytics workspace.'
    metadata: { category: 'Monitoring' }
    parameters: {
      workspaceId: { type: 'String', metadata: { displayName: 'Log Analytics Workspace Resource ID', description: 'Resource ID of the Log Analytics Workspace to receive diagnostics.' } }
      diagName: { type: 'String', metadata: { displayName: 'Diagnostic setting name', description: 'Name of the diagnostic setting to create when enforcing.' } }
    }
    policyRule: {
      'if': { 'field': 'type', 'equals': 'Microsoft.Storage/storageAccounts' }
      'then': {
        'effect': effect
        'details': {
          'type': 'Microsoft.Insights/diagnosticSettings'
          'existenceCondition': { 'field': 'Microsoft.Insights/diagnosticSettings/workspaceId', 'equals': '[parameters(\'workspaceId\')]' }
          'roleDefinitionIds': [ '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' ]
          'deployment': {
            'properties': {
              'mode': 'incremental'
              'template': {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                'contentVersion': '1.0.0.0'
                'parameters': { 'diagnosticSettingName': { 'type': 'string' }, 'workspaceId': { 'type': 'string' }, 'resourceName': { 'type': 'string' } }
                'resources': [ {
                  'type': 'Microsoft.Storage/storageAccounts/providers/diagnosticSettings'
                  'apiVersion': '2021-05-01-preview'
                  'name': '[concat(parameters(\'resourceName\'), \'/Microsoft.Insights/\', parameters(\'diagnosticSettingName\'))]'
                  'properties': {
                    'workspaceId': '[parameters(\'workspaceId\')]'
                    'logs': [ { 'categoryGroup': 'allLogs', 'enabled': true } ]
                    'metrics': [ { 'category': 'AllMetrics', 'enabled': true, 'retentionPolicy': { 'enabled': false, 'days': 0 } } ]
                  }
                } ]
              }
              'parameters': { 'diagnosticSettingName': { 'value': '[parameters(\'diagName\')]' }, 'workspaceId': { 'value': '[parameters(\'workspaceId\')]' }, 'resourceName': { 'value': '[field(\'name\')]' } }
            }
          }
        }
      }
    }
  }
}

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: assignmentName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Storage diagnostics to Log Analytics (assignment)'
    policyDefinitionId: policyDef.id
    parameters: { workspaceId: { value: logAnalyticsWorkspaceId }, diagName: { value: diagnosticSettingName } }
  }
}

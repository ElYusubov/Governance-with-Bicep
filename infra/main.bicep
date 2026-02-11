targetScope = 'subscription'

// Guardrails (start in audit)
module requireTag './modules/policy/require-tag.bicep' = {
  name: 'require-tag-environment'
  params: {
    tagName: 'Environment'
    effect: 'audit'
  }
}

module allowedLocations './modules/policy/allowed-locations.bicep' = {
  name: 'allowed-locations'
  params: {
    allowedLocations: [ 'eastus2', 'westus2' ]
    effect: 'audit'
  }
}

// Optional: Allowed VM SKUs (starts in audit)
module allowedVmSkus './modules/policy/allowed-vm-skus.bicep' = {
  name: 'allowed-vm-skus'
  params: {
    allowedSkus: ['Standard_B2ms', 'Standard_B2s', 'Standard_B1s']
    effect: 'Audit'
  }
}

// Optional: Storage Diagnostics to Log Analytics (set workspaceId to enable)
@description('Resource ID of Log Analytics Workspace; leave empty to skip deploying diagnostics policy')
param logAnalyticsWorkspaceId string

module storageDiagnostics './modules/policy/storage-diagnostics.bicep' = if (logAnalyticsWorkspaceId != '') {
  name: 'storage-diagnostics'
  params: {
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    effect: 'auditIfNotExists' // switch to 'deployIfNotExists' for auto-remediation
    diagnosticSettingName: 'storage-to-law'
  }
}

targetScope = 'subscription'

@allowed([ 'audit', 'deny' ])
@description('Effect for the require-tag policy')
param requireTagEffect string = 'audit'

@allowed([ 'audit', 'deny' ])
@description('Effect for the allowed-locations policy')
param allowedLocationsEffect string = 'audit'

@allowed([ 'Audit', 'Deny' ])
@description('Effect for the allowed VM SKUs policy (capitalized by design)')
param allowedVmSkusEffect string = 'Audit'

@allowed([ 'audit', 'deny' ])
@description('Effect for the storage access controls policy')
param storageAccessControlsEffect string = 'audit'

@allowed([ 'auditIfNotExists', 'deployIfNotExists' ])
@description('Effect for the storage diagnostics policy')
param storageDiagnosticsEffect string = 'auditIfNotExists'

@description('Allowed Azure regions')
param allowedLocationsList array = [ 'eastus', 'eastus2', 'westus', 'westus2' ]

@description('Allowed VM SKUs')
param allowedVmSkusList array = [ 'Standard_B2ms', 'Standard_B2s', 'Standard_B1s' ]

// Guardrails (start in audit)
module requireTag './modules/policy/require-tag.bicep' = {
  name: 'require-tag-environment'
  params: {
    tagName: 'Environment'
    effect: requireTagEffect
  }
}

module allowedLocations './modules/policy/allowed-locations.bicep' = {
  name: 'allowed-locations'
  params: {
    allowedLocations: allowedLocationsList
    effect: allowedLocationsEffect
  }
}

// Optional: Allowed VM SKUs (starts in audit)
module allowedVmSkus './modules/policy/allowed-vm-skus.bicep' = {
  name: 'allowed-vm-skus'
  params: {
    allowedSkus: allowedVmSkusList
    effect: allowedVmSkusEffect
  }
}

// Optional: Storage Diagnostics to Log Analytics (set workspaceId to enable)
@description('Resource ID of Log Analytics Workspace; leave empty to skip deploying diagnostics policy')
param logAnalyticsWorkspaceId string = ''

module storageDiagnostics './modules/policy/storage-diagnostics.bicep' = if (logAnalyticsWorkspaceId != '') {
  name: 'storage-diagnostics'
  params: {
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    effect: storageDiagnosticsEffect // 'deployIfNotExists' enables auto-remediation
    diagnosticSettingName: 'storage-to-law'
  }
}

module storageAccessControls './modules/policy/storage-access-controls.bicep' = {
  name: 'storage-access-controls'
  params: {
    effect: storageAccessControlsEffect
  }
}

// deploy-test-storage-with-lock.bicep
// Learning sample: creates a resource group plus a storage account protected by a
// CanNotDelete lock, so you have something to test the policies against.
// Remove the lock before deleting it: see docs/labs/07-clean-up.md.

// Deployment scope: subscription
targetScope = 'subscription'

@description('Resource group name.')
param resourceGroupName string

@description('Azure region selection.')
param azureRegion string

var tag = {
  Project: 'Session Demo'
  Environment: 'Demo'
}

@description('Resource group defintion')
resource myResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: azureRegion
  tags: tag
}

@description('Storage module with a parameter defined.')
module storageModule '../modules/storage-param.bicep' = {
  scope: resourceGroup(myResourceGroup.name)
  name: 'storageDeployment-${uniqueString(myResourceGroup.id)}' // dynamic deployment name
  params: {
    geoRedundancy: false
    tags: tag
    azureRegion: azureRegion
  }
}

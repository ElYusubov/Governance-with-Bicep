# Samples

`deploy-test-storage-with-lock.bicep` is a **learning aid**, not part of the policy deployment. It creates a resource group and a storage account (via `../modules/storage-param.bicep`) with a `CanNotDelete` lock.

Use it as a ready-made test resource for the [labs](../../docs/labs/README.md).

```bash
az deployment sub create --location eastus2 \
  --template-file infra/samples/deploy-test-storage-with-lock.bicep \
  --parameters resourceGroupName=rg-governance-lab azureRegion=eastus2
```

```powershell
az deployment sub create --location eastus2 `
  --template-file infra/samples/deploy-test-storage-with-lock.bicep `
  --parameters resourceGroupName=rg-governance-lab azureRegion=eastus2
```

> The lock blocks deletion. Run `scripts/cleanup.sh` (or `cleanup.ps1`), which removes locks first.

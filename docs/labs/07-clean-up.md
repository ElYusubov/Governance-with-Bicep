# Lab 07: Clean up

**Goal:** remove everything the labs created so nothing keeps costing money or blocking work.

## 1. Run the cleanup script
It deletes the five lab policy assignments and definitions, removes `CanNotDelete` locks, and deletes resource groups that start with `rg-governance-lab`.

```bash
scripts/cleanup.sh
```

```powershell
scripts/cleanup.ps1
```

Add `-y` (bash) or `-Yes` (PowerShell) to skip the confirmation.

## 2. Verify
```bash
az policy assignment list --query "[?ends_with(name, '-assignment')].name" -o tsv
az group list --query "[?starts_with(name, 'rg-governance-lab')].name" -o tsv
```

Both should be empty (resource groups may take a few minutes to disappear).

## 3. Optional: remove GitHub access
```bash
az ad app delete --id $(az ad app list --display-name governance-with-bicep-gha --query "[0].appId" -o tsv)
```

```powershell
az ad app delete --id (az ad app list --display-name governance-with-bicep-gha --query "[0].appId" -o tsv)
```

Then delete the three secrets and the `platform` environment in your fork's settings.

## Done
You can now write a policy, test it in audit mode, enforce it, and ship it through CI/CD. Next steps: add your own policy module following `infra/modules/README.md`, then read about management groups and initiatives.

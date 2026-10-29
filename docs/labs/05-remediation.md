# Lab 05: Auto-remediation with Log Analytics

**Goal:** use `deployIfNotExists` so Azure fixes missing diagnostic settings for you.

Effects: `auditIfNotExists` only reports a missing setting. `deployIfNotExists` creates it, using a managed identity.

> A Log Analytics workspace has a small cost. Lab 07 deletes it.

## 1. Create a workspace
```bash
RG=rg-governance-lab
az group create -n $RG -l eastus2
az monitor log-analytics workspace create -g $RG -n law-gov-demo -l eastus2
LAW_ID=$(az monitor log-analytics workspace show -g $RG -n law-gov-demo --query id -o tsv)
```

```powershell
$rg = 'rg-governance-lab'
az group create -n $rg -l eastus2
az monitor log-analytics workspace create -g $rg -n law-gov-demo -l eastus2
$lawId = az monitor log-analytics workspace show -g $rg -n law-gov-demo --query id -o tsv
```

## 2. Deploy the policy in audit mode
```bash
az deployment sub create --location eastus2 --template-file infra/main.bicep \
  --parameters infra/params/sub.dev.json logAnalyticsWorkspaceId=$LAW_ID
```

```powershell
az deployment sub create --location eastus2 --template-file infra/main.bicep `
  --parameters infra/params/sub.dev.json logAnalyticsWorkspaceId=$lawId
```

Storage accounts without diagnostics now show as non-compliant.

## 3. Switch to `deployIfNotExists`
Add `storageDiagnosticsEffect=deployIfNotExists` to the same command. The policy assignment gets a managed identity.

> The identity needs a role on the subscription (for example **Monitoring Contributor** and **Log Analytics Contributor**) to create settings. Grant it in the portal under Policy > Assignments > Remediation, or with `az role assignment create`.

## 4. Remediate existing storage accounts
Policy fixes *new* resources automatically; use a remediation task for existing ones:

```bash
az policy remediation create -n fix-storage-diag --policy-assignment storage-diagnostics-policy-14-assignment
```

```powershell
az policy remediation create -n fix-storage-diag --policy-assignment storage-diagnostics-policy-14-assignment
```

## Check yourself
- A new storage account gets a diagnostic setting named `storage-to-law`:
  `az monitor diagnostic-settings list --resource <STORAGE_ID> -o table`

Next: [Lab 06](06-ci-cd-with-oidc.md)

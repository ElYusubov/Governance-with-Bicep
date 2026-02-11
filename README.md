# Governance-w-Bicep

Welcome to Policy-as-Code starter repo for **Azure Governance** using **Bicep** and **GitHub Actions** with **OIDC**.

## What You'll Learn
- Define Azure Policy guardrails as reusable **Bicep modules**
- Start with **`audit`** effect, then switch to **`deny`** to enforce
- Validate with **what-if** and compliance checks in **PRs**
- Deploy at **subscription** scope via GitHub Actions (no long-lived secrets)

## Repo Structure
```
infra/
  main.bicep
  modules/
    policy/
      require-tag.bicep
      allowed-locations.bicep
      allowed-vm-skus.bicep
      storage-diagnostics.bicep
  params/
    sub.dev.json
.github/
  workflows/
    pr-validate.yml
    release-deploy.yml
.bicepconfig.json
README.md
```

## Quick Start (Local)
```bash
az login
az account set --subscription <SUB_ID>

# Preview changes
az deployment sub what-if   --template-file infra/main.bicep   --location eastus2

# Deploy (starts with audit)
az deployment sub create   --template-file infra/main.bicep   --location eastus2

# Check compliance
az policy state summarize --subscription <SUB_ID>
```

## Demonstration Flow
1. **Audit** mode: create a non-compliant resource (missing required tag) → allowed but flagged
2. Flip module **`effect`** param to `deny` and redeploy → non-compliance is blocked
3. **Extended:** Allowed VM SKUs & Storage Diagnostics (audit-first → enforce)

## Workflows
- **PR Validate**: build Bicep, run `what-if`, snapshot policy compliance
- **Release Deploy**: deploy to subscription on merge to `main` and summarize compliance

## Notes
- Modules are subscription-scoped. For production, consider **management group** scope and **initiatives**.

## Extended Demo (Optional)

### Allowed VM SKUs
- Module: `infra/modules/policy/allowed-vm-skus.bicep`
- Start with `effect: 'audit'`, then switch to `deny` to block disallowed sizes.

### Storage Diagnostics to Log Analytics
- Module: `infra/modules/policy/storage-diagnostics.bicep`
- Set parameter `logAnalyticsWorkspaceId` in `infra/main.bicep` to your Workspace resource ID to enable the module.
- Start with `effect: 'auditIfNotExists'`, then switch to `deployIfNotExists` to **auto-deploy** diagnostic settings.

```bash
# Example: create a workspace and pass its resource ID
LAW_NAME=law-gov-demo
RG=rg-governance-demo
az monitor log-analytics workspace create -g $RG -n $LAW_NAME -l eastus
LAW_ID=$(az monitor log-analytics workspace show -g $RG -n $LAW_NAME --query id -o tsv)

# Edit infra/main.bicep: set logAnalyticsWorkspaceId to $LAW_ID
# Then deploy:
az deployment sub create   --template-file infra/main.bicep   --location eastus

# Try creating a storage account without diagnostics; with deployIfNotExists, settings will be created automatically.
```

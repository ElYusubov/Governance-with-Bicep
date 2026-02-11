# Copilot instructions

## Project overview
- This repo is an Azure Policy-as-Code starter using Bicep at subscription scope. The entry point is infra/main.bicep, which composes policy modules under infra/modules/policy/.
- Policies are defined as custom policy definitions plus assignments in each module, designed to start in audit mode and later be flipped to deny or deploy modes.

## Key architecture and patterns
- All Bicep files use subscription scope (targetScope = 'subscription'). Keep new modules consistent unless explicitly changing scope.
- Each policy module creates:
  - Microsoft.Authorization/policyDefinitions with policyRule and metadata
  - Microsoft.Authorization/policyAssignments referencing the definition ID
- Assignment names are derived from policyName via "${policyName}-assignment". Follow this convention for consistency.
- Effects are parameterized and constrained with @allowed. Match the casing used in each module:
  - require-tag.bicep and allowed-locations.bicep use 'audit'/'deny'
  - allowed-vm-skus.bicep uses 'Audit'/'Deny' (casing is intentional)
  - storage-diagnostics.bicep uses 'auditIfNotExists'/'deployIfNotExists'
- The storage diagnostics module is optional. infra/main.bicep only deploys it when logAnalyticsWorkspaceId is not empty.
  - It uses deployIfNotExists with a managed identity and requires a location for the assignment.

## Files to follow as examples
- Composition and module wiring: infra/main.bicep
- Tag requirement policy: infra/modules/policy/require-tag.bicep
- Location allowlist policy: infra/modules/policy/allowed-locations.bicep
- Allowed VM SKUs policy with parameters: infra/modules/policy/allowed-vm-skus.bicep
- Diagnostics deployIfNotExists policy: infra/modules/policy/storage-diagnostics.bicep

## Developer workflows
- Local preview: az deployment sub what-if --template-file infra/main.bicep --location eastus2
- Local deploy: az deployment sub create --template-file infra/main.bicep --location eastus2
- Compliance snapshot: az policy state summarize --subscription <SUB_ID>

## CI/CD conventions
- PR validation runs Bicep build, subscription what-if, and compliance snapshot (see .github/workflows/pr-validate.yml).
- Release deploy on main uses azure/arm-deploy@v2 at subscription scope and then summarizes compliance (see .github/workflows/release-deploy.yml).

## Parameters
- infra/params/sub.dev.json is currently empty; parameters are set inline in infra/main.bicep.
- To enable storage diagnostics, set logAnalyticsWorkspaceId in infra/main.bicep to the Log Analytics workspace resource ID.

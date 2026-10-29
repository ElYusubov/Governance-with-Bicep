# Glossary

| Term | Meaning |
|---|---|
| **Azure Policy** | Azure service that evaluates resources against rules |
| **Policy definition** | A rule: a condition plus an effect |
| **Policy assignment** | Turns a definition on at a scope |
| **Initiative** | A bundle of policy definitions assigned together |
| **Effect** | What happens on a violation (`audit`, `deny`, `auditIfNotExists`, `deployIfNotExists`) |
| **Scope** | Where an assignment applies: management group, subscription, resource group, resource |
| **Compliance** | The report of which resources meet the policy |
| **Exemption** | A documented exception for a resource or scope |
| **Remediation task** | Fixes existing resources for `deployIfNotExists` policies |
| **Managed identity** | An Azure-managed identity the policy uses to deploy fixes |
| **Bicep** | A language that compiles to ARM templates for deploying Azure resources |
| **Module** | A reusable Bicep file called from another |
| **What-if** | A dry-run that shows changes before deploying |
| **Resource lock** | A `CanNotDelete` or `ReadOnly` guard on a resource |
| **OIDC** | Passwordless sign-in from GitHub Actions to Azure |
| **Federated credential** | The trust setting that lets a specific repo or branch sign in with OIDC |
| **Service principal** | The identity GitHub Actions uses in Azure |
| **Indexed mode** | Policy mode that only checks resources supporting tags and location |

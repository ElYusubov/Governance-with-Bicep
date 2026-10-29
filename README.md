# Governance-with-Bicep

A beginner-friendly starter for **Azure Policy as Code**. You write governance rules ("policies") in **Bicep**, preview them, and deploy them to an Azure subscription, locally or through **GitHub Actions**.

> **New to this?** A *policy* is a rule such as "every resource must have an `Environment` tag". Policies start in **audit** mode (they only report violations) and can later be switched to **deny** (they block violations). Nothing is blocked until you choose to.
>
> **Use a sandbox subscription** while learning. Deny-mode policies affect everyone deploying to it.

## Start here
1. [Concepts](docs/concepts.md): the ideas in five minutes ([glossary](docs/glossary.md))
2. [Hands-on labs](docs/labs/README.md): learn by doing
3. [FAQ](docs/faq.md) and [troubleshooting](docs/troubleshooting.md): when you're stuck

## What you get

| Policy | What it checks |
|---|---|
| `require-tag` | Resources have an `Environment` tag |
| `allowed-locations` | Resources are only in approved regions |
| `allowed-vm-skus` | Only approved VM sizes are used |
| `storage-access-controls` | Storage accounts block anonymous access and shared keys, and require TLS 1.2 |
| `storage-diagnostics` *(optional)* | Storage accounts send logs to Log Analytics |

## Prerequisites
- An Azure subscription where you can create policies (Owner or Resource Policy Contributor)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (it includes Bicep support: `az bicep install`)
- Optional: a GitHub repo with the secrets listed under [Automated deployment](#automated-deployment-github-actions)

## Quick start (5 minutes)
```bash
az login
az account set --subscription <SUB_ID>

# 1. Preview what will be created (changes nothing)
az deployment sub what-if --template-file infra/main.bicep --parameters infra/params/sub.dev.json --location eastus2

# 2. Deploy (everything starts in audit mode)
az deployment sub create --template-file infra/main.bicep --parameters infra/params/sub.dev.json --location eastus2

# 3. Check compliance (results can take up to 30 minutes to appear)
az policy state summarize
```

## Try it: audit, then deny
1. Deploy as above. Create a resource without an `Environment` tag. It succeeds but is reported as non-compliant.
2. In `infra/params/sub.dev.json`, set `requireTagEffect` to `deny` and redeploy.
3. Create an untagged resource again. Azure now blocks it.

Each policy has its own effect parameter, so you can enforce them one at a time:

| Parameter | Allowed values |
|---|---|
| `requireTagEffect`, `allowedLocationsEffect`, `storageAccessControlsEffect` | `audit`, `deny` |
| `allowedVmSkusEffect` | `Audit`, `Deny` (capitalized on purpose) |
| `storageDiagnosticsEffect` | `auditIfNotExists`, `deployIfNotExists` |

`infra/params/sub.prod.json` is an example with enforcing effects. **Review it before use**; see [params/README](infra/params/README.md).

## Learn by doing
Follow the [hands-on labs](docs/labs/README.md) (bash and PowerShell). They take you from first deployment to CI/CD and cleanup. Stuck? See [troubleshooting](docs/troubleshooting.md).

Helper scripts in `scripts/`:

| Script (`.sh` / `.ps1`) | Purpose |
|---|---|
| `setup-oidc` | Creates the Azure identity, secrets, and `platform` environment for GitHub Actions |
| `test-noncompliant` | Creates a deliberately non-compliant resource (`tag`, `storage`, or `location`) |
| `cleanup` | Removes the lab policies, locks, and resource groups |

## Repo layout
```
infra/
  main.bicep               Entry point: wires all policies together
  modules/policy/          One Bicep module per policy (see modules/README.md)
  modules/storage-param.bicep, samples/   Test resources for the labs, not part of the policy deployment
  params/                  sub.dev.json (audit) and sub.prod.json (enforce)
docs/                      Labs and troubleshooting
scripts/                   Helper scripts
.github/workflows/         pr-validate.yml and release-deploy.yml
.bicepconfig.json          Bicep linter rules
```

## Optional: storage diagnostics
Set `logAnalyticsWorkspaceId` in `infra/params/sub.dev.json` to a Log Analytics workspace resource ID. The policy is skipped while it is empty.

```bash
az monitor log-analytics workspace create -g <RG> -n <LAW_NAME> -l eastus
az monitor log-analytics workspace show -g <RG> -n <LAW_NAME> --query id -o tsv
```
Use `auditIfNotExists` first, then `deployIfNotExists` to create diagnostic settings automatically.

## Automated deployment (GitHub Actions)
- **PR Validate**: lints Bicep, runs security scans, runs `what-if`, and saves a compliance snapshot.
- **Release Deploy**: deploys to the subscription when `infra/**` changes on `main`, using the `platform` environment.

Both authenticate with **OIDC**, so there are no stored passwords. Run `scripts/setup-oidc.sh <owner/repo>` (or `setup-oidc.ps1 -Repo <owner/repo>`) to create the Entra app registration, federated credentials, repository secrets (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`), and the `platform` environment. Details: [Lab 06](docs/labs/06-ci-cd-with-oidc.md).

## Clean up
```bash
scripts/cleanup.sh      # or scripts/cleanup.ps1
```

## Good to know
- Everything deploys at **subscription** scope. For production, consider management groups and policy initiatives.
- Changing a policy's `policyName` creates a new definition and leaves the old one behind.

# Lab 00: Setup

**Goal:** a working Azure CLI signed in to a sandbox subscription.

## 1. Install the tools
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- Git, and optionally the [GitHub CLI](https://cli.github.com/) (`gh`) for Lab 06

```bash
az bicep install
az --version
```

## 2. Sign in and pick a subscription
```bash
az login
az account list -o table
az account set --subscription <SUB_ID>
az account show --query "{name:name, id:id}" -o table
```

## 3. Clone the repo
```bash
git clone https://github.com/<you>/Governance-with-Bicep.git
cd Governance-with-Bicep
```

## 4. Check your permissions
You need **Owner**, or **Resource Policy Contributor** plus **Contributor**, on the subscription.

```bash
az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv) --query "[].roleDefinitionName" -o tsv
```

```powershell
az role assignment list --assignee (az ad signed-in-user show --query id -o tsv) --query "[].roleDefinitionName" -o tsv
```

## Check yourself
- `az account show` prints the subscription you intend to use.
- The role list includes `Owner` (or both roles above).

Next: [Lab 01](01-first-policy.md)

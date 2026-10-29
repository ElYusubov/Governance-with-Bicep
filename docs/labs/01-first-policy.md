# Lab 01: Your first policy

**Goal:** deploy all policies in **audit** mode and watch one flag a resource.

## 1. Preview, then deploy
```bash
az deployment sub what-if --location eastus2 \
  --template-file infra/main.bicep --parameters infra/params/sub.dev.json

az deployment sub create --location eastus2 \
  --template-file infra/main.bicep --parameters infra/params/sub.dev.json
```

```powershell
az deployment sub what-if --location eastus2 `
  --template-file infra/main.bicep --parameters infra/params/sub.dev.json

az deployment sub create --location eastus2 `
  --template-file infra/main.bicep --parameters infra/params/sub.dev.json
```

`what-if` changes nothing; it shows what *would* be created.

## 2. Confirm the policies exist
```bash
az policy assignment list --query "[?ends_with(name, '-assignment')].{name:name, mode:enforcementMode}" -o table
```

## 3. Break a rule on purpose
Create a storage account with no `Environment` tag:

```bash
scripts/test-noncompliant.sh tag
```

```powershell
scripts/test-noncompliant.ps1 -Scenario tag
```

It succeeds. Audit mode never blocks.

## 4. Look at compliance
Evaluation can take up to 30 minutes. To speed it up:

```bash
az policy state trigger-scan --no-wait
az policy state list --query "[?complianceState=='NonCompliant'].{policy:policyDefinitionName, resource:resourceId}" -o table
```

## Check yourself
- You see assignments ending in `-assignment`.
- The untagged storage account is created without errors.
- Later, it appears as `NonCompliant` for `require-tag-policy-14`.

Next: [Lab 02](02-audit-to-deny.md)

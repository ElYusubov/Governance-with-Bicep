# Lab 03: Allowed locations and VM sizes

**Goal:** see two *allowlist* policies in action.

## Part A: allowed locations
Allowed regions: `eastus`, `eastus2`, `westus`, `westus2`.

1. Switch to deny:
   ```bash
   az deployment sub create --location eastus2 --template-file infra/main.bicep \
     --parameters infra/params/sub.dev.json requireTagEffect=deny allowedLocationsEffect=deny
   ```
   ```powershell
   az deployment sub create --location eastus2 --template-file infra/main.bicep `
     --parameters infra/params/sub.dev.json requireTagEffect=deny allowedLocationsEffect=deny
   ```
2. Wait 5 to 10 minutes, then try an unapproved region:
   ```bash
   scripts/test-noncompliant.sh location
   ```
   ```powershell
   scripts/test-noncompliant.ps1 -Scenario location
   ```

**Expected:** `RequestDisallowedByPolicy`.

## Part B: allowed VM SKUs
Allowed sizes: `Standard_B1s`, `Standard_B2s`, `Standard_B2ms`. Note that this policy uses capitalized `Audit`/`Deny`.

```bash
az deployment sub create --location eastus2 --template-file infra/main.bicep \
  --parameters infra/params/sub.dev.json allowedVmSkusEffect=Deny
```

```powershell
az deployment sub create --location eastus2 --template-file infra/main.bicep `
  --parameters infra/params/sub.dev.json allowedVmSkusEffect=Deny
```

After a few minutes, try a large VM. The policy blocks it before it is created, so **it costs nothing**:

```bash
az vm create -g rg-governance-lab -n vm-lab --image Ubuntu2204 --size Standard_D16s_v5 --generate-ssh-keys
```

```powershell
az vm create -g rg-governance-lab -n vm-lab --image Ubuntu2204 --size Standard_D16s_v5 --generate-ssh-keys
```

**Expected:** `RequestDisallowedByPolicy`. If it *succeeds*, delete the VM right away: `az vm delete -g rg-governance-lab -n vm-lab --yes`.

## Check yourself
- Both attempts fail with `RequestDisallowedByPolicy`.
- You can say why the effect value in Part B is `Deny`, not `deny`.

Next: [Lab 04](04-storage-security.md)

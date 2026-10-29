# Lab 04: Storage security

**Goal:** catch storage accounts that allow anonymous access, shared keys, or old TLS.

The `storage-access-controls` policy flags an account if **any** of these is true:
- `allowBlobPublicAccess` is `true`
- `allowSharedKeyAccess` is `true`
- `minimumTlsVersion` is not `TLS1_2`

## 1. Create an insecure account (audit mode)
```bash
scripts/test-noncompliant.sh storage
```

```powershell
scripts/test-noncompliant.ps1 -Scenario storage
```

It has the `Environment` tag, so only this policy objects. Audit mode allows it.

## 2. See it flagged
```bash
az policy state trigger-scan --no-wait
az policy state list --policy-definition storage-access-controls-policy-14 \
  --query "[].{resource:resourceId, state:complianceState}" -o table
```

```powershell
az policy state trigger-scan --no-wait
az policy state list --policy-definition storage-access-controls-policy-14 `
  --query "[].{resource:resourceId, state:complianceState}" -o table
```

## 3. Fix the account
```bash
az storage account update -g rg-governance-lab -n <ACCOUNT_NAME> \
  --allow-blob-public-access false --allow-shared-key-access false --min-tls-version TLS1_2
```

```powershell
az storage account update -g rg-governance-lab -n <ACCOUNT_NAME> `
  --allow-blob-public-access false --allow-shared-key-access false --min-tls-version TLS1_2
```

Trigger another scan. It should turn `Compliant`.

## 4. Optional: deny
Set `storageAccessControlsEffect=deny` as in Lab 02. Do this only if no app depends on account keys.

## Check yourself
- The insecure account shows `NonCompliant`, then `Compliant` after the fix.

Next: [Lab 05](05-remediation.md)

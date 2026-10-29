# FAQ

**Will deploying this break my existing resources?**
No. Everything starts in `audit` mode, which only reports. Existing resources are never changed or deleted.

**Why is my compliance report empty?**
Azure evaluates in the background; allow up to 30 minutes, or run `az policy state trigger-scan`.

**Why doesn't deny block anything yet?**
New assignments take 5 to 10 minutes to take effect.

**Do the labs cost money?**
Storage accounts cost pennies. The Log Analytics workspace in Lab 05 has a small cost. Run the cleanup script when done.

**Can I use my work subscription?**
Use a sandbox. Deny policies affect everyone deploying to the subscription.

**Why is the VM policy `Audit`/`Deny` but the others `audit`/`deny`?**
Casing differs between modules on purpose. Match each module's `@allowed` values.

**How do I allow one resource to break a rule?**
Create an **exemption** instead of loosening the policy:

```bash
az policy exemption create --name allow-legacy-storage \
  --policy-assignment "/subscriptions/<SUB_ID>/providers/Microsoft.Authorization/policyAssignments/storage-access-controls-policy-14-assignment" \
  --exemption-category Waiver \
  --scope "/subscriptions/<SUB_ID>/resourceGroups/<RG>/providers/Microsoft.Storage/storageAccounts/<NAME>" \
  --expires-on 2027-01-31T00:00:00Z --description "Legacy app, migrating by Jan 2027"
```

```powershell
az policy exemption create --name allow-legacy-storage `
  --policy-assignment "/subscriptions/<SUB_ID>/providers/Microsoft.Authorization/policyAssignments/storage-access-controls-policy-14-assignment" `
  --exemption-category Waiver `
  --scope "/subscriptions/<SUB_ID>/resourceGroups/<RG>/providers/Microsoft.Storage/storageAccounts/<NAME>" `
  --expires-on 2027-01-31T00:00:00Z --description "Legacy app, migrating by Jan 2027"
```

Always set an expiry date.

**I locked myself out with deny. What now?**
Set the effect back to audit and redeploy, or create an exemption for the blocked scope.

**How do I add my own policy?**
Copy a module in `infra/modules/policy/`, change the rule, then add it to `infra/main.bicep` with an effect parameter. See [CONTRIBUTING](../CONTRIBUTING.md).

**Where do I go next?**
Management group scope, initiatives, and the [Azure Policy docs](https://learn.microsoft.com/azure/governance/policy/).

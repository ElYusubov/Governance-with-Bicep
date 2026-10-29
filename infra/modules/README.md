# Policy modules

Each module under `policy/` creates one **policy definition** (the rule) and one **policy assignment** (turns the rule on for the subscription). `infra/main.bicep` wires them together.

| Module | What it checks | Effect parameter (in `main.bicep`) | Before you set it to deny |
|---|---|---|---|
| `require-tag.bicep` | A tag (default `Environment`) exists | `requireTagEffect` (`audit`/`deny`) | Make sure your pipelines add the tag, or deployments will fail |
| `allowed-locations.bicep` | Resources are in approved regions | `allowedLocationsEffect` (`audit`/`deny`) | Check that no existing workloads use other regions |
| `allowed-vm-skus.bicep` | Only approved VM sizes | `allowedVmSkusEffect` (`Audit`/`Deny`, capitalized) | Confirm current VMs use approved sizes |
| `storage-access-controls.bicep` | No anonymous blob access, no shared keys, TLS 1.2+ | `storageAccessControlsEffect` (`audit`/`deny`) | Apps must not depend on account keys or old TLS |
| `storage-diagnostics.bicep` | Storage logs go to Log Analytics (optional) | `storageDiagnosticsEffect` (`auditIfNotExists`/`deployIfNotExists`) | Needs `logAnalyticsWorkspaceId`; remediation uses a managed identity |

## Conventions
- Every module is subscription scoped (`targetScope = 'subscription'`).
- The assignment name is `<policyName>-assignment`.
- Each module has a `policyName` parameter. Changing it creates a *new* definition and leaves the old one behind.

## Not policy modules
`storage-param.bicep` is a sample storage account with a delete lock. It is the test resource used by `infra/samples/` and the labs, and it is not part of the policy deployment.

New here? Start with [`docs/labs`](../../docs/labs/README.md).

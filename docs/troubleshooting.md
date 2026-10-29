# Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `AuthorizationFailed` on deploy | Your account or service principal can't write policies | Needs **Resource Policy Contributor** (or Owner) at subscription scope |
| `az policy state summarize` shows nothing | Evaluation takes time after a new assignment | Wait up to 30 minutes, or run `az policy state trigger-scan` |
| `RequestDisallowedByPolicy` | A policy is in `deny` mode and blocked your resource | This is expected after Lab 02. Fix the resource or set the effect back to audit |
| Deny doesn't block anything | New assignments take a few minutes to take effect | Wait 5 to 10 minutes and retry |
| `ScopeLocked` when deleting | The sample storage account has a `CanNotDelete` lock | Use `scripts/cleanup.sh` / `cleanup.ps1`, which remove locks first |
| `InvalidTemplateDeployment` mentioning `logAnalyticsWorkspaceId` | Diagnostics policy enabled with an invalid ID | Leave it empty, or use a full workspace resource ID |
| GitHub Action fails at **Azure Login** | Missing secrets or federated credential mismatch | Re-run `scripts/setup-oidc.sh`/`.ps1`, check the three secrets and the `platform` environment |
| Old policies remain after renaming `policyName` | Renaming creates a new definition | Delete the old definition and assignment (Lab 07) |

Still stuck? Open an issue with the full error text, with subscription IDs removed.

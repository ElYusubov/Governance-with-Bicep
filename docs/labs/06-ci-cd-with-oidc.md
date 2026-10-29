# Lab 06: CI/CD with GitHub Actions and OIDC

**Goal:** validate every pull request and deploy on merge, with no stored passwords.

**OIDC** means GitHub proves its identity to Azure with a short-lived token, so you never store a secret key.

## 1. Fork the repo
Fork on GitHub, then clone your fork. Sign in with `az login` and `gh auth login`.

## 2. Run the setup script
It creates the app registration, three federated credentials, a least-privilege role (**Resource Policy Contributor**), the repo secrets, and the `platform` environment.

```bash
scripts/setup-oidc.sh <your-user>/Governance-with-Bicep
```

```powershell
scripts/setup-oidc.ps1 -Repo <your-user>/Governance-with-Bicep
```

No `gh` installed? The script prints the three values to add under **Settings > Secrets and variables > Actions**.

## 3. Open a pull request
Change anything under `infra/` (for example, add a comment) on a branch and open a PR. **PR Validate** runs:
1. Bicep lint and build
2. PSRule and Checkov scans (advisory)
3. `what-if` against your subscription
4. A compliance snapshot, uploaded as an artifact

## 4. Merge
Merging to `main` runs **Release Deploy** (it uses the `platform` environment, so you can require approvals under Settings > Environments).

## Check yourself
- The PR shows green checks, and the `pr-validation` artifact contains `whatif.txt`.
- After merge, the Actions run is green and `compliance-snapshot` is uploaded.

If login fails, see [troubleshooting](../troubleshooting.md).

Next: [Lab 07](07-clean-up.md)

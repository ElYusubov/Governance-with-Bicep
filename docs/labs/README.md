# Hands-on labs

Learn Azure Policy by doing. Each lab takes 10 to 20 minutes and builds on the one before. Commands that are identical in both shells are shown once. Where they differ, you get a **bash** block and a **PowerShell** block.

> **Use a sandbox subscription.** Deny-mode policies can block real work. Everything here is removed by Lab 07.

| # | Lab | You will |
|---|---|---|
| [00](00-setup.md) | Setup | Install tools and sign in |
| [01](01-first-policy.md) | Your first policy | Deploy in audit mode and see a violation |
| [02](02-audit-to-deny.md) | Audit to deny | Block a non-compliant resource |
| [03](03-locations-and-vm-skus.md) | Locations and VM sizes | Test two allowlist policies |
| [04](04-storage-security.md) | Storage security | Catch insecure storage accounts |
| [05](05-remediation.md) | Auto-remediation | Use `deployIfNotExists` with Log Analytics |
| [06](06-ci-cd-with-oidc.md) | CI/CD | Run validation and deployment from GitHub Actions |
| [07](07-clean-up.md) | Clean up | Remove everything |

Key terms:
- **Policy definition**: the rule ("storage must use TLS 1.2").
- **Policy assignment**: switches a definition on for a scope (here, your subscription).
- **Effect**: what happens on a violation: `audit` reports it, `deny` blocks it.
- **Compliance**: the report of which resources follow the rules.

Stuck? See [troubleshooting](../troubleshooting.md).

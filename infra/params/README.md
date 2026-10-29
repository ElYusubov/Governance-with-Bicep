# Parameter files

| File | Effects | Use |
|---|---|---|
| `sub.dev.json` | All audit | Learning and the CI workflows. Safe default. |
| `sub.prod.json` | Deny / `deployIfNotExists` | **Enforcing.** Deploy only after reviewing compliance from audit mode. |

> **Warning:** `sub.prod.json` blocks non-compliant deployments for everyone on the subscription. Don't use it in a sandbox you share, and run `what-if` first. If something breaks, see the [FAQ](../../docs/faq.md).

Override a single value without editing a file:

```bash
az deployment sub create --location eastus2 --template-file infra/main.bicep \
  --parameters infra/params/sub.dev.json requireTagEffect=deny
```

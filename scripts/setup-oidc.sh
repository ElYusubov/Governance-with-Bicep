#!/usr/bin/env bash
# Sets up passwordless (OIDC) GitHub Actions access to your Azure subscription.
# Usage: scripts/setup-oidc.sh <owner/repo> [app-name]
set -euo pipefail

REPO="${1:?Usage: $0 <owner/repo> [app-name]}"
APP_NAME="${2:-governance-with-bicep-gha}"

SUB_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "Subscription: $SUB_ID"

APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv)
if [ -z "$APP_ID" ]; then
  APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
fi
az ad sp show --id "$APP_ID" >/dev/null 2>&1 || az ad sp create --id "$APP_ID" >/dev/null

# One federated credential per way GitHub Actions can sign in
add_cred() {
  local name="$1" subject="$2"
  if az ad app federated-credential list --id "$APP_ID" --query "[?name=='$name']" -o tsv | grep -q .; then return; fi
  az ad app federated-credential create --id "$APP_ID" --parameters "{
    \"name\": \"$name\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"$subject\",
    \"audiences\": [\"api://AzureADTokenExchange\"]}" >/dev/null
}
add_cred github-main "repo:$REPO:ref:refs/heads/main"
add_cred github-pr "repo:$REPO:pull_request"
add_cred github-env-platform "repo:$REPO:environment:platform"

# Least privilege: enough to create policy definitions and assignments
az role assignment create --assignee "$APP_ID" --role "Resource Policy Contributor" \
  --scope "/subscriptions/$SUB_ID" >/dev/null 2>&1 || true

if command -v gh >/dev/null 2>&1; then
  gh secret set AZURE_CLIENT_ID --repo "$REPO" --body "$APP_ID"
  gh secret set AZURE_TENANT_ID --repo "$REPO" --body "$TENANT_ID"
  gh secret set AZURE_SUBSCRIPTION_ID --repo "$REPO" --body "$SUB_ID"
  gh api -X PUT "repos/$REPO/environments/platform" >/dev/null
  echo "Done. Secrets and the 'platform' environment were created in $REPO."
else
  echo "GitHub CLI (gh) not found. Add these as repository secrets manually:"
  echo "  AZURE_CLIENT_ID=$APP_ID"
  echo "  AZURE_TENANT_ID=$TENANT_ID"
  echo "  AZURE_SUBSCRIPTION_ID=$SUB_ID"
  echo "Also create an environment named 'platform' in the repo settings."
fi

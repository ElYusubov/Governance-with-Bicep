# Sets up passwordless (OIDC) GitHub Actions access to your Azure subscription.
# Usage: scripts/setup-oidc.ps1 -Repo <owner/repo> [-AppName <name>]
param(
  [Parameter(Mandatory)][string]$Repo,
  [string]$AppName = 'governance-with-bicep-gha'
)
$ErrorActionPreference = 'Stop'

$subId = az account show --query id -o tsv
$tenantId = az account show --query tenantId -o tsv
Write-Host "Subscription: $subId"

$appId = az ad app list --display-name $AppName --query "[0].appId" -o tsv
if (-not $appId) { $appId = az ad app create --display-name $AppName --query appId -o tsv }
az ad sp show --id $appId 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { az ad sp create --id $appId | Out-Null }

function Add-Cred($name, $subject) {
  $existing = az ad app federated-credential list --id $appId --query "[?name=='$name'].name" -o tsv
  if ($existing) { return }
  $file = New-TemporaryFile
  @{ name = $name; issuer = 'https://token.actions.githubusercontent.com'; subject = $subject; audiences = @('api://AzureADTokenExchange') } |
    ConvertTo-Json | Set-Content $file
  az ad app federated-credential create --id $appId --parameters "@$file" | Out-Null
  Remove-Item $file
}
Add-Cred 'github-main' "repo:${Repo}:ref:refs/heads/main"
Add-Cred 'github-pr' "repo:${Repo}:pull_request"
Add-Cred 'github-env-platform' "repo:${Repo}:environment:platform"

# Least privilege: enough to create policy definitions and assignments
az role assignment create --assignee $appId --role 'Resource Policy Contributor' --scope "/subscriptions/$subId" 2>$null | Out-Null

if (Get-Command gh -ErrorAction SilentlyContinue) {
  gh secret set AZURE_CLIENT_ID --repo $Repo --body $appId
  gh secret set AZURE_TENANT_ID --repo $Repo --body $tenantId
  gh secret set AZURE_SUBSCRIPTION_ID --repo $Repo --body $subId
  gh api -X PUT "repos/$Repo/environments/platform" | Out-Null
  Write-Host "Done. Secrets and the 'platform' environment were created in $Repo."
} else {
  Write-Host "GitHub CLI (gh) not found. Add these as repository secrets manually:"
  Write-Host "  AZURE_CLIENT_ID=$appId"
  Write-Host "  AZURE_TENANT_ID=$tenantId"
  Write-Host "  AZURE_SUBSCRIPTION_ID=$subId"
  Write-Host "Also create an environment named 'platform' in the repo settings."
}

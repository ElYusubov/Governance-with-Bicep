# Creates a deliberately non-compliant resource so you can see a policy react.
# Usage: scripts/test-noncompliant.ps1 -Scenario tag|storage|location
# In audit mode the resource is created and flagged; in deny mode creation is blocked.
param([Parameter(Mandatory)][ValidateSet('tag', 'storage', 'location')][string]$Scenario)

$rg = if ($env:LAB_RG) { $env:LAB_RG } else { 'rg-governance-lab' }
$suffix = (Get-Date -UFormat %s).Substring(4)

az group create -n $rg -l eastus2 2>$null | Out-Null

switch ($Scenario) {
  'tag' { az storage account create -g $rg -n "labtag$suffix" -l eastus2 --sku Standard_LRS }
  'storage' {
    az storage account create -g $rg -n "labsec$suffix" -l eastus2 --sku Standard_LRS `
      --tags Environment=lab --allow-blob-public-access true --allow-shared-key-access true --min-tls-version TLS1_0
  }
  'location' { az group create -n "$rg-northeurope" -l northeurope }
}

Write-Host "Done. If you saw RequestDisallowedByPolicy, the policy is in deny mode."
Write-Host "Otherwise check compliance later with: az policy state list --query ""[?complianceState=='NonCompliant'].{policy:policyDefinitionName,resource:resourceId}"" -o table"

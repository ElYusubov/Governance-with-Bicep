# Removes everything the labs create: policy assignments, definitions, and lab resource groups.
# Usage: scripts/cleanup.ps1 [-Yes]   (-Yes skips the confirmation prompt)
param([switch]$Yes)

$policies = 'require-tag-policy-14', 'allowed-locations-policy-14', 'allowed-vm-skus-policy-14', 'storage-access-controls-policy-14', 'storage-diagnostics-policy-14'
$rg = if ($env:LAB_RG) { $env:LAB_RG } else { 'rg-governance-lab' }

Write-Host "This deletes the 5 lab policies (assignments + definitions) and resource groups starting with '$rg' in:"
az account show --query "{name:name,id:id}" -o tsv
if (-not $Yes -and (Read-Host 'Continue? [y/N]') -ne 'y') { Write-Host 'Cancelled.'; return }

foreach ($p in $policies) {
  az policy assignment delete --name "$p-assignment" 2>$null
  if ($LASTEXITCODE -eq 0) { Write-Host "Deleted assignment $p-assignment" }
  az policy definition delete --name $p 2>$null
  if ($LASTEXITCODE -eq 0) { Write-Host "Deleted definition $p" }
}

foreach ($g in (az group list --query "[?starts_with(name,'$rg')].name" -o tsv)) {
  # CanNotDelete locks must be removed first
  foreach ($id in (az lock list -g $g --query "[].id" -o tsv)) { az lock delete --ids $id }
  az group delete -n $g --yes --no-wait
  Write-Host "Deleting resource group $g"
}
Write-Host 'Cleanup started. Resource group deletion finishes in the background.'

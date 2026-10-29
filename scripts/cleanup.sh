#!/usr/bin/env bash
# Removes everything the labs create: policy assignments, definitions, and lab resource groups.
# Usage: scripts/cleanup.sh [-y]   (-y skips the confirmation prompt)
set -uo pipefail

POLICIES=(require-tag-policy-14 allowed-locations-policy-14 allowed-vm-skus-policy-14 storage-access-controls-policy-14 storage-diagnostics-policy-14)
RG="${LAB_RG:-rg-governance-lab}"

echo "This deletes the 5 lab policies (assignments + definitions) and resource groups starting with '$RG' in the current subscription:"
az account show --query "{name:name,id:id}" -o tsv
if [ "${1:-}" != "-y" ]; then
  read -r -p "Continue? [y/N] " ans
  [ "$ans" = "y" ] || { echo "Cancelled."; exit 0; }
fi

for p in "${POLICIES[@]}"; do
  az policy assignment delete --name "$p-assignment" 2>/dev/null && echo "Deleted assignment $p-assignment"
  az policy definition delete --name "$p" 2>/dev/null && echo "Deleted definition $p"
done

for g in $(az group list --query "[?starts_with(name, '$RG')].name" -o tsv); do
  # CanNotDelete locks must be removed first
  for id in $(az lock list -g "$g" --query "[].id" -o tsv); do az lock delete --ids "$id"; done
  az group delete -n "$g" --yes --no-wait && echo "Deleting resource group $g"
done
echo "Cleanup started. Resource group deletion finishes in the background."

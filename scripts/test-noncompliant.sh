#!/usr/bin/env bash
# Creates a deliberately non-compliant resource so you can see a policy react.
# Usage: scripts/test-noncompliant.sh <tag|storage|location>
# In audit mode the resource is created and flagged; in deny mode creation is blocked.
set -uo pipefail

SCENARIO="${1:?Usage: $0 <tag|storage|location>}"
RG="${LAB_RG:-rg-governance-lab}"
SUFFIX=$(date +%s | tail -c 7)

az group create -n "$RG" -l eastus2 >/dev/null 2>&1 || true

case "$SCENARIO" in
  tag)       # no Environment tag
    az storage account create -g "$RG" -n "labtag$SUFFIX" -l eastus2 --sku Standard_LRS ;;
  storage)   # public blob access, shared keys, old TLS
    az storage account create -g "$RG" -n "labsec$SUFFIX" -l eastus2 --sku Standard_LRS \
      --tags Environment=lab --allow-blob-public-access true --allow-shared-key-access true --min-tls-version TLS1_0 ;;
  location)  # region not on the allowed list
    az group create -n "$RG-northeurope" -l northeurope ;;
  *) echo "Unknown scenario: $SCENARIO"; exit 1 ;;
esac

echo "Done. If you saw RequestDisallowedByPolicy, the policy is in deny mode."
echo "Otherwise check compliance later with: az policy state list --query \"[?complianceState=='NonCompliant'].{policy:policyDefinitionName,resource:resourceId}\" -o table"

#!/bin/bash

set -euo pipefail

UNINSTALL_MONITORING="${UNINSTALL_MONITORING:-false}"

helm uninstall arc-controller \
  --namespace arc-systems \
  --wait || true

helm uninstall arc-runner \
  --namespace arc-runners \
  --wait || true

if [[ "${UNINSTALL_MONITORING}" == "true" ]]; then
  helm uninstall kube-prometheus-stack \
    --namespace monitoring \
    --wait || true
fi

# Delete ARC CRDs if they exist.
crds_to_delete="$(kubectl get crds -o name | grep -F 'actions.github.com' || true)"
if [[ -n "${crds_to_delete}" ]]; then
  echo "Deleting ARC CRDs.."
  while IFS= read -r crd; do
    kubectl delete "${crd}"
  done <<< "${crds_to_delete}"
else
  echo "No ARC CRDs found. Skipping.."
fi

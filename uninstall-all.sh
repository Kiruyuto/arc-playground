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

# Delete CRDs
kubectl get crds | grep actions.github.com | awk '{print $1}' | xargs -r kubectl delete crd

#!/bin/bash

set -euo pipefail

ARC_CONFIG_DIR="${ARC_CONFIG_DIR:-$HOME/arc-config}"
ENABLE_MONITORING="${ENABLE_MONITORING:-true}"
PROM_SKIP_CRDS="${PROM_SKIP_CRDS:-true}"
PROM_SYNC_CRDS="${PROM_SYNC_CRDS:-true}"

sync_prometheus_crds() {
  echo "Syncing kube-prometheus-stack CRDs..."
  helm show crds prometheus-community/kube-prometheus-stack | \
    kubectl apply --server-side --force-conflicts -f -
}

# Deploy Controller
helm upgrade --install arc-controller \
  --namespace arc-systems \
  --create-namespace \
  -f "${ARC_CONFIG_DIR}/controller/values.yaml" \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

# Deploy Runner Scale Set
helm upgrade --install arc-runner \
  --namespace arc-runners \
  --create-namespace \
  -f "${ARC_CONFIG_DIR}/runner-scale-set/values.yaml" \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

# Deploy Monitoring
if [[ "${ENABLE_MONITORING}" == "true" ]]; then
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update

  if [[ "${PROM_SYNC_CRDS}" == "true" ]]; then
    sync_prometheus_crds
  fi

  PROM_CRD_ARGS=()
  if [[ "${PROM_SKIP_CRDS}" == "true" ]]; then
    PROM_CRD_ARGS+=(--skip-crds)
  fi

  helm upgrade --install kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    -f "${ARC_CONFIG_DIR}/monitoring/values-prometheus.yaml" \
    prometheus-community/kube-prometheus-stack \
    "${PROM_CRD_ARGS[@]}"

  kubectl apply -f "${ARC_CONFIG_DIR}/monitoring/podmonitors-manifest.yaml"
fi

kubectl get crds | grep actions.github.com

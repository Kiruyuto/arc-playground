#!/bin/bash

set -euo pipefail

ARC_CONFIG_DIR="${ARC_CONFIG_DIR:-$HOME/arc-config}"
APPLY_MONITORING="${APPLY_MONITORING:-true}"
PROM_SKIP_CRDS="${PROM_SKIP_CRDS:-true}"

require_values_file() {
  local values_file="$1"
  if [[ ! -f "${values_file}" ]]; then
    echo "Missing values file: ${values_file}"
    exit 1
  fi
}

upgrade_existing_release() {
  local release="$1"
  local namespace="$2"
  local values_file="$3"
  local chart="$4"
  shift 4

  if helm status "${release}" --namespace "${namespace}" >/dev/null 2>&1; then
    echo "Applying values for ${release} in namespace ${namespace}..."
    helm upgrade "${release}" \
      --namespace "${namespace}" \
      -f "${values_file}" \
      "${chart}" \
      "$@"
  else
    echo "Skipping ${release}: release not found in namespace ${namespace}."
    echo "Run ./deploy-all.sh first if this release should exist."
  fi
}

controller_values="${ARC_CONFIG_DIR}/controller/values.yaml"
runner_values="${ARC_CONFIG_DIR}/runner-scale-set/values.yaml"
monitoring_values="${ARC_CONFIG_DIR}/monitoring/values-prometheus.yaml"

require_values_file "${controller_values}"
require_values_file "${runner_values}"

upgrade_existing_release \
  arc-controller \
  arc-systems \
  "${controller_values}" \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

upgrade_existing_release \
  arc-runner \
  arc-runners \
  "${runner_values}" \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

if [[ "${APPLY_MONITORING}" == "true" ]]; then
  require_values_file "${monitoring_values}"

  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
  helm repo update >/dev/null

  monitoring_args=()
  if [[ "${PROM_SKIP_CRDS}" == "true" ]]; then
    monitoring_args+=(--skip-crds)
  fi

  upgrade_existing_release \
    kube-prometheus-stack \
    monitoring \
    "${monitoring_values}" \
    prometheus-community/kube-prometheus-stack \
    "${monitoring_args[@]}"
fi

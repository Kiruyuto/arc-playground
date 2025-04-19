#!/bin/bash

set -e

## Add openebs (Required when using containerMode.type=kubernetes)
# helm repo add openebs https://openebs.github.io/openebs
# helm repo update
# helm install openebs --namespace openebs openebs/openebs --create-namespace

# Deploy Controller
helm upgrade --install arc-controller \
  --namespace arc-systems \
  --create-namespace \
  -f ~/arc-config/controller/values.yaml \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

# Deploy Runner Scale Set
helm upgrade --install arc-runner \
  --namespace arc-runners \
  --create-namespace \
  -f ~/arc-config/runner-scale-set/values.yaml \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

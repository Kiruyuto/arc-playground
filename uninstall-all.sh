set -e

helm uninstall arc-controller \
  --namespace arc-systems \
  --wait

helm uninstall arc-runner \
  --namespace arc-runners \
  --wait

# Delete CRDs
kubectl get crds | grep actions.github.com | awk '{print $1}' | xargs kubectl delete crd
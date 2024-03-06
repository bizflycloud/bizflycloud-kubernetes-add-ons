#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="vmoperator"
CHART="vm/victoria-metrics-operator"
NAMESPACE="victoria-metrics"


################################################################################
# Install vmoperator from the Helm chart
################################################################################
helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 10m0s\
  --namespace "$NAMESPACE" \
  --values "$values"

# Install VictoriaMetrics Cluster with CRDs
if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  VMCLUSTER="$ROOT_DIR/stacks/victoria-metrics-cluster/yaml/vmcluster.yaml"
  VMAGENT="$ROOT_DIR/stacks/victoria-metrics-cluster/yaml/vmagent.yaml"
  kubectl apply -n "$NAMESPACE" -f "$VMCLUSTER"
  kubectl apply -n "$NAMESPACE" -f "$VMAGENT"
else
  # use github hosted master version of values.yml
  kubectl apply -n "$NAMESPACE" -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/victoria-metrics-cluster/yaml/vmcluster.yaml
  kubectl apply -n "$NAMESPACE" -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/victoria-metrics-cluster/yaml/vmagent.yaml
fi
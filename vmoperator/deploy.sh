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
NAMESPACE="vmoperator"
REPO_ENV=$APPLICATION_ENV

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
  script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  VMCLUSTER="${script_dir}/values.yml"
  kubectl apply -n "$NAMESPACE" -f "$VMCLUSTER"
else
  # use github hosted master version of values.yml
  kubectl apply -n "$NAMESPACE" -f https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/$REPO_ENV/vmoperator/values.yml
fi
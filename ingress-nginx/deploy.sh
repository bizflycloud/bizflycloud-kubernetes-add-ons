#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="ingress-nginx"
CHART="ingress-nginx/ingress-nginx"
CHART_VERSION="4.12.1"
NAMESPACE="ingress-nginx"

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
values="${script_dir}/values.yml"

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 10m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  "$@"

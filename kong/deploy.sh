#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add kong https://charts.konghq.com
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="kong"
CHART="kong/kong"
CHART_VERSION="2.46.0"
NAMESPACE="kong"

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

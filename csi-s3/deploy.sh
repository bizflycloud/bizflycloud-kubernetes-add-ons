#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add yandex-s3 https://yandex-cloud.github.io/k8s-csi-s3/charts
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="csi-s3"
CHART="yandex-s3/csi-s3"
CHART_VERSION="0.41.0"
NAMESPACE="csi-s3"

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

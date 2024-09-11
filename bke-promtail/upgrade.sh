#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add {{HELM_REPO_NAME}} {{HELM_REPO_URL}}
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="promtail"
CHART="sample-charts/promtail"
NAMESPACE="bke-obs-stack"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/promtail/values.yml"
else
    # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/$REPO_ENV/bke-promtail/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
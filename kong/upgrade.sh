#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add kong https://charts.konghq.com
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kong"
CHART="kong/kong"
CHART_VERSION="2.38.0"
NAMESPACE="kong"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/kong/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/master/kong/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
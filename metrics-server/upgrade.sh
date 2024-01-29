#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="metrics-server"
CHART="metrics-server/metrics-server"
NAMESPACE="metrics-server"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    script_dir="$(cd "$(dirname "$0")" && pwd)"
    values="${script_dir}/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/master/stacks/metrics-server/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \

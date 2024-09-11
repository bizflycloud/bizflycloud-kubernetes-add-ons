#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add sample-charts https://lmq1999.github.io/sample-chart/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kube-node-exporter"
CHART="sample-charts/kube-node-exporter"
NAMESPACE="bke-obs-stack"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/{{STACK_NAME}}/values.yml"
else
    # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/$REPO_ENV/bke-kube-node-exporter/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
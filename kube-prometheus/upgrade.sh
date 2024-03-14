#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kube-prometheus"
CHART="prometheus-community/kube-prometheus-stack"
NAMESPACE="kube-prometheus"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    values="${script_dir}/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/master/kube-prometheus/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
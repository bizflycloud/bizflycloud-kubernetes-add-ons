#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="ingress-nginx"
CHART="ingress-nginx/ingress-nginx"
NAMESPACE="ingress-nginx"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    script_dir="$(cd "$(dirname "$0")" && pwd)"
    values="${script_dir}/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/master/stacks/ingress-nginx/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values"

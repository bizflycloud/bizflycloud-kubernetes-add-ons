#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="argocd"
CHART="argo/argo-cd"
NAMESPACE="argocd"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/argocd/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/master/argocd/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
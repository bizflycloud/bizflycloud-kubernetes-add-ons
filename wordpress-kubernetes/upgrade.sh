#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="wordpress-kubernetes"
CHART="bitnami/wordpress"
NAMESPACE="wordpress-kubernetes"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    values="${script_dir}/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons//wordpress/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
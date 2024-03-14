#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="vmoperator"
NAMESPACE="vmoperator"
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
VMCLUSTER="${script_dir}/values.yml"
kubectl delete -n "$NAMESPACE" -f "$VMCLUSTER"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"


kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
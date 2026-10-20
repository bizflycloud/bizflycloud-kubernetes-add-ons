#!/bin/sh
set -e

################################################################################
# chart
################################################################################
STACK="vmoperator"
NAMESPACE="vmoperator"
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ -f "${script_dir}/manifests/vmcluster.yaml" ]; then
  kubectl delete --ignore-not-found=true -n "$NAMESPACE" -f "${script_dir}/manifests/vmcluster.yaml"
fi

helm uninstall "$STACK" --namespace "$NAMESPACE" 2>/dev/null || true
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"

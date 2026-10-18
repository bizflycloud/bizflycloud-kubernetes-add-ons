#!/bin/sh
set -e

################################################################################
# chart
################################################################################
STACK="{{STACK_NAME}}"
NAMESPACE="{{NAMESPACE}}"

helm uninstall "$STACK" --namespace "$NAMESPACE" 2>/dev/null || true
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"

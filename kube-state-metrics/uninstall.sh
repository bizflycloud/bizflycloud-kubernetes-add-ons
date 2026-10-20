#!/bin/sh
set -e

################################################################################
# chart
################################################################################
STACK="kube-state-metrics"
NAMESPACE="kube-state-metrics"

helm uninstall "$STACK" --namespace "$NAMESPACE" 2>/dev/null || true
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"

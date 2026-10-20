#!/bin/sh
set -e

################################################################################
# chart
################################################################################
STACK="argocd"
NAMESPACE="argocd"

helm uninstall "$STACK" --namespace "$NAMESPACE" 2>/dev/null || true
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"

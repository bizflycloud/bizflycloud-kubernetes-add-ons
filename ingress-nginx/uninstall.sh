#!/bin/sh
set -e

################################################################################
# chart
################################################################################
STACK="ingress-nginx"
NAMESPACE="ingress-nginx"

helm uninstall "$STACK" --namespace "$NAMESPACE" 2>/dev/null || true
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"

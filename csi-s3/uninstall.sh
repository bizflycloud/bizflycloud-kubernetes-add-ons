#!/bin/sh
set -e

################################################################################
# chart
################################################################################
STACK="csi-s3"
NAMESPACE="csi-s3"

helm uninstall "$STACK" --namespace "$NAMESPACE" 2>/dev/null || true
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"

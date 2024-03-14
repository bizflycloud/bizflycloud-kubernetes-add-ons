#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="wordpress-kubernetes"
NAMESPACE="wordpress-kubernetes"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
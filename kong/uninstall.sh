#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kong"
NAMESPACE="kong"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
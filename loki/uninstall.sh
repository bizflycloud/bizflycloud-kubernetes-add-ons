#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="loki"
NAMESPACE="loki"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
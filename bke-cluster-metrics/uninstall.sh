#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="bke-cluster-metrics"
NAMESPACE="bke-cluster-metrics"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="bke-cluster-log"
NAMESPACE="bke-obs-stack"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
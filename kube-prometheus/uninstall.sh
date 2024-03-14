#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kube-prometheus"
NAMESPACE="kube-prometheus"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kubearmor"
NAMESPACE="kubearmor"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
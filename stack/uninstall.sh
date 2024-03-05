#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="{{STACK_NAME}}"
NAMESPACE="{{NAMESPACE}}"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kube-node-exporter"
NAMESPACE="bke-obs-stack"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
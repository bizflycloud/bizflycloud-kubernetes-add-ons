#!/bin/sh
set -e

################################################################################
# chart
################################################################################
STACK="karpenter"
NAMESPACE="karpenter"

# Clean up Custom Resources prior to uninstallation to avoid orphaned Cloud Servers
kubectl delete --ignore-not-found=true nodepools.karpenter.sh --all
kubectl delete --ignore-not-found=true nodeclaims.karpenter.sh --all
kubectl delete --ignore-not-found=true bizflycloudnodeclasses.karpenter.bizflycloud.com --all
kubectl delete --ignore-not-found=true bizflycloudnodeclasses.bizflycloud.sh --all 2>/dev/null || true

helm uninstall "$STACK" --namespace "$NAMESPACE" 2>/dev/null || true
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"

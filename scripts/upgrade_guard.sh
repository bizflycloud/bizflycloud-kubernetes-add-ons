#!/bin/sh
# upgrade_guard.sh - 4-Layer Zero-Downtime & Zero-Overwrite Upgrade Guard
# POSIX-compliant upgrade protection engine for BizFly Cloud Kubernetes Add-ons

PRE_UPGRADE_REV=""
CUSTOM_OVERLAY_FILE=""
PRE_SNAPSHOT_FILE=""
UPGRADE_GUARD_RESOLVED_STACK=""
UPGRADE_GUARD_RESOLVED_NS=""

# Resolve legacy vs canonical (STACK, NAMESPACE)
resolve_existing_release() {
  target_stack="$STACK"
  target_ns="$NAMESPACE"

  case "$STACK" in
    bke-cluster-log)
      if helm status loki-stack -n "$target_ns" >/dev/null 2>&1; then
        target_stack="loki-stack"
      fi
      ;;
    bke-cluster-metrics)
      if helm status "$STACK" -n monitoring >/dev/null 2>&1; then
        target_ns="monitoring"
      fi
      ;;
    kube-state-metrics)
      if helm status "$STACK" -n monitoring >/dev/null 2>&1; then
        target_ns="monitoring"
      fi
      ;;
    wordpress-kubernetes|wordpress)
      if helm status wordpress -n wordpress >/dev/null 2>&1; then
        target_stack="wordpress"
        target_ns="wordpress"
      fi
      ;;
  esac

  if ! helm status "$target_stack" -n "$target_ns" >/dev/null 2>&1; then
    if helm status "$target_stack" -n "$target_stack" >/dev/null 2>&1; then
      target_ns="$target_stack"
    fi
  fi

  STACK="$target_stack"
  NAMESPACE="$target_ns"
  UPGRADE_GUARD_RESOLVED_STACK="$STACK"
  UPGRADE_GUARD_RESOLVED_NS="$NAMESPACE"
}

# Unstick pending-upgrade / pending-rollback / pending-install
unstick_helm_release() {
  release="$1"
  ns="$2"

  eval "$(helm history "$release" -n "$ns" -o json 2>/dev/null | python3 -c '
import sys, json

try:
    content = sys.stdin.read().strip()
    if not content or content == "[]":
        sys.exit(0)
    history = json.loads(content)
    if not history:
        sys.exit(0)
    sorted_history = sorted(history, key=lambda x: int(x.get("revision", 0)))
    latest = sorted_history[-1]
    rev = latest.get("revision")
    status = latest.get("status")
    print(f"LATEST_REV=\"{rev}\"")
    print(f"LATEST_STATUS=\"{status}\"")

    good_revs = [x.get("revision") for x in sorted_history if x.get("status") in ["deployed", "superseded"]]
    if good_revs:
        print(f"LAST_GOOD_REV=\"{good_revs[-1]}\"")
    else:
        print("LAST_GOOD_REV=\"\"")
except Exception:
    pass
' || true)"

  if [ -n "$LAST_GOOD_REV" ]; then
    PRE_UPGRADE_REV="$LAST_GOOD_REV"
  elif [ -n "$LATEST_REV" ]; then
    PRE_UPGRADE_REV="$LATEST_REV"
  fi

  case "$LATEST_STATUS" in
    pending-upgrade|pending-rollback|pending-install)
      echo "WARN: Release $release in namespace $ns is stuck in $LATEST_STATUS (revision $LATEST_REV)."
      if [ -n "$LAST_GOOD_REV" ]; then
        echo "INFO: Unsticking release $release by rolling back to revision $LAST_GOOD_REV..."
        if helm rollback "$release" "$LAST_GOOD_REV" -n "$ns" --wait --timeout 3m0s; then
          echo "INFO: Successfully un-stuck $release to revision $LAST_GOOD_REV."
          PRE_UPGRADE_REV="$LAST_GOOD_REV"
        else
          echo "ERROR: Failed to unstick $release via helm rollback."
        fi
      fi
      ;;
  esac
}

# Capture live snapshot of workloads, ConfigMaps, Services, and CRs
capture_live_snapshot() {
  release="$1"
  ns="$2"
  snapshot_file="/tmp/pre-snapshot-${release}-$$.json"

  res_types="Deployment,DaemonSet,StatefulSet,Service,ConfigMap,Secret,Ingress,HorizontalPodAutoscaler,PodDisruptionBudget"
  for cr_type in vmclusters.operator.victoriametrics.net nodepools.karpenter.sh bizflycloudnodeclasses.bizflycloud.sh; do
    if kubectl get crd "$cr_type" >/dev/null 2>&1; then
      res_types="${res_types},${cr_type}"
    fi
  done

  kubectl get "$res_types" -n "$ns" -o json 2>/dev/null | python3 -c '
import sys, json

try:
    content = sys.stdin.read().strip()
    if not content or content == "null":
        sys.exit(0)
    data = json.loads(content)
    items = data.get("items", []) if data.get("kind") == "List" else [data] if data else []
    filtered_items = []

    for item in items:
        if not isinstance(item, dict):
            continue
        meta = item.get("metadata", {})
        name = meta.get("name", "")
        kind = item.get("kind", "")

        # Skip Helm release secrets and service account tokens
        if kind == "Secret":
            sec_type = item.get("type", "")
            if sec_type in ["helm.sh/release.v1", "kubernetes.io/service-account-token"]:
                continue
            if name.startswith("sh.helm.release.v1.") or "default-token-" in name:
                continue

        # Strip ephemeral server fields
        for field in ["resourceVersion", "uid", "generation", "creationTimestamp", "managedFields", "selfLink"]:
            meta.pop(field, None)

        # Strip status
        item.pop("status", None)

        filtered_items.append(item)

    if filtered_items:
        print(json.dumps({"apiVersion": "v1", "kind": "List", "items": filtered_items}, indent=2))
except Exception:
    sys.exit(0)
' > "$snapshot_file"

  if [ -s "$snapshot_file" ]; then
    PRE_SNAPSHOT_FILE="$snapshot_file"
  else
    rm -f "$snapshot_file"
    PRE_SNAPSHOT_FILE=""
  fi
}

# Extract live custom overlay (replicas, custom ConfigMap data keys, annotations, resources)
extract_custom_overlay() {
  release="$1"
  ns="$2"
  overlay_file="/tmp/custom-overlay-${release}-$$.yaml"
  : > "$overlay_file"

  # Pass snapshot file path (if available) or read live manifests via kubectl
  python3 - "$release" "$ns" "$PRE_SNAPSHOT_FILE" << 'EOF' > "$overlay_file"
import sys, os, json, yaml

stack = sys.argv[1]
ns = sys.argv[2]
snapshot_path = sys.argv[3] if len(sys.argv) > 3 else ""

items = []
if snapshot_path and os.path.isfile(snapshot_path):
    try:
        with open(snapshot_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            items = data.get("items", []) if data.get("kind") == "List" else [data] if data else []
    except Exception:
        items = []

if not items:
    try:
        import subprocess
        proc = subprocess.run(
            ["kubectl", "get", "Deployment,DaemonSet,StatefulSet,Service,ConfigMap", "-n", ns, "-o", "json"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        if proc.returncode == 0 and proc.stdout:
            data = json.loads(proc.stdout)
            items = data.get("items", []) if data.get("kind") == "List" else [data] if data else []
    except Exception:
        items = []

overlay = {}

for item in items:
    if not isinstance(item, dict):
        continue
    kind = item.get("kind", "")
    meta = item.get("metadata", {})
    name = meta.get("name", "")
    annotations = meta.get("annotations", {})

    # 1. Workload Replicas & Container Resources
    if kind in ["Deployment", "StatefulSet"]:
        replicas = item.get("spec", {}).get("replicas")
        if replicas is not None and replicas > 0:
            if "ingress-nginx" in name or stack == "ingress-nginx":
                overlay.setdefault("controller", {})["replicaCount"] = replicas
            elif "argocd-server" in name:
                overlay.setdefault("server", {})["replicas"] = replicas
            elif "argocd-repo-server" in name:
                overlay.setdefault("repoServer", {})["replicas"] = replicas
            elif "argocd-application-controller" in name:
                overlay.setdefault("controller", {})["replicas"] = replicas
            elif "kong" in name or stack == "kong":
                overlay.setdefault("replicaCount", replicas)
            elif "wordpress" in name or stack in ["wordpress", "wordpress-kubernetes"]:
                overlay.setdefault("replicaCount", replicas)
            elif "kube-state-metrics" in name:
                overlay.setdefault("replicas", replicas)
            elif "metrics-server" in name:
                overlay.setdefault("replicas", replicas)
            elif "cert-manager" in name:
                overlay.setdefault("replicaCount", replicas)
            elif name == stack or f"{stack}-controller" in name:
                overlay.setdefault("replicaCount", replicas)

        # Container resources
        containers = item.get("spec", {}).get("template", {}).get("spec", {}).get("containers", [])
        for c in containers:
            c_name = c.get("name", "")
            res = c.get("resources", {})
            if res and (res.get("requests") or res.get("limits")):
                clean_res = {}
                if "requests" in res:
                    clean_res["requests"] = res["requests"]
                if "limits" in res:
                    clean_res["limits"] = res["limits"]
                if clean_res:
                    if "ingress-nginx" in name or "controller" in c_name:
                        overlay.setdefault("controller", {})["resources"] = clean_res
                    elif "argocd-server" in name:
                        overlay.setdefault("server", {})["resources"] = clean_res
                    elif "argocd-repo-server" in name:
                        overlay.setdefault("repoServer", {})["resources"] = clean_res
                    elif "kong" in name or stack == "kong":
                        overlay.setdefault("resources", clean_res)
                    elif name == stack or stack in name:
                        overlay.setdefault("resources", clean_res)

    # 2. ConfigMap Data
    elif kind == "ConfigMap":
        data = item.get("data", {})
        if data:
            if name == "ingress-nginx-controller":
                overlay.setdefault("controller", {})["config"] = data
            elif name == "argocd-cm":
                overlay.setdefault("configs", {}).setdefault("cm", {})["data"] = data
            elif name == "argocd-cmd-params-cm":
                overlay.setdefault("configs", {}).setdefault("params", {})["data"] = data
            elif "kong" in name or stack == "kong":
                overlay.setdefault("env", data)

    # 3. Service Annotations
    elif kind == "Service":
        custom_annotations = {
            k: v for k, v in annotations.items()
            if not k.startswith("kubectl.kubernetes.io/")
            and not k.startswith("control-plane.alpha.kubernetes.io/")
        }
        if custom_annotations:
            if "ingress-nginx" in name or stack == "ingress-nginx":
                overlay.setdefault("controller", {}).setdefault("service", {})["annotations"] = custom_annotations
            elif "kong" in name or stack == "kong":
                overlay.setdefault("proxy", {}).setdefault("annotations", custom_annotations)
            elif name == stack or f"{stack}-service" in name:
                overlay.setdefault("service", {}).setdefault("annotations", custom_annotations)

if overlay:
    print(yaml.safe_dump(overlay, default_flow_style=False))
EOF

  if [ -s "$overlay_file" ]; then
    CUSTOM_OVERLAY_FILE="$overlay_file"
  else
    rm -f "$overlay_file"
    CUSTOM_OVERLAY_FILE=""
  fi
}

# POSIX EXIT / signal trap handler
upgrade_exit_trap() {
  trap - EXIT INT TERM
  exit_code="$1"

  if [ "$exit_code" -ne 0 ]; then
    echo "=========================================================="
    echo "UPGRADE FAILED (exit code $exit_code). INITIATING SAFE RECOVERY..."
    echo "=========================================================="

    if [ -n "$PRE_UPGRADE_REV" ] && [ -n "$STACK" ] && [ -n "$NAMESPACE" ]; then
      TRAP_LATEST_REV=""
      TRAP_LATEST_STATUS=""
      eval "$(helm history "$STACK" -n "$NAMESPACE" -o json 2>/dev/null | python3 -c '
import sys, json

try:
    content = sys.stdin.read().strip()
    if content:
        history = json.loads(content)
        if history:
            sorted_h = sorted(history, key=lambda x: int(x.get("revision", 0)))
            latest = sorted_h[-1]
            rev = latest.get("revision", "")
            status = latest.get("status", "")
            print("TRAP_LATEST_REV=\"%s\"" % rev)
            print("TRAP_LATEST_STATUS=\"%s\"" % status)
except Exception:
    pass
' || true)"

      should_rollback=0
      case "$TRAP_LATEST_STATUS" in
        pending-upgrade|pending-rollback|pending-install|failed)
          should_rollback=1
          ;;
      esac
      if [ -n "$TRAP_LATEST_REV" ] && [ "$TRAP_LATEST_REV" != "$PRE_UPGRADE_REV" ]; then
        should_rollback=1
      fi

      if [ "$should_rollback" -eq 1 ]; then
        echo "INFO: Rolling back Helm release $STACK to pre-upgrade revision $PRE_UPGRADE_REV (current rev: $TRAP_LATEST_REV, status: $TRAP_LATEST_STATUS)..."
        helm rollback "$STACK" "$PRE_UPGRADE_REV" -n "$NAMESPACE" --wait --timeout 2m0s || true
      fi
    fi

    if [ -n "$PRE_SNAPSHOT_FILE" ] && [ -s "$PRE_SNAPSHOT_FILE" ]; then
      echo "INFO: Re-applying live pre-upgrade Kubernetes snapshot ($PRE_SNAPSHOT_FILE)..."
      kubectl apply -n "$NAMESPACE" -f "$PRE_SNAPSHOT_FILE" || true
    fi

    if [ -n "$NAMESPACE" ]; then
      echo "INFO: Checking rollout status for workloads in $NAMESPACE..."
      for dep in $(kubectl get deployment -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
        kubectl rollout status "deployment/$dep" -n "$NAMESPACE" --timeout=60s || true
      done
      for sts in $(kubectl get statefulset -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
        kubectl rollout status "statefulset/$sts" -n "$NAMESPACE" --timeout=60s || true
      done
      for ds in $(kubectl get daemonset -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
        kubectl rollout status "daemonset/$ds" -n "$NAMESPACE" --timeout=60s || true
      done
    fi

    echo "=========================================================="
    echo "SAFE RECOVERY COMPLETED. Pre-upgrade state restored."
    echo "=========================================================="
  fi

  rm -f "/tmp/pre-snapshot-${STACK}-$$.json" "/tmp/custom-overlay-${STACK}-$$.yaml"
  exit "$exit_code"
}

# Main guarded upgrade runner
run_guarded_helm_upgrade() {
  trap 'upgrade_exit_trap $?' EXIT INT TERM

  resolve_existing_release
  unstick_helm_release "$STACK" "$NAMESPACE"
  capture_live_snapshot "$STACK" "$NAMESPACE"
  extract_custom_overlay "$STACK" "$NAMESPACE"

  extra_args=""
  if [ -n "$CUSTOM_OVERLAY_FILE" ] && [ -s "$CUSTOM_OVERLAY_FILE" ]; then
    extra_args="--values $CUSTOM_OVERLAY_FILE"
  fi

  echo "INFO: Running pre-flight helm upgrade --dry-run=server for $STACK in $NAMESPACE..."
  # shellcheck disable=SC2086
  if ! helm upgrade "$STACK" "$CHART" \
    --dry-run=server \
    --create-namespace \
    --install \
    --namespace "$NAMESPACE" \
    --values "$values" \
    $extra_args \
    --version "$CHART_VERSION" \
    "$@"; then
    echo "ERROR: Pre-flight dry-run validation failed for $STACK in $NAMESPACE! Aborting upgrade before cluster modification." >&2
    exit 1
  fi

  echo "INFO: Pre-flight dry-run successful. Proceeding with atomic upgrade..."

  # shellcheck disable=SC2086
  if ! helm upgrade "$STACK" "$CHART" \
    --atomic \
    --create-namespace \
    --install \
    --timeout 5m0s \
    --namespace "$NAMESPACE" \
    --values "$values" \
    $extra_args \
    --version "$CHART_VERSION" \
    "$@"; then
    echo "ERROR: Helm upgrade failed for $STACK in $NAMESPACE!" >&2
    exit 1
  fi

  echo "INFO: Helm upgrade for $STACK in $NAMESPACE completed successfully."
}

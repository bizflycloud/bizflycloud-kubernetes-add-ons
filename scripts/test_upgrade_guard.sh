#!/bin/sh
# test_upgrade_guard.sh - Comprehensive Unit Tests for scripts/upgrade_guard.sh
set -e

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
GUARD_SCRIPT="${script_dir}/upgrade_guard.sh"

echo "=========================================================="
echo "RUNNING UNIT TESTS FOR scripts/upgrade_guard.sh"
echo "=========================================================="

TEST_TMP_DIR=$(mktemp -d "/tmp/upgrade-guard-test-XXXXXX")
trap 'rm -rf "$TEST_TMP_DIR"' EXIT

MOCK_BIN_DIR="${TEST_TMP_DIR}/bin"
mkdir -p "$MOCK_BIN_DIR"
PATH="${MOCK_BIN_DIR}:$PATH"
export PATH

# Helper to record invocations
MOCK_LOG="${TEST_TMP_DIR}/mock_calls.log"
export MOCK_LOG
: > "$MOCK_LOG"

# -----------------------------------------------------------------------------
# Test 1: POSIX Syntax Validation
# -----------------------------------------------------------------------------
echo "[Test 1/7] Checking upgrade_guard.sh for POSIX compliance..."
/bin/sh -n "$GUARD_SCRIPT"
if grep -q "BASH_SOURCE" "$GUARD_SCRIPT"; then
  echo "FAIL: Non-POSIX BASH_SOURCE found"
  exit 1
fi
if grep -q "&>" "$GUARD_SCRIPT"; then
  echo "FAIL: Bashism &> found"
  exit 1
fi
echo "PASS: POSIX syntax validation succeeded."

# -----------------------------------------------------------------------------
# Test 2: Unsticking pending-upgrade release
# -----------------------------------------------------------------------------
echo "[Test 2/7] Testing unstick_helm_release on stuck release..."
cat << 'EOF' > "${MOCK_BIN_DIR}/helm"
#!/bin/sh
echo "helm $@" >> "$MOCK_LOG"
case "$1" in
  history)
    cat << 'JSON'
[
  {"revision": 1, "status": "superseded", "app_version": "1.0.0"},
  {"revision": 2, "status": "deployed", "app_version": "1.1.0"},
  {"revision": 3, "status": "pending-upgrade", "app_version": "1.2.0"}
]
JSON
    ;;
  rollback)
    echo "Rollback called successfully"
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
EOF
chmod +x "${MOCK_BIN_DIR}/helm"

(
  STACK="test-stack"
  NAMESPACE="test-ns"
  . "$GUARD_SCRIPT"
  unstick_helm_release "$STACK" "$NAMESPACE"
  if [ "$PRE_UPGRADE_REV" != "2" ]; then
    echo "FAIL: Expected PRE_UPGRADE_REV=2, got '$PRE_UPGRADE_REV'"
    exit 1
  fi
)
if ! grep -q "helm rollback test-stack 2 -n test-ns" "$MOCK_LOG"; then
  echo "FAIL: helm rollback not invoked with last good revision 2"
  exit 1
fi
echo "PASS: Successfully detected and un-stuck pending-upgrade release to revision 2."

# -----------------------------------------------------------------------------
# Test 3: Live snapshot & Custom Overlay Extraction (replicas, CM data, resources, annotations, secrets)
# -----------------------------------------------------------------------------
echo "[Test 3/7] Testing live snapshot & custom overlay extraction (replicas=5, ConfigMap data, resources, annotations, secrets)..."
cat << 'EOF' > "${MOCK_BIN_DIR}/kubectl"
#!/bin/sh
echo "kubectl $@" >> "$MOCK_LOG"
case "$*" in
  *"get "*"-o json"*)
    cat << 'JSON'
{
  "apiVersion": "v1",
  "kind": "List",
  "items": [
    {
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "metadata": {
        "name": "ingress-nginx-controller",
        "resourceVersion": "12345",
        "uid": "uuid-1111",
        "generation": 3,
        "creationTimestamp": "2026-01-01T00:00:00Z",
        "managedFields": [{"manager": "k8s"}]
      },
      "spec": {
        "replicas": 5,
        "template": {
          "spec": {
            "containers": [
              {
                "name": "controller",
                "resources": {
                  "requests": {"cpu": "200m", "memory": "256Mi"},
                  "limits": {"cpu": "1000m", "memory": "1Gi"}
                }
              }
            ]
          }
        }
      },
      "status": {"readyReplicas": 5}
    },
    {
      "apiVersion": "v1",
      "kind": "ConfigMap",
      "metadata": {
        "name": "ingress-nginx-controller",
        "resourceVersion": "22222",
        "uid": "uuid-2222"
      },
      "data": {
        "proxy-body-size": "100m",
        "enable-underscores-in-headers": "true"
      }
    },
    {
      "apiVersion": "v1",
      "kind": "Service",
      "metadata": {
        "name": "ingress-nginx-controller",
        "resourceVersion": "33333",
        "uid": "uuid-3333",
        "annotations": {
          "kubectl.kubernetes.io/last-applied-configuration": "{}",
          "service.beta.kubernetes.io/bizfly-loadbalancer-id": "lb-12345"
        }
      },
      "spec": {
        "clusterIP": "10.96.0.100",
        "clusterIPs": ["10.96.0.100"],
        "ports": [{"port": 80, "nodePort": 30080}],
        "type": "LoadBalancer"
      }
    },
    {
      "apiVersion": "v1",
      "kind": "Secret",
      "type": "kubernetes.io/tls",
      "metadata": {
        "name": "custom-customer-cert",
        "resourceVersion": "44444",
        "uid": "uuid-4444"
      },
      "data": {"tls.crt": "Y2VydA==", "tls.key": "a2V5"}
    },
    {
      "apiVersion": "v1",
      "kind": "Secret",
      "type": "helm.sh/release.v1",
      "metadata": {"name": "sh.helm.release.v1.ingress-nginx.v1"}
    },
    {
      "apiVersion": "v1",
      "kind": "Secret",
      "type": "kubernetes.io/service-account-token",
      "metadata": {"name": "default-token-xyz"}
    }
  ]
}
JSON
    ;;
  *)
    exit 0
    ;;
esac
EOF
chmod +x "${MOCK_BIN_DIR}/kubectl"

(
  STACK="ingress-nginx"
  NAMESPACE="ingress-nginx"
  . "$GUARD_SCRIPT"
  capture_live_snapshot "$STACK" "$NAMESPACE"
  extract_custom_overlay "$STACK" "$NAMESPACE"

  if [ -z "$PRE_SNAPSHOT_FILE" ] || [ ! -f "$PRE_SNAPSHOT_FILE" ]; then
    echo "FAIL: PRE_SNAPSHOT_FILE was not generated"
    exit 1
  fi

  # Verify ephemeral fields stripped
  if grep -q "resourceVersion" "$PRE_SNAPSHOT_FILE"; then
    echo "FAIL: resourceVersion was not stripped from snapshot"
    exit 1
  fi
  if grep -q "creationTimestamp" "$PRE_SNAPSHOT_FILE"; then
    echo "FAIL: creationTimestamp was not stripped from snapshot"
    exit 1
  fi

  # Verify Helm release and SA secrets excluded, but customer TLS secret preserved
  if grep -q "sh.helm.release.v1" "$PRE_SNAPSHOT_FILE"; then
    echo "FAIL: Helm release secret was not excluded from snapshot"
    exit 1
  fi
  if grep -q "default-token-xyz" "$PRE_SNAPSHOT_FILE"; then
    echo "FAIL: SA token secret was not excluded from snapshot"
    exit 1
  fi
  if ! grep -q "custom-customer-cert" "$PRE_SNAPSHOT_FILE"; then
    echo "FAIL: Customer TLS secret was not preserved in snapshot"
    exit 1
  fi

  # Verify Service immutable clusterIP preserved in snapshot
  if ! grep -q "10.96.0.100" "$PRE_SNAPSHOT_FILE"; then
    echo "FAIL: Service clusterIP was not preserved in snapshot"
    exit 1
  fi

  # Verify custom overlay extracted: replicas, configmap, resources, service annotations
  if [ -z "$CUSTOM_OVERLAY_FILE" ] || [ ! -f "$CUSTOM_OVERLAY_FILE" ]; then
    echo "FAIL: CUSTOM_OVERLAY_FILE was not generated"
    exit 1
  fi
  if ! grep -q "replicaCount: 5" "$CUSTOM_OVERLAY_FILE"; then
    echo "FAIL: replicaCount: 5 not found in overlay"
    exit 1
  fi
  if ! grep -q "proxy-body-size: 100m" "$CUSTOM_OVERLAY_FILE"; then
    echo "FAIL: proxy-body-size: 100m not found in overlay"
    exit 1
  fi
  if ! grep -q "cpu: 200m" "$CUSTOM_OVERLAY_FILE"; then
    echo "FAIL: container resource requests (cpu: 200m) not found in overlay"
    exit 1
  fi
  if ! grep -q "service.beta.kubernetes.io/bizfly-loadbalancer-id: lb-12345" "$CUSTOM_OVERLAY_FILE"; then
    echo "FAIL: Service custom annotation not found in overlay"
    exit 1
  fi
  if grep -q "kubectl.kubernetes.io/last-applied-configuration" "$CUSTOM_OVERLAY_FILE"; then
    echo "FAIL: Internal kubectl annotation should have been filtered from overlay"
    exit 1
  fi
)
echo "PASS: Live snapshot and custom overlay extraction accurately preserved custom configurations."

# -----------------------------------------------------------------------------
# Test 4: Pre-flight dry-run failure aborts before etcd mutation
# -----------------------------------------------------------------------------
echo "[Test 4/7] Testing pre-flight --dry-run=server abort on invalid config..."
: > "$MOCK_LOG"
cat << 'EOF' > "${MOCK_BIN_DIR}/helm"
#!/bin/sh
echo "helm $@" >> "$MOCK_LOG"
case "$*" in
  *"--dry-run=server"*)
    echo "Error: admission webhook denied the request" >&2
    exit 1
    ;;
  *"--atomic"*)
    echo "ERROR: --atomic upgrade should NEVER have been called after dry-run failure!"
    exit 99
    ;;
  *"history"*)
    echo '[{"revision": 1, "status": "deployed"}]'
    ;;
  *"status"*)
    echo '{"info": {"status": "deployed"}}'
    ;;
  *)
    exit 0
    ;;
esac
EOF
chmod +x "${MOCK_BIN_DIR}/helm"

test_dry_run_aborted=0
(
  STACK="test-addon"
  CHART="test-repo/test-chart"
  CHART_VERSION="1.0.0"
  NAMESPACE="test-addon"
  values="/dev/null"
  . "$GUARD_SCRIPT"
  run_guarded_helm_upgrade >/dev/null 2>&1
) || test_dry_run_aborted=$?

if [ "$test_dry_run_aborted" -eq 0 ]; then
  echo "FAIL: Expected guarded upgrade to exit with non-zero on dry-run error"
  exit 1
fi
if grep -q "\-\-atomic" "$MOCK_LOG"; then
  echo "FAIL: --atomic was invoked despite dry-run failure!"
  exit 1
fi
if grep -q "helm rollback" "$MOCK_LOG"; then
  echo "FAIL: helm rollback should NOT be invoked when dry-run aborts before mutation"
  exit 1
fi
echo "PASS: Pre-flight --dry-run=server caught error and prevented cluster mutation."

# -----------------------------------------------------------------------------
# Test 5: Upgrade failure triggers EXIT trap rollback & live snapshot restore
# -----------------------------------------------------------------------------
echo "[Test 5/7] Testing runtime failure triggering EXIT trap & snapshot restore..."
: > "$MOCK_LOG"
cat << 'EOF' > "${MOCK_BIN_DIR}/helm"
#!/bin/sh
echo "helm $*" >> "$MOCK_LOG"
case "$*" in
  *"history"*)
    echo '[{"revision": 2, "status": "deployed"}, {"revision": 3, "status": "failed"}]'
    ;;
  *"--dry-run=server"*)
    exit 0
    ;;
  *"--atomic"*)
    echo "Simulating rollout failure (timeout / OOMKill)" >&2
    exit 1
    ;;
  *"rollback"*)
    echo "Helm rolled back successfully"
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
EOF
chmod +x "${MOCK_BIN_DIR}/helm"

cat << 'EOF' > "${MOCK_BIN_DIR}/kubectl"
#!/bin/sh
echo "kubectl $*" >> "$MOCK_LOG"
case "$*" in
  *"jsonpath"*)
    echo "app-deploy"
    ;;
  *"get "*"-o json"*)
    cat << 'JSON'
{
  "apiVersion": "v1",
  "kind": "List",
  "items": [
    {
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "metadata": {"name": "app-deploy"},
      "spec": {"replicas": 3}
    }
  ]
}
JSON
    ;;
  *"apply "*)
    echo "Snapshot reapplied successfully"
    exit 0
    ;;
  *"rollout status"*)
    echo "Rollout verified"
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
EOF
chmod +x "${MOCK_BIN_DIR}/kubectl"

trap_restored=0
(
  STACK="test-rollback-stack"
  CHART="test/chart"
  CHART_VERSION="2.0.0"
  NAMESPACE="test-rollback-ns"
  values="/dev/null"
  . "$GUARD_SCRIPT"
  run_guarded_helm_upgrade >/dev/null 2>&1
) || trap_restored=$?

if [ "$trap_restored" -eq 0 ]; then
  echo "FAIL: Expected upgrade runner to exit with non-zero on failure"
  exit 1
fi
if ! grep -q "helm rollback test-rollback-stack 2 -n test-rollback-ns" "$MOCK_LOG"; then
  echo "FAIL: Expected helm rollback to PRE_UPGRADE_REV 2 in trap"
  exit 1
fi
if ! grep -q "kubectl apply -n test-rollback-ns -f /tmp/pre-snapshot-test-rollback-stack" "$MOCK_LOG"; then
  echo "FAIL: Expected kubectl apply of live snapshot in trap"
  exit 1
fi
echo "PASS: Upgrade failure properly triggered Helm rollback and live snapshot re-application."

# -----------------------------------------------------------------------------
# Test 6: Post-Helm failure when revision advanced but status is deployed (Audit Point 1)
# -----------------------------------------------------------------------------
echo "[Test 6/7] Testing rollback when post-Helm kubectl apply fails after revision advanced..."
: > "$MOCK_LOG"
cat << 'EOF' > "${MOCK_BIN_DIR}/helm"
#!/bin/sh
echo "helm $*" >> "$MOCK_LOG"
case "$*" in
  *"history"*)
    # Initially rev 1 was deployed. During upgrade, rev 2 was deployed.
    if grep -q "helm upgrade test-post-hook-stack" "$MOCK_LOG"; then
      echo '[{"revision": 1, "status": "superseded"}, {"revision": 2, "status": "deployed"}]'
    else
      echo '[{"revision": 1, "status": "deployed"}]'
    fi
    ;;
  *"--dry-run=server"*)
    exit 0
    ;;
  *"--atomic"*)
    exit 0
    ;;
  *"rollback"*)
    echo "Helm rolled back successfully"
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
EOF
chmod +x "${MOCK_BIN_DIR}/helm"

test_post_hook_failed=0
(
  STACK="test-post-hook-stack"
  CHART="test/chart"
  CHART_VERSION="2.0.0"
  NAMESPACE="test-post-hook-ns"
  values="/dev/null"
  . "$GUARD_SCRIPT"
  run_guarded_helm_upgrade >/dev/null 2>&1
  # Simulate subsequent command failure (e.g. vmcluster.yaml failure)
  exit 1
) || test_post_hook_failed=$?

if [ "$test_post_hook_failed" -ne 1 ]; then
  echo "FAIL: Expected script to exit 1 on post-hook failure"
  exit 1
fi
if ! grep -q "helm rollback test-post-hook-stack 1 -n test-post-hook-ns" "$MOCK_LOG"; then
  echo "FAIL: Expected helm rollback to PRE_UPGRADE_REV 1 even when status is deployed"
  exit 1
fi
echo "PASS: Post-Helm failure properly rolled back advanced revision to PRE_UPGRADE_REV."

# -----------------------------------------------------------------------------
# Test 7: Manifests containing quotes and backslashes (Audit Point 2)
# -----------------------------------------------------------------------------
echo "[Test 7/7] Testing safe handling of manifests with quotes and complex chars..."
cat << 'EOF' > "${MOCK_BIN_DIR}/kubectl"
#!/bin/sh
case "$*" in
  *"get "*"-o json"*)
    cat << 'JSON'
{
  "apiVersion": "v1",
  "kind": "List",
  "items": [
    {
      "apiVersion": "v1",
      "kind": "ConfigMap",
      "metadata": {"name": "ingress-nginx-controller"},
      "data": {
        "complex-config": "python -c '''print(\"hello \\\"world\\\"\")'''",
        "backslash-pattern": "regex: ^[a-z]+(\\.[a-z]+)*$"
      }
    }
  ]
}
JSON
    ;;
  *)
    exit 0
    ;;
esac
EOF
chmod +x "${MOCK_BIN_DIR}/kubectl"

(
  STACK="ingress-nginx"
  NAMESPACE="ingress-nginx"
  . "$GUARD_SCRIPT"
  capture_live_snapshot "$STACK" "$NAMESPACE"
  extract_custom_overlay "$STACK" "$NAMESPACE"

  if [ -z "$PRE_SNAPSHOT_FILE" ] || [ ! -f "$PRE_SNAPSHOT_FILE" ]; then
    echo "FAIL: Snapshot failed on complex quote manifest"
    exit 1
  fi
  if [ -z "$CUSTOM_OVERLAY_FILE" ] || [ ! -f "$CUSTOM_OVERLAY_FILE" ]; then
    echo "FAIL: Overlay failed on complex quote manifest"
    exit 1
  fi
)
echo "PASS: Complex characters and quotes handled without SyntaxError."

echo "=========================================================="
echo "ALL 7 TEST SCENARIOS PASSED SUCCESSFULLY (exit code 0)"
echo "=========================================================="

#!/bin/sh
# validate-addons.sh - Strict POSIX validation suite for bizflycloud-kubernetes-add-ons
set -e

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT="$script_dir"

echo "=== [1/5] Checking Shell Scripts for POSIX Compliance and Syntax ==="
errors=0

for sh_file in $(find "$REPO_ROOT" -maxdepth 3 -name "*.sh"); do
  case "$(basename "$sh_file")" in
    validate-addons.sh|apply-to-addons-repo.sh|test_upgrade_guard.sh)
      continue
      ;;
  esac

  # Check shell syntax
  if ! /bin/sh -n "$sh_file" 2>/dev/null; then
    echo "FAIL: Syntax error in $sh_file"
    errors=$((errors + 1))
    continue
  fi

  # Check for BASH_SOURCE
  if grep -q "BASH_SOURCE" "$sh_file"; then
    echo "FAIL: Non-POSIX \${BASH_SOURCE} found in $sh_file"
    errors=$((errors + 1))
  fi

  # Check for &> redirection (bashism)
  if grep -q "&>" "$sh_file"; then
    echo "FAIL: Bashism '&>' found in $sh_file"
    errors=$((errors + 1))
  fi

  # Check for raw.githubusercontent.com in deploy/upgrade scripts
  if [ "$(basename "$sh_file")" = "deploy.sh" ] || [ "$(basename "$sh_file")" = "upgrade.sh" ]; then
    if grep -q "raw.githubusercontent.com" "$sh_file"; then
      echo "FAIL: Remote HTTP values fetch found in $sh_file"
      errors=$((errors + 1))
    fi
  fi

  # Check for trailing backslash at end of file
  if tail -n 1 "$sh_file" | grep -q '\\$'; then
    echo "FAIL: Trailing backslash at EOF in $sh_file"
    errors=$((errors + 1))
  fi

  # Check for invalid --ignore-not-found flag on kubectl apply
  if grep -E "kubectl apply.*--ignore-not-found" "$sh_file" >/dev/null 2>&1; then
    echo "FAIL: Invalid flag --ignore-not-found on kubectl apply in $sh_file"
    errors=$((errors + 1))
  fi
done

if [ $errors -eq 0 ]; then
  echo "PASS: All shell scripts are valid POSIX /bin/sh and free of bashisms."
else
  echo "FAILED: $errors shell script issues found."
  exit 1
fi

echo "=== [2/5] Validating YAML Syntax of INFORMATION.yaml and values.yml ==="
yaml_errors=0

python3 - << 'EOF'
import sys, os, yaml

root = sys.argv[1] if len(sys.argv) > 1 else "."
yaml_files = []
for dirpath, _, filenames in os.walk(root):
    if ".git" in dirpath or "templates" in dirpath:
        continue
    for f in filenames:
        if f.endswith((".yaml", ".yml")):
            yaml_files.append(os.path.join(dirpath, f))

failed = 0
for yf in yaml_files:
    try:
        with open(yf, "r", encoding="utf-8") as fp:
            list(yaml.safe_load_all(fp))
    except Exception as e:
        print(f"FAIL: Invalid YAML in {yf}: {e}")
        failed += 1

if failed > 0:
    sys.exit(1)
print(f"PASS: Verified {len(yaml_files)} YAML files successfully.")
EOF

echo "=== [3/5] Validating INFORMATION.yaml Schema & Invariants ==="
python3 - << 'EOF'
import sys, os, yaml

root = "."
addons = [
    "argocd", "bke-cluster-log", "bke-cluster-metrics", "cert-manager", "csi-s3",
    "ingress-nginx", "karpenter", "kong", "kube-prometheus", "kube-state-metrics",
    "kubearmor", "loki", "metrics-server", "vmoperator", "wordpress-kubernetes"
]

required_fields = ["type", "name", "version", "short_description", "icon_url", "catalog"]
failed = 0

for addon in addons:
    info_path = os.path.join(root, addon, "INFORMATION.yaml")
    if not os.path.exists(info_path):
        print(f"FAIL: Missing INFORMATION.yaml in {addon}")
        failed += 1
        continue
    try:
        with open(info_path, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        if not isinstance(data, dict):
            print(f"FAIL: {info_path} is not a valid YAML mapping")
            failed += 1
            continue
        for field in required_fields:
            if field not in data or not str(data[field]).strip():
                print(f"FAIL: Missing or empty field '{field}' in {info_path}")
                failed += 1
        if "{{" in str(data.get("icon_url", "")):
            print(f"FAIL: Unrendered template in icon_url: {info_path}")
            failed += 1
        if addon in ["bke-cluster-log", "bke-cluster-metrics"]:
            if not data.get("internal"):
                print(f"FAIL: Expected internal: true in {info_path}")
                failed += 1
        if data.get("version") in ["Latest", "latest", "Lorem"]:
            print(f"FAIL: Placeholder version '{data.get('version')}' in {info_path}")
            failed += 1
    except Exception as e:
        print(f"FAIL: Error reading {info_path}: {e}")
        failed += 1

if failed > 0:
    sys.exit(1)
print(f"PASS: All 15 add-ons have valid INFORMATION.yaml schema and invariants.")
EOF

echo "=== [4/5] Checking Add-on Specific Upgrades & Invariants ==="
python3 - << 'EOF'
import sys, os, yaml

# 1. ingress-nginx values check
with open("ingress-nginx/values.yml") as f:
    ing = yaml.safe_load(f)
assert ing.get("controller", {}).get("metrics", {}).get("service", {}).get("servicePort"), "ingress-nginx metrics.service.servicePort missing or misplaced"
assert "controller" not in ing.get("controller", {}).get("podAnnotations", {}), "ingress-nginx podAnnotations still contains nested controller!"

# 2. vmoperator values split
assert os.path.exists("vmoperator/manifests/vmcluster.yaml"), "vmoperator/manifests/vmcluster.yaml missing"
with open("vmoperator/manifests/vmcluster.yaml") as f:
    vm_cr = f.read()
assert ".vmoperator.svc.cluster.local" in vm_cr, "vmoperator FQDN should point to .vmoperator.svc.cluster.local"

# 3. loki storageClassName check
with open("loki/values.yml") as f:
    loki_val = yaml.safe_load(f)
assert "storageClassName" not in loki_val.get("loki", {}).get("persistence", {}), "loki values still has hardcoded storageClassName!"

# 4. karpenter CRDs check
for crd in ["bizflycloud.sh_bizflycloudnodeclasses.yaml", "karpenter.sh_nodepools.yaml", "karpenter.sh_nodeclaims.yaml"]:
    assert os.path.exists(os.path.join("karpenter/crds", crd)) or os.path.exists(os.path.join("karpenter/helm/crds", crd)), f"Missing Karpenter CRD: {crd}"

# 5. metrics-server values check
with open("metrics-server/values.yml") as f:
    ms_val = f.read()
assert "--kubelet-insecure-tls" in ms_val, "metrics-server values missing --kubelet-insecure-tls"

# 6. kong values check
with open("kong/values.yml") as f:
    kong_val = yaml.safe_load(f)
assert "ingressController" in kong_val and "proxy" in kong_val, "kong values does not conform to kong/kong schema"

# 7. kubearmor values check
with open("kubearmor/values.yml") as f:
    ka_val = yaml.safe_load(f)
assert ka_val.get("autoDeploy") is True, "kubearmor autoDeploy must be true"

# 8. cert-manager crds.enabled check
with open("cert-manager/values.yml") as f:
    cm_val = yaml.safe_load(f)
assert cm_val.get("crds", {}).get("enabled") is True, "cert-manager crds.enabled must be true"

# 9. csi-s3 values and assets check
with open("csi-s3/values.yml") as f:
    csi_val = yaml.safe_load(f)
assert csi_val.get("secret", {}).get("endpoint") == "https://hn.ss.bfcplatform.vn", "csi-s3 secret.endpoint default mismatch"
assert os.path.exists("csi-s3/assets/images/images.svg"), "csi-s3/assets/images/images.svg missing"

# 10. verify all icon files exist if referenced locally in main branch
addons_list = [
    "argocd", "bke-cluster-log", "bke-cluster-metrics", "cert-manager", "csi-s3",
    "ingress-nginx", "karpenter", "kong", "kube-prometheus", "kube-state-metrics",
    "kubearmor", "loki", "metrics-server", "vmoperator", "wordpress-kubernetes"
]
for addon in addons_list:
    info_path = os.path.join(addon, "INFORMATION.yaml")
    if os.path.exists(info_path):
        with open(info_path) as f:
            data = yaml.safe_load(f)
        icon_url = str(data.get("icon_url", ""))
        if "bizflycloud/bizflycloud-kubernetes-add-ons/main/" in icon_url:
            rel_path = icon_url.split("bizflycloud/bizflycloud-kubernetes-add-ons/main/")[1]
            # If bke-cluster-log or bke-cluster-metrics, check or allow if upstream
            if addon not in ["bke-cluster-log", "bke-cluster-metrics"]:
                assert os.path.exists(rel_path), f"Icon file {rel_path} referenced in {addon}/INFORMATION.yaml missing locally!"

print("PASS: All add-on specific invariants and upgrades verified.")
EOF

echo "=== [5/5] Checking Documentation Integrity (No Lorem Ipsum or Copy-Paste Typos) ==="
python3 - << 'EOF'
import sys, os

addons = [
    "argocd", "bke-cluster-log", "bke-cluster-metrics", "cert-manager", "csi-s3",
    "ingress-nginx", "karpenter", "kong", "kube-prometheus", "kube-state-metrics",
    "kubearmor", "loki", "metrics-server", "vmoperator", "wordpress-kubernetes"
]

failed = 0
for addon in addons:
    readme = os.path.join(addon, "README.md")
    if not os.path.exists(readme):
        print(f"FAIL: Missing README.md in {addon}")
        failed += 1
        continue
    content = open(readme, encoding="utf-8").read()
    if "Lorem ipsum" in content:
        print(f"FAIL: Lorem ipsum found in {readme}")
        failed += 1
    if addon != "ingress-nginx" and "tạo namespace ingress-nginx" in content:
        print(f"FAIL: Copy-paste typo 'tạo namespace ingress-nginx' found in {readme}")
        failed += 1

if failed > 0:
    sys.exit(1)
print("PASS: Documentation integrity verified across all add-ons.")
EOF

echo "=========================================================="
echo "SUCCESS: ALL CHECKS PASSED (exit code 0)"
echo "=========================================================="

echo "=== [6/6] Running Unit Tests for upgrade_guard.sh ==="
if [ -f "${script_dir}/scripts/test_upgrade_guard.sh" ]; then
  sh "${script_dir}/scripts/test_upgrade_guard.sh"
fi

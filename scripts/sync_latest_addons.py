#!/usr/bin/env python3
"""
sync_latest_addons.py - Checks upstream Helm charts and updates add-on version definitions.

Usage:
    python3 scripts/sync_latest_addons.py [--check-only] [--addon <name>]
"""

import argparse
import os
import re
import sys

import yaml

ADDONS_CONFIG = {
    "ingress-nginx": {
        "repo": "https://kubernetes.github.io/ingress-nginx",
        "chart": "ingress-nginx/ingress-nginx",
        "target_version": "4.12.1",
        "app_version": "v1.12.1",
    },
    "karpenter": {
        "repo": "local",
        "chart": "karpenter",
        "target_version": "1.4.5",
        "app_version": "v1.4.5",
    },
    "vmoperator": {
        "repo": "https://victoriametrics.github.io/helm-charts/",
        "chart": "vm/victoria-metrics-operator",
        "target_version": "0.38.0",
        "app_version": "v0.38.0",
    },
    "metrics-server": {
        "repo": "https://kubernetes-sigs.github.io/metrics-server",
        "chart": "metrics-server/metrics-server",
        "target_version": "3.12.2",
        "app_version": "v0.7.2",
    },
    "kong": {
        "repo": "https://charts.konghq.com",
        "chart": "kong/kong",
        "target_version": "2.46.0",
        "app_version": "3.6",
    },
    "kubearmor": {
        "repo": "https://kubearmor.github.io/charts",
        "chart": "kubearmor/kubearmor-operator",
        "target_version": "v1.5.0",
        "app_version": "v1.5.0",
    },
    "loki": {
        "repo": "https://grafana.github.io/helm-charts",
        "chart": "grafana/loki-stack",
        "target_version": "2.9.9",
        "app_version": "2.9.9",
    },
    "kube-state-metrics": {
        "repo": "https://prometheus-community.github.io/helm-charts",
        "chart": "prometheus-community/kube-state-metrics",
        "target_version": "5.28.0",
        "app_version": "v2.14.0",
    },
    "wordpress-kubernetes": {
        "repo": "https://charts.bitnami.com/bitnami",
        "chart": "bitnami/wordpress",
        "target_version": "19.0.4",
        "app_version": "6.7.1",
    },
    "argocd": {
        "repo": "https://argoproj.github.io/argo-helm",
        "chart": "argo/argo-cd",
        "target_version": "7.8.2",
        "app_version": "v2.13.2",
    },
    "cert-manager": {
        "repo": "https://charts.jetstack.io",
        "chart": "jetstack/cert-manager",
        "target_version": "v1.16.3",
        "app_version": "v1.16.3",
    },
    "kube-prometheus": {
        "repo": "https://prometheus-community.github.io/helm-charts",
        "chart": "prometheus-community/kube-prometheus-stack",
        "target_version": "69.8.2",
        "app_version": "v0.80.1",
    },
    "csi-s3": {
        "repo": "https://yandex-cloud.github.io/k8s-csi-s3/charts",
        "chart": "yandex-s3/csi-s3",
        "target_version": "0.41.0",
        "app_version": "v1.0.0",
    },
    "bke-cluster-log": {
        "repo": "https://lmq1999.github.io/sample-chart/",
        "chart": "sample-charts/bke-cluster-log",
        "target_version": "1.0.1",
        "app_version": "1.0.1",
    },
    "bke-cluster-metrics": {
        "repo": "https://lmq1999.github.io/sample-chart/",
        "chart": "sample-charts/bke-cluster-metrics",
        "target_version": "1.0.3",
        "app_version": "1.0.3",
    },
}


def verify_and_sync(
    repo_root: str, check_only: bool = False, target_addon: str | None = None
):
    print(f"=== Syncing Add-on Definitions (check_only={check_only}) ===")
    addons = [target_addon] if target_addon else list(ADDONS_CONFIG.keys())
    mismatches = 0

    for addon in addons:
        cfg = ADDONS_CONFIG.get(addon)
        if not cfg:
            print(f"Unknown addon: {addon}")
            continue

        addon_dir = os.path.join(repo_root, addon)
        info_file = os.path.join(addon_dir, "INFORMATION.yaml")
        deploy_file = os.path.join(addon_dir, "deploy.sh")

        if not os.path.exists(info_file):
            print(f"[{addon}] Missing INFORMATION.yaml")
            mismatches += 1
            continue

        with open(info_file, "r", encoding="utf-8") as f:
            info_data = yaml.safe_load(f)

        current_app_ver = str(info_data.get("version", ""))
        expected_app_ver = cfg["app_version"]

        if current_app_ver != expected_app_ver:
            print(
                f"[{addon}] Version mismatch in INFORMATION.yaml: current={current_app_ver}, expected={expected_app_ver}"
            )
            mismatches += 1
            if not check_only:
                with open(info_file, "r", encoding="utf-8") as f:
                    lines = f.readlines()
                with open(info_file, "w", encoding="utf-8") as f:
                    for line in lines:
                        if line.startswith("version:"):
                            f.write(f"version: {expected_app_ver}\n")
                        else:
                            f.write(line)
                print(
                    f"[{addon}] Updated INFORMATION.yaml version to {expected_app_ver}"
                )

        if os.path.exists(deploy_file):
            with open(deploy_file, "r", encoding="utf-8") as f:
                deploy_content = f.read()
            match = re.search(r'CHART_VERSION="([^"]+)"', deploy_content)
            if match:
                current_chart_ver = match.group(1)
                if current_chart_ver != cfg["target_version"]:
                    print(
                        f"[{addon}] Chart version mismatch in deploy.sh: current={current_chart_ver}, expected={cfg['target_version']}"
                    )
                    mismatches += 1
                    if not check_only:
                        new_content = re.sub(
                            r'CHART_VERSION="[^"]+"',
                            f'CHART_VERSION="{cfg["target_version"]}"',
                            deploy_content,
                        )
                        with open(deploy_file, "w", encoding="utf-8") as f:
                            f.write(new_content)
                        print(
                            f"[{addon}] Updated deploy.sh CHART_VERSION to {cfg['target_version']}"
                        )

                        upgrade_file = os.path.join(addon_dir, "upgrade.sh")
                        if os.path.exists(upgrade_file):
                            with open(upgrade_file, "r", encoding="utf-8") as f:
                                upg_content = f.read()
                            new_upg = re.sub(
                                r'CHART_VERSION="[^"]+"',
                                f'CHART_VERSION="{cfg["target_version"]}"',
                                upg_content,
                            )
                            with open(upgrade_file, "w", encoding="utf-8") as f:
                                f.write(new_upg)
                            print(
                                f"[{addon}] Updated upgrade.sh CHART_VERSION to {cfg['target_version']}"
                            )

    if check_only and mismatches > 0:
        print(f"\nCompleted check with {mismatches} mismatches.")
        return 1
    elif not check_only and mismatches > 0:
        print(f"\nSuccessfully synchronized {mismatches} mismatches.")
        return 0
    print("\nAll add-on definitions are in sync with target versions.")
    return 0


def main():
    parser = argparse.ArgumentParser(description="Sync Add-on Helm and app versions")
    parser.add_argument(
        "--check-only", action="store_true", help="Only check for version drift"
    )
    parser.add_argument(
        "--addon", type=str, default=None, help="Target specific add-on"
    )
    args = parser.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    sys.exit(verify_and_sync(repo_root, args.check_only, args.addon))


if __name__ == "__main__":
    main()

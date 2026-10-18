# BizFly Cloud Kubernetes Add-ons

Kho lưu trữ chính thức các tiện ích mở rộng (Add-ons) cho dịch vụ BizFly Kubernetes Engine (BKE).

## Danh Sách Add-ons Hỗ Trợ (15 Add-ons)

| Add-on | Loại / Catalog | Phiên Bản | Chart Nguồn |
| :--- | :--- | :--- | :--- |
| `ingress-nginx` | Network | v1.12.1 (Chart 4.12.1) | `ingress-nginx/ingress-nginx` |
| `karpenter` | Autoscaling | v1.2.2-beta.1 | In-cluster Provider Chart |
| `vmoperator` | Monitoring | v0.38.0 | `vm/victoria-metrics-operator` |
| `metrics-server` | Monitoring | v0.7.2 (Chart 3.12.2) | `metrics-server/metrics-server` |
| `kong` | Network | 3.6 (Chart 2.46.0) | `kong/kong` |
| `kubearmor` | Security | v1.5.0 | `kubearmor/kubearmor-operator` |
| `loki` | Logging | 2.9.9 | `grafana/loki-stack` |
| `kube-state-metrics` | Monitoring | v2.14.0 (Chart 5.28.0) | `prometheus-community/kube-state-metrics` |
| `wordpress-kubernetes` | Blogs and Forums | 6.7.1 (Chart 19.0.4) | `bitnami/wordpress` |
| `argocd` | Developer | v2.13.2 (Chart 7.8.2) | `argo/argo-cd` |
| `cert-manager` | Network | v1.16.3 | `jetstack/cert-manager` |
| `kube-prometheus` | Monitoring | v0.80.1 (Chart 69.8.2) | `prometheus-community/kube-prometheus-stack` |
| `csi-s3` | Storage | v1.0.0 (Chart 0.41.0) | `yandex-s3/csi-s3` |
| `bke-cluster-log` | BKE Internal | 1.0.1 | `sample-charts/bke-cluster-log` |
| `bke-cluster-metrics` | BKE Internal | 1.0.3 | `sample-charts/bke-cluster-metrics` |

## Tiêu Chuẩn Shell Script

- Mọi script (`deploy.sh`, `upgrade.sh`, `uninstall.sh`, `stack-generate.sh`) tuân thủ nghiêm ngặt chuẩn POSIX `/bin/sh`.
- Xác định đường dẫn độc lập qua `script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)`.
- Cấu hình values luôn nạp cục bộ từ `${script_dir}/values.yml`.
- `upgrade.sh` thực thi nâng cấp in-place atomic và hỗ trợ truyền thêm tham số với `"$@"`.
- `uninstall.sh` đảm bảo tính lũy quyền (idempotency) với `--ignore-not-found=true`.

## Kiểm Tra Tính Hợp Chuẩn

```bash
./validate-addons.sh
```

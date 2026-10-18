# Giới thiệu về Loki

Loki là một giải pháp quản lý logs mã nguồn mở được phát triển bởi Grafana Labs. Khác với các hệ thống logs truyền thống lập chỉ mục toàn bộ văn bản, Loki chỉ đánh chỉ mục metadata (labels), giúp giảm thiểu tối đa chi phí lưu trữ và tài nguyên vận hành.

# Tác dụng của Loki

- Thu thập logs tập trung từ các ứng dụng và hệ thống trong cụm BKE.
- Tích hợp trực tiếp với Grafana và Prometheus query syntax (LogQL).
- Tiết kiệm dung lượng lưu trữ nhờ cơ chế chunk-compression hiệu quả.

# Hướng dẫn cài đặt Loki

## Bước 1: Cài đặt Loki bằng Helm

Sử dụng Helm để cài đặt Loki stack:

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install loki grafana/loki-stack \
  --namespace loki \
  --create-namespace \
  --version 2.9.9
```

## Bước 2: Kiểm tra trạng thái của LOKI

```bash
kubectl get pods -n loki
kubectl get pvc -n loki
```

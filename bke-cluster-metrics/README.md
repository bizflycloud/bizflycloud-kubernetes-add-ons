# BKE Cluster Metrics

BKE Cluster Metrics là tiện ích nội bộ (Internal Add-on) của BizFly Kubernetes Engine (BKE) phục vụ việc thu thập các chỉ số tài nguyên phần cứng (CPU, Memory, Disk I/O, Network Traffic) từ các node của cụm BKE.

## Tính Năng Chính

- Tự động triển khai DaemonSet trên mọi Kubernetes Worker Node thuộc cụm.
- Xuất số liệu chuẩn định dạng Prometheus metrics.
- Cung cấp telemetry dữ liệu cho `bke-node-alert` và hệ thống giám sát sức khỏe cụm tự động.

## Cài Đặt

Tiện ích này thường được khởi tạo tự động bởi `bke-orchestrator`. Bạn cũng có thể nâng cấp thủ công:

```bash
helm repo add sample-charts https://lmq1999.github.io/sample-chart/
helm repo update
helm upgrade --install bke-cluster-metrics sample-charts/bke-cluster-metrics \
  --namespace bke-cluster-metrics \
  --create-namespace \
  --version 1.0.3
```

## Kiểm Tra Hoạt Động

```bash
kubectl get pods -n bke-cluster-metrics
```

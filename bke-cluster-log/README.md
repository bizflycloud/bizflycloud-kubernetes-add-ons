# BKE Cluster Log

BKE Cluster Log là tiện ích nội bộ (Internal Add-on) của BizFly Kubernetes Engine (BKE) phục vụ việc thu thập, xử lý và chuyển tiếp logs từ các thành phần hệ thống và workload của khách hàng về hạ tầng giám sát tập trung.

## Tính Năng Chính

- Tự động phát hiện và thu thập stdout/stderr container logs trên toàn bộ các node thuộc cụm BKE.
- Bổ sung siêu dữ liệu (Kubernetes metadata: namespace, pod, container, labels).
- Chuyển tiếp tin cậy về giải pháp logging tập trung của BizFly Cloud.

## Cài Đặt

Tiện ích này thường được khởi tạo tự động bởi `bke-orchestrator`. Bạn cũng có thể nâng cấp thủ công:

```bash
helm repo add sample-charts https://lmq1999.github.io/sample-chart/
helm repo update
helm upgrade --install bke-cluster-log sample-charts/bke-cluster-log \
  --namespace bke-cluster-log \
  --create-namespace \
  --version 1.0.1
```

## Kiểm Tra Hoạt Động

```bash
kubectl get pods -n bke-cluster-log
```

# Giới thiệu về Victoria Metrics Operator

Victoria Metrics Operator là một dự án mã nguồn mở được phát triển để triển khai và quản lý Victoria Metrics trên Kubernetes. Victoria Metrics là một hệ thống lưu trữ và truy vấn metrics mã nguồn mở, được thiết kế để xử lý và truy vấn một lượng lớn dữ liệu metrics với hiệu suất cao.

# Tác dụng của Victoria Metrics Operator

- Triển khai và quản lý Victoria Metrics: Tự động hóa việc triển khai và quản lý Victoria Metrics trên môi trường Kubernetes.
- Tối ưu hóa việc triển khai và vận hành: Cung cấp các tùy chọn cấu hình linh hoạt cho Victoria Metrics trên Kubernetes.
- Tích hợp với Kubernetes: Quản lý Victoria Metrics dễ dàng thông qua Kubernetes CRD (`VMCluster`, `VMAgent`).

# Hướng dẫn cài đặt Victoria Metrics Operator

## Bước 1: Cài đặt Victoria Metrics Operator

Sử dụng Helm để cài đặt:

```bash
helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update
helm upgrade --install vmoperator vm/victoria-metrics-operator \
  --namespace vmoperator \
  --create-namespace \
  --version 0.38.0
```

## Bước 2: Khởi tạo cụm VictoriaMetrics Cluster

Sau khi cài đặt operator, triển khai cụm VictoriaMetrics:

```bash
kubectl apply -n vmoperator -f manifests/vmcluster.yaml
```

## Bước 3: Kiểm tra trạng thái

```bash
kubectl get pods -n vmoperator
kubectl get vmcluster,vmagent -n vmoperator
```

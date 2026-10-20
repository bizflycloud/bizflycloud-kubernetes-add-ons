# Giới thiệu về Kubernetes Metrics Server

Kubernetes Metrics Server là một thành phần quan trọng trong hệ thống Kubernetes giúp thu thập và lưu trữ các thông tin về tài nguyên của các container và các pod trong cluster. Metrics Server cung cấp dữ liệu về CPU và memory usage của các pod, giúp người quản trị hệ thống có cái nhìn tổng quan về hiệu suất hoạt động của các ứng dụng chạy trên Kubernetes.

# Tác dụng của Kubernetes Metrics Server

- Thu thập và lưu trữ thông tin về tài nguyên sử dụng của các container và pod.
- Cung cấp dữ liệu về CPU và memory usage để theo dõi hiệu suất hoạt động của ứng dụng.
- Hỗ trợ trong việc điều chỉnh tài nguyên cho Horizontal Pod Autoscaler (HPA).

# Hướng dẫn cài đặt Kubernetes Metrics Server

## Bước 1: Cài đặt Metrics Server bằng Helm

```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace metrics-server \
  --create-namespace \
  --version 3.12.2
```

## Bước 2: Kiểm tra cài đặt metrics server

Kiểm tra trạng thái của Metrics Server bằng lệnh:

```bash
kubectl get deployment metrics-server -n metrics-server
```

## Bước 3: Kiểm tra Metrics Server hoạt động

```bash
kubectl top nodes
kubectl top pods -A
```

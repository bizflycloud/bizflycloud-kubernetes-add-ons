# Giới thiệu về Loki

Loki là một dịch vụ giám sát logs mã nguồn mở, được phát triển bởi cộng đồng Prometheus. Nó được thiết kế để làm giảm bớt chi phí lưu trữ logs bằng cách lưu trữ logs ở dạng nén và chỉ lưu trữ những phần quan trọng của logs.

# Tác dụng của Loki

- Thu thập logs: Loki giúp thu thập và lưu trữ logs từ các ứng dụng và hệ thống trong môi trường Kubernetes.
- Truy vấn logs: Loki cung cấp khả năng truy vấn logs một cách linh hoạt và hiệu quả, giúp người dùng dễ dàng tìm kiếm và xem logs của các ứng dụng và hệ thống.
- Giảm chi phí lưu trữ: Nhờ cơ chế nén và chỉ lưu trữ những phần quan trọng của logs, Loki giúp giảm chi phí lưu trữ so với các giải pháp giám sát logs truyền thống.

# Hướng dẫn cài đặt Loki

## Bước 1: Tạo namespace cho Loki

Sử dụng lệnh sau để tạo namespace loki:

```bash
kubectl create namespace loki
```
## Bước 2: Cài đặt Loki

Sử dụng Helm để cài đặt Loki

```bash
helm repo add loki https://grafana.github.io/loki/charts
helm repo update
helm install loki loki/loki --namespace loki
```

## Bước 3: Kiểm tra trạng thái của LOKI

Để kiểm tra trạng thái của LOKI, sử dụng lệnh sau:

```bash
kubectl get pods -n loki
kubectl get services -n loki
```

## Bước 4: Sử dụng LOKI

Cấu hình và sử dụng Loki:

- Sau khi cài đặt, bạn cần cấu hình Loki để thu thập và lưu trữ logs từ các ứng dụng và hệ thống trong môi trường Kubernetes của bạn.

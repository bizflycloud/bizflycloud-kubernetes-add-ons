# Giới thiệu về Kubernetes Metrics Server

Kubernetes Metrics Server là một thành phần quan trọng trong hệ thống Kubernetes giúp thu thập và lưu trữ các thông tin về tài nguyên của các container và các pod trong cluster. Metrics Server cung cấp dữ liệu về CPU và memory usage của các pod, giúp người quản trị hệ thống có cái nhìn tổng quan về hiệu suất hoạt động của các ứng dụng chạy trên Kubernetes.

# Tác dụng của Kubernetes Metrics Server

- Thu thập và lưu trữ thông tin về tài nguyên sử dụng của các container và pod.
- Cung cấp dữ liệu về CPU và memory usage để theo dõi hiệu suất hoạt động của ứng dụng.
- Hỗ trợ trong việc điều chỉnh tài nguyên cho các pod để tối ưu hiệu suất và sử dụng tài nguyên hiệu quả.

# Hướng dẫn cài đặt Kubernetes Metrics Server

## Bước 1: Tạo namespace cho Kubernetes Metrics Server

Sử dụng lệnh sau để tạo namespace metrics-server:

```bash
kubectl create ns metrics-server
```

## Bước 2: Cài đặt Metrics Server


Sử dụng Helm để cài đặt Kubernetes Metrics Server:

```bash
helm install metrics-server metrics-server/metrics-server --namespace metrics-server
```

## Bước 3: Kiểm tra cài đặt metrics server

Kiểm tra trạng thái của Metrics Server bằng lệnh:

```bash
kubectl get deployment metrics-server -n metrics-server
```

## Bước 4: Kiểm tra Metrics Server hoạt động

Để kiểm tra Metrics Server hoạt động đúng, sử dụng lệnh sau:

```bash
kubectl top nodes -n metrics-server
kubectl top pods -n metrics-server
```

Nếu bạn nhận được dữ liệu về tài nguyên sử dụng của nodes và pods, có nghĩa là Metrics Server đã được cài đặt và hoạt động thành công.

Đó là hướng dẫn cài đặt và sử dụng Kubernetes Metrics Server. Nếu bạn gặp bất kỳ vấn đề nào trong quá trình cài đặt, hãy tham khảo tài liệu chính thức của Kubernetes hoặc cộng đồng Kubernetes để được hỗ trợ.
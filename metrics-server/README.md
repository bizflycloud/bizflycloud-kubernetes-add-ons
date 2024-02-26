# Giới thiệu về Kubernetes Metrics Server

Kubernetes Metrics Server là một thành phần quan trọng trong hệ thống Kubernetes giúp thu thập và lưu trữ các thông tin về tài nguyên của các container và các pod trong cluster. Metrics Server cung cấp dữ liệu về CPU và memory usage của các pod, giúp người quản trị hệ thống có cái nhìn tổng quan về hiệu suất hoạt động của các ứng dụng chạy trên Kubernetes.

# Tác dụng của Kubernetes Metrics Server

- Thu thập và lưu trữ thông tin về tài nguyên sử dụng của các container và pod.
- Cung cấp dữ liệu về CPU và memory usage để theo dõi hiệu suất hoạt động của ứng dụng.
- Hỗ trợ trong việc điều chỉnh tài nguyên cho các pod để tối ưu hiệu suất và sử dụng tài nguyên hiệu quả.

# Hướng dẫn cài đặt Kubernetes Metrics Server

## Bước 1: Tải Metrics Server YAML file

Tải Metrics Server YAML file từ GitHub repository:

```bash
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Bước 2: Sửa đổi file YAML

Mở file YAML và tìm đến phần args trong container metrics-server để thêm các cấu hình sau:

```yaml
args:
  - --kubelet-insecure-tls
  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
```

## Bước 3: Cài đặt Metrics Server

Sử dụng lệnh kubectl để cài đặt Metrics Server:

```bash
kubectl apply -f components.yaml
```

Kiểm tra trạng thái của Metrics Server bằng lệnh:

```bash
kubectl get deployment metrics-server -n kube-system
```

## Bước 4: Kiểm tra Metrics Server hoạt động

Để kiểm tra Metrics Server hoạt động đúng, sử dụng lệnh sau:

```bash
kubectl top nodes
kubectl top pods
```

Nếu bạn nhận được dữ liệu về tài nguyên sử dụng của nodes và pods, có nghĩa là Metrics Server đã được cài đặt và hoạt động thành công.

Đó là hướng dẫn cài đặt và sử dụng Kubernetes Metrics Server. Nếu bạn gặp bất kỳ vấn đề nào trong quá trình cài đặt, hãy tham khảo tài liệu chính thức của Kubernetes hoặc cộng đồng Kubernetes để được hỗ trợ.
# Giới thiệu về WordPress trên Kubernetes

WordPress là một hệ thống quản lý nội dung (CMS) mã nguồn mở phổ biến nhất thế giới. Kết hợp cùng Kubernetes, WordPress mang lại khả năng tự động phục hồi, mở rộng linh hoạt theo lưu lượng truy cập và độ tin cậy cao trên nền tảng BizFly Kubernetes Engine (BKE).

# Tác dụng của WordPress trên Kubernetes

- Triển khai nhanh chóng toàn bộ stack WordPress cùng cơ sở dữ liệu MariaDB.
- Khả năng mở rộng tự động theo tải truy cập.
- Độ tin cậy cao, tự động phục hồi khi Pod gặp lỗi và tự động quản lý volume dữ liệu.

# Hướng dẫn cài đặt WordPress Kubernetes

## Bước 1: Cài đặt WordPress bằng Helm

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install wordpress-kubernetes bitnami/wordpress \
  --namespace wordpress-kubernetes \
  --create-namespace \
  --version 19.0.4
```

## Bước 2: Kiểm tra trạng thái của WordPress

```bash
kubectl get pods -n wordpress-kubernetes
kubectl get svc -n wordpress-kubernetes
```

## Bước 3: Truy cập WordPress

Sau khi cài đặt thành công, truy cập vào WordPress thông qua địa chỉ IP External LoadBalancer được cấp phát bởi BizFly Cloud.

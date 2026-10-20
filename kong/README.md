# Giới thiệu về Kong Ingress

Kong Ingress là một bộ điều khiển Ingress Controller mã nguồn mở được xây dựng trên nền tảng của Kong Gateway. Nó cung cấp một cách tiếp cận linh hoạt và mạnh mẽ để quản lý lưu lượng và bảo mật cho các ứng dụng chạy trên môi trường Kubernetes.

# Tác dụng của Kong Ingress

- Điều khiển lưu lượng (Traffic Control): Quản lý và điều khiển lưu lượng truy cập vào các ứng dụng Kubernetes thông qua quy tắc routing, phân phối tải, và kiểm soát truy cập.
- Bảo mật (Security): Tính năng bảo mật như xác thực, ủy quyền, và mã hóa để bảo vệ các ứng dụng trên Kubernetes.
- Quản lý API (API Management): Tích hợp sẵn với Kong Gateway, cho phép quản lý plugins, giới hạn lưu lượng (rate limiting), và phân phối khóa API.

# Cách cài đặt Kong Ingress sử dụng Helm

## Bước 1: Cài đặt Kong Ingress

Sử dụng Helm để cài đặt Kong:

```bash
helm repo add kong https://charts.konghq.com
helm repo update
helm upgrade --install kong kong/kong \
  --namespace kong \
  --create-namespace \
  --version 2.46.0
```

## Bước 2: Kiểm tra trạng thái của Kong Ingress

```bash
kubectl get pods -n kong
kubectl get services -n kong
```

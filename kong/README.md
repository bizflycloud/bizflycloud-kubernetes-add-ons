# Giới thiệu về Kong Ingress

Kong Ingress là một bộ điều khiển Ingress Controller mã nguồn mở được xây dựng trên nền tảng của Kong Gateway. Nó cung cấp một cách tiếp cận linh hoạt và mạnh mẽ để quản lý lưu lượng và bảo mật cho các ứng dụng chạy trên môi trường Kubernetes.

# Tác dụng của Kong Ingress

- Điều khiển lưu lượng (Traffic Control): Kong Ingress cho phép quản lý và điều khiển lưu lượng truy cập vào các ứng dụng Kubernetes thông qua các cơ chế như quy tắc routing, phân phối tải, và kiểm soát truy cập.
- Bảo mật (Security): Nó cung cấp các tính năng bảo mật như xác thực, ủy quyền, và mã hóa để bảo vệ các ứng dụng trên Kubernetes.
- Quản lý API (API Management): Kong Ingress tích hợp sẵn với Kong Gateway, cho phép quản lý và kiểm soát các API thông qua các tính năng như quản lý API, giới hạn lưu lượng, và phân phối khóa API.

# Cách cài đặt Kong Ingress sử dụng Helm

## Bước 1: Tạo namespace cho kong

Sử dụng lệnh sau để tạo namespace kong:

```bash
kubectl create namespace kong
```

## Bước 2: Cài đặt Kong Ingress

Sử dụng Helm để cài đặt Kong:

```bash
helm repo add kong https://charts.konghq.com
helm repo update

helm install kong kong/kong --namespace kong
```

## Bước 3: Kiểm tra trạng thái của Kong Ingress

Chờ đợi một vài phút để cài đặt hoàn tất và kiểm tra trạng thái của các pods và services của Kong Ingress Controller.

```bash
kubectl get pods -n kong
kubectl get services -n kong
```

## Bước 4: Sử dụng Kong Ingress

Cấu hình và sử dụng Kong Ingress:

- Bạn có thể cấu hình các đối tượng Ingress trong Kubernetes để sử dụng Kong Ingress Controller để quản lý lưu lượng và bảo mật cho các ứng dụng của bạn.

Thông qua các bước trên, bạn đã cài đặt và cấu hình Kong Ingress trên môi trường Kubernetes của mình, sẵn sàng để điều khiển lưu lượng và bảo mật cho các ứng dụng Kubernetes của bạn.
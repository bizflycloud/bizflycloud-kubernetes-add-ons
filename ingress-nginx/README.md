# Giới thiệu về NGINX Ingress Controller

NGINX Ingress Controller là một phần mềm mã nguồn mở được sử dụng để quản lý traffic và điều hướng requests đến các ứng dụng chạy trên Kubernetes cluster thông qua việc sử dụng NGINX web server. Ingress Controller giúp tạo ra các rules và configurations để quản lý việc điều hướng traffic từ bên ngoài vào các services trong cluster.

# Tác dụng của NGINX Ingress Controller

- Quản lý traffic và điều hướng requests đến các ứng dụng chạy trên Kubernetes cluster.
- Hỗ trợ cấu hình các rules và configurations cho việc điều hướng traffic theo yêu cầu.
- Cung cấp tính năng load balancing, SSL termination và caching cho ứng dụng.

# Hướng dẫn cài đặt NGINX Ingress Controller

## Bước 1: Cài đặt qua Add-on Script hoặc Helm

Sử dụng Helm để cài đặt NGINX Ingress Controller:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --version 4.12.1
```

## Bước 2: Kiểm tra trạng thái của NGINX Ingress Controller

Để kiểm tra trạng thái của NGINX Ingress Controller, sử dụng lệnh sau:

```bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

## Bước 3: Sử dụng NGINX Ingress Controller

Sau khi cài đặt thành công, bạn có thể tạo tài nguyên Ingress để định tuyến truy cập tới service của bạn:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: demo.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: demo-service
            port:
              number: 80
```

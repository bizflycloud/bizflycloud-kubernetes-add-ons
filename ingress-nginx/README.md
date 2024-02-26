# Giới thiệu về NGINX Ingress Controller

NGINX Ingress Controller là một phần mềm mã nguồn mở được sử dụng để quản lý traffic và điều hướng requests đến các ứng dụng chạy trên Kubernetes cluster thông qua việc sử dụng NGINX web server. Ingress Controller giúp tạo ra các rules và configurations để quản lý việc điều hướng traffic từ bên ngoài vào các services trong cluster.

# Tác dụng của NGINX Ingress Controller

- Quản lý traffic và điều hướng requests đến các ứng dụng chạy trên Kubernetes cluster.
- Hỗ trợ cấu hình các rules và configurations cho việc điều hướng traffic theo yêu cầu.
- Cung cấp tính năng load balancing, SSL termination và caching cho ứng dụng.

# Hướng dẫn cài đặt NGINX Ingress Controller

## Bước 1: Tạo namespace cho NGINX Ingress Controller

Sử dụng lệnh sau để tạo namespace nginx-ingress:

```bash
kubectl create namespace nginx-ingress
```


## Bước 2: Cài đặt NGINX Ingress Controller

Sử dụng Helm để cài đặt NGINX Ingress Controller:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace nginx-ingress
```

## Bước 3: Kiểm tra trạng thái của NGINX Ingress Controller

Để kiểm tra trạng thái của NGINX Ingress Controller, sử dụng lệnh sau:

```
kubectl get pods -n nginx-ingress
```

## Bước 4: Sử dụng NGINX Ingress Controller

Sau khi cài đặt thành công, bạn có thể bắt đầu sử dụng NGINX Ingress Controller để quản lý traffic và điều hướng requests trong Kubernetes cluster. Bạn có thể tạo các Ingress resources để cấu hình rules cho việc điều hướng traffic.

Đó là hướng dẫn cài đặt và sử dụng NGINX Ingress Controller. Nếu bạn cần thêm thông tin hoặc gặp vấn đề trong quá trình cài đặt, hãy tham khảo tài liệu chính thức của NGINX Ingress Controller hoặc cộng đồng Kubernetes để được hỗ trợ.
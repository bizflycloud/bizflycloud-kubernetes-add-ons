# Giới thiệu về cert-manager

cert-manager là một công cụ mã nguồn mở được sử dụng để quản lý và tự động hóa việc phát hành, cài đặt và cập nhật chứng chỉ SSL/TLS trên môi trường Kubernetes. cert-manager được tích hợp chặt chẽ với Let's Encrypt và các nhà cung cấp chứng chỉ SSL/TLS khác, giúp tự động hóa quy trình quản lý chứng chỉ SSL/TLS một cách dễ dàng và an toàn.
Đặc điểm chính của cert-manager:

- Tự động hóa: Tự động hóa quy trình phát hành, cài đặt và cập nhật chứng chỉ SSL/TLS trên môi trường Kubernetes.
- Tích hợp Let's Encrypt: Hỗ trợ tích hợp chặt chẽ với Let's Encrypt để tự động lấy và cài đặt chứng chỉ SSL/TLS miễn phí.
- Quản lý tài nguyên Kubernetes: Sử dụng các tài nguyên Kubernetes như CustomResourceDefinitions (CRDs) để quản lý các yêu cầu và chứng chỉ SSL/TLS.
- Hỗ trợ nhiều nhà cung cấp chứng chỉ: 
- Hỗ trợ nhiều nhà cung cấp chứng chỉ SSL/TLS khác nhau ngoài Let's Encrypt.

# Cách cài đặt cert-manager sử dụng Helm

## Bước 1: Tạo namespace cho Cert-manager

Sử dụng lệnh sau để tạo namespace cert-manager:

```bash
kubectl create namespace cert-manager
```

## Bước 2: Cài đặt NGINX Ingress Controller

Sử dụng Helm để cài đặt cert-manager:

```bash

helm repo add jetstack https://charts.jetstack.io
kubectl create namespace cert-manager
helm install cert-manager jetstack/cert-manager --namespace cert-manager --set installCRDs=true
```

## Bước 3: Kiểm tra trạng thái của Cert-manager

Chờ đợi một vài phút cho các tài nguyên của cert-manager được tạo trong namespace cert-manager.
Để kiểm tra trạng thái của Cert-manager sử dụng lệnh:

```bash
kubectl get pods --namespace cert-manager
```

## Bước 4: Sử dụng Cert-manager

Tạo một Issuer hoặc ClusterIssuer:

- Bạn có thể tạo một Issuer hoặc ClusterIssuer để cho phép cert-manager tương tác với nhà cung cấp chứng chỉ SSL/TLS như Let's Encrypt. Hãy tham khảo tài liệu của cert-manager để biết thêm chi tiết về cách cấu hình Issuer hoặc ClusterIssuer.

Tạo Certificate:

- Sau khi có Issuer hoặc ClusterIssuer, bạn có thể tạo một Certificate để yêu cầu cert-manager phát hành và quản lý chứng chỉ SSL/TLS.

Thông qua các bước trên, bạn đã cài đặt và cấu hình cert-manager trên môi trường Kubernetes của mình, và có thể bắt đầu sử dụng nó để tự động hóa quy trình quản lý chứng chỉ SSL/TLS.
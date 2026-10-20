# Giới thiệu về cert-manager

cert-manager là một công cụ mã nguồn mở được sử dụng để quản lý và tự động hóa việc phát hành, cài đặt và cập nhật chứng chỉ SSL/TLS trên môi trường Kubernetes. cert-manager được tích hợp chặt chẽ với Let's Encrypt và các nhà cung cấp chứng chỉ SSL/TLS khác, giúp tự động hóa quy trình quản lý chứng chỉ SSL/TLS một cách dễ dàng và an toàn.

# Đặc điểm chính của cert-manager

- Tự động hóa: Tự động hóa quy trình phát hành, cài đặt và cập nhật chứng chỉ SSL/TLS trên môi trường Kubernetes.
- Tích hợp Let's Encrypt: Hỗ trợ tích hợp ACME HTTP-01 / DNS-01 để tự động lấy và gia hạn chứng chỉ SSL/TLS miễn phí.
- Quản lý tài nguyên Kubernetes: Sử dụng các tài nguyên CustomResourceDefinitions (CRDs) như `Issuer`, `ClusterIssuer`, `Certificate`.

# Cách cài đặt cert-manager sử dụng Helm

## Bước 1: Cài đặt cert-manager

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.16.3 \
  --set crds.enabled=true
```

## Bước 2: Kiểm tra trạng thái của Cert-manager

```bash
kubectl get pods --namespace cert-manager
kubectl get crds | grep cert-manager
```

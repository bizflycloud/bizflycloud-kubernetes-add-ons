# Giới thiệu về ArgoCD

ArgoCD là một công cụ mã nguồn mở được sử dụng để triển khai và quản lý ứng dụng trên Kubernetes theo mô hình GitOps. GitOps là phương pháp quản lý hạ tầng và ứng dụng Kubernetes thông qua các bản khai báo trạng thái được phiên bản hóa trong kho lưu trữ Git.

# Đặc điểm chính của ArgoCD

- GitOps: Tự động đồng bộ hóa trạng thái ứng dụng trên Kubernetes với kho lưu trữ Git.
- Giao diện người dùng đồ họa (Web UI): Cung cấp giao diện trực quan theo dõi trạng thái triển khai, đồng bộ và chi tiết từng tài nguyên.
- Phê duyệt và tự động hóa: Hỗ trợ kiểm soát phiên bản, rollback tự động và phân quyền chi tiết (RBAC).

# Hướng dẫn cài đặt ArgoCD

## Bước 1: Cài đặt ArgoCD bằng Helm

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version 7.8.2
```

## Bước 2: Truy cập ArgoCD UI

Sau khi cài đặt thành công, bạn có thể truy cập giao diện người dùng web của ArgoCD bằng cách port-forward:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Truy cập vào địa chỉ <https://localhost:8080>.

## Bước 3: Lấy mật khẩu đăng nhập ban đầu

Tên người dùng mặc định là `admin`. Mật khẩu được tạo ngẫu nhiên trong secret:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

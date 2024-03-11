# Giới thiệ về ArgoCD

ArgoCD là một công cụ mã nguồn mở được sử dụng để triển khai và quản lý ứng dụng trên Kubernetes bằng cách sử dụng GitOps. GitOps là một phương pháp quản lý hạ tầng và ứng dụng Kubernetes bằng cách sử dụng các trạng thái được lưu trữ trong một kho lưu trữ Git. ArgoCD giúp tự động hóa việc triển khai, đồng bộ hóa và theo dõi các ứng dụng trên môi trường Kubernetes một cách linh hoạt và hiệu quả.

# Đặc điểm chính của ArgoCD

- GitOps: Sử dụng GitOps để quản lý trạng thái của các ứng dụng và hạ tầng Kubernetes.
- Giao diện người dùng đồ họa (UI): Cung cấp giao diện người dùng web để quản lý ứng dụng và xem trạng thái triển khai.
- Đồng bộ hóa liên tục: Theo dõi trạng thái hiện tại của các tài nguyên Kubernetes và đồng bộ hóa với trạng thái khai báo trong Git.
- Phê duyệt và tự động hóa triển khai: Hỗ trợ phê duyệt và tự động hóa quá trình triển khai dựa trên cập nhật trong kho lưu trữ Git.
- Quản lý nhiều môi trường: Hỗ trợ triển khai ứng dụng trên nhiều môi trường như production, staging, development, vv.

# Hướng dẫn cài đặt ArgoCD 

## Bước 1: Tạo namespace cho argoCD

Sử dụng lệnh sau để tạo namespace ingress-nginx:

```bash
kubectl create namespace argocd
```

## Bước 2: Cài đặt ArgoCD

Sử dụng Helm để cài đặt ArgoCD

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd --namespace argocd
```

## Bước 3: Truy cập ArgoCD UI

Sau khi cài đặt thành công, bạn có thể truy cập giao diện người dùng web của ArgoCD bằng cách sử dụng port-forwarding:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Sau đó, truy cập vào địa chỉ <https://localhost:8080> để sử dụng giao diện người dùng web của ArgoCD.

Đăng nhập vào ArgoCD UI:

Mặc định, tên người dùng là "admin" và mật khẩu được tạo ngẫu nhiên. Bạn có thể lấy mật khẩu bằng cách chạy lệnh sau:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```
## Bước 4: Sử dụng ArgoCD

Đăng nhập vào ArgoCD UI:

Mặc định, tên người dùng là "admin" và mật khẩu được tạo ngẫu nhiên. Bạn có thể lấy mật khẩu bằng cách chạy lệnh sau:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

Sau khi đăng nhập, bạn có thể bắt đầu triển khai ứng dụng trên Kubernetes bằng cách thêm các ứng dụng và định nghĩa triển khai vào kho lưu trữ Git và theo dõi trạng thái triển khai của chúng trong giao diện người dùng web của ArgoCD.
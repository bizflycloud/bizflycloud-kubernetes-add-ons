# Giới thiệu về KubeArmor

KubeArmor là một dự án bảo mật mã nguồn mở sử dụng eBPF và LSM (Linux Security Modules) như AppArmor/SELinux để bảo vệ hệ thống và các container chạy trên Kubernetes trong thời gian thực.

# Tác dụng của KubeArmor

- Bảo vệ dữ liệu và tiến trình: Ngăn chặn các hành vi tấn công, thực thi mã độc hoặc can thiệp trái phép vào hệ thống tập tin và mạng của Pod.
- Phát hiện và ngăn chặn mối đe dọa bảo mật theo thời gian thực (Zero-trust runtime enforcement).
- Giám sát và kiểm toán bảo mật (Security telemetry & audit logging).

# Hướng dẫn cài đặt KubeArmor

## Bước 1: Cài đặt KubeArmor Operator

Sử dụng Helm để cài đặt:

```bash
helm repo add kubearmor https://kubearmor.github.io/charts
helm repo update
helm upgrade --install kubearmor kubearmor/kubearmor-operator \
  --namespace kubearmor \
  --create-namespace \
  --version v1.5.0
```

## Bước 2: Kiểm tra trạng thái của KubeArmor

```bash
kubectl get pods -n kubearmor
kubectl get daemonset -n kubearmor
```

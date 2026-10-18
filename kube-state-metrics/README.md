# Giới thiệu về kube-state-metrics

kube-state-metrics là một dịch vụ mở rộng của Kubernetes giúp thu thập và xuất trạng thái của các tài nguyên trong một cụm Kubernetes. Nó lắng nghe Kubernetes API server và sinh ra các metrics về trạng thái của các đối tượng (Deployments, Pods, Services, PVCs, Nodes).

# Tác dụng của kube-state-metrics

- Thu thập thông tin trạng thái và số liệu về các tài nguyên Kubernetes.
- Cung cấp dữ liệu chuẩn Prometheus format phục vụ cho việc theo dõi, cảnh báo và lập biểu đồ Grafana.
- Hỗ trợ đánh giá dung lượng và tối ưu hóa hoạt động của cụm.

# Cách cài đặt kube-state-metrics sử dụng Helm

## Bước 1: Cài đặt kube-state-metrics

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-state-metrics prometheus-community/kube-state-metrics \
  --namespace kube-state-metrics \
  --create-namespace \
  --version 5.28.0
```

## Bước 2: Kiểm tra trạng thái của kube-state-metrics

```bash
kubectl get pods -n kube-state-metrics
kubectl get services -n kube-state-metrics
```

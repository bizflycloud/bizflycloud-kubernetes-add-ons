# Giới thiệu về Kube-Prometheus Stack

Kube-Prometheus Stack là bộ giải pháp giám sát hoàn chỉnh cho Kubernetes, tích hợp Prometheus, Grafana, Alertmanager, Node Exporter và Kube-State-Metrics.

# Tác dụng của Prometheus Stack

- Thu thập metrics toàn diện từ tầng Node, Pod, Control Plane đến tầng ứng dụng.
- Cung cấp sẵn hệ thống Dashboard Grafana phong phú để trực quan hóa dữ liệu.
- Quản lý luật cảnh báo (Alerting Rules) thông qua Prometheus Operator CRDs (`PrometheusRule`, `ServiceMonitor`, `PodMonitor`).

# Hướng dẫn cài đặt Kube-Prometheus Stack

## Bước 1: Cài đặt Kube-Prometheus Stack bằng Helm

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace kube-prometheus \
  --create-namespace \
  --version 69.8.2
```

## Bước 2: Kiểm tra trạng thái của Prometheus Stack

```bash
kubectl get pods -n kube-prometheus
kubectl get svc -n kube-prometheus
```

## Bước 3: Truy cập Grafana Dashboard

```bash
kubectl port-forward svc/kube-prometheus-grafana -n kube-prometheus 3000:80
```

Truy cập <http://localhost:3000> (Mặc định tài khoản: `admin` / `prom-operator`).

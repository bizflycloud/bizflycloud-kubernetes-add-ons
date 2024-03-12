# Giới thiệu về Prometheus

Prometheus là một dự án mã nguồn mở được sử dụng rộng rãi để giám sát hệ thống và ứng dụng. Nó cung cấp các công cụ và thư viện để thu thập, lưu trữ và truy vấn dữ liệu metrics từ các ứng dụng chạy trên cụm hệ thống.

# Tác dụng của Prometheus

- Thu thập metrics: Prometheus có khả năng thu thập metrics từ nhiều nguồn khác nhau như các ứng dụng, server và dịch vụ.

- Giám sát hệ thống và ứng dụng: Prometheus cho phép giám sát và theo dõi hiệu suất và trạng thái của các ứng dụng và hệ thống, từ đó giúp phát hiện và giải quyết các vấn đề hoạt động và hiệu suất.

- Báo cáo và cảnh báo: Prometheus cung cấp các công cụ để tạo ra báo cáo và cảnh báo dựa trên các ngưỡng và quy tắc cấu hình.

# Hướng dẫn cài đặt Prometheus

## Bước 1: Tạo namespace cho Prometheus

Sử dụng lệnh sau để tạo namespace prometheus:

```bash
kubectl create namespace prometheus
```

## Bước 2: Cài đặt Prometheus

Sử dụng Helm để cài đặt Prometheus:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus
```

## Bước 3: Kiểm tra trạng thái của Prometheus

Để kiểm tra trạng thái của Prometheus, sử dụng lệnh sau:

```bash
kubectl get pods -n prometheus
kubectl get services -n prometheus
```

## Bước 4: Sử dụng Prometheus

Truy cập giao diện đồ họa của Prometheus:

- Mặc định, Prometheus cài đặt một giao diện đồ họa trên cổng 9090. Bạn có thể truy cập vào giao diện đồ họa này thông qua trình duyệt web.

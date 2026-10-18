# Karpenter Autoscaler Cho BizFly Kubernetes Engine (BKE)

Karpenter là giải pháp node autoscaling hiệu năng cao thế hệ mới được tích hợp sẵn cho BKE theo mô hình In-Cluster Add-on (tương tự AWS EKS).

## Điểm Nổi Bật
- **Zero-touch Authentication (BKE Credential Injection)**: Khi cài đặt qua Add-on Catalog, toàn bộ thông tin xác thực (`Application Credentials`, `Cluster Token`, `Cluster Join Endpoint`, `VPC Network ID`) được `bke-orchestrator` tự động nạp vào `Secret/bizflycloud-credentials` trong namespace `karpenter`.
- **Just-in-time Node Provisioning**: Tự động tính toán tổng CPU/RAM/Topology của các Pod `Pending` và gọi trực tiếp BizFly Cloud Server API để khởi tạo node có flavor tối ưu nhất mà không bị giới hạn bởi các Worker Pool cố định.
- **Declarative CRD (`NodePool` & `BizflyCloudNodeClass`)**: Hỗ trợ khai báo cấu hình hạ tầng và chính sách gom tải (Consolidation) trực tiếp qua Kubernetes YAML / GitOps.

## Sử Dụng

Sau khi cài đặt add-on thành công, `BizflyCloudNodeClass/default` và `NodePool/default` đã được khởi tạo sẵn. Bạn có thể kiểm tra trạng thái:

```bash
kubectl get pods -n karpenter
kubectl get nodepools,bizflycloudnodeclasses
```

Khi triển khai workload vượt quá tài nguyên hiện tại của cụm, Karpenter sẽ tự động cấp phát Cloud Server mới và đưa vào cụm BKE.

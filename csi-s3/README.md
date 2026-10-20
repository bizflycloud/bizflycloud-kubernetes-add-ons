# Giới thiệu k8s-csi-s3

[k8s-csi-s3](https://github.com/yandex-cloud/k8s-csi-s3) cho phép khách hàng sử dụng Bizflycloud Simple Storage bucket làm một storage cho BKE có khả năng ReadWriteMany. csi-s3 sẽ tạo ra mỗi bucket tương ứng với volume, tương ứng với volume id.

**Chuẩn bị**

1. Access key [API Access Key](https://manage.bizflycloud.vn/simple-storage/access-key)

**Lưu ý:** Vì S3 không phải là một file system thực tế (object storage) nên có một số giới hạn về POSIX compatibility.

## Hướng dẫn sử dụng

### 1. Cài đặt add-on csi-s3 qua Helm

```bash
helm repo add yandex-s3 https://yandex-cloud.github.io/k8s-csi-s3/charts
helm repo update
helm upgrade --install csi-s3 yandex-s3/csi-s3 \
  --namespace csi-s3 \
  --create-namespace \
  --version 0.41.0
```

### 2. Cấu hình Secret xác thực Simple Storage

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: csi-s3-secret
  namespace: csi-s3
stringData:
  accessKeyID: <YOUR_ACCESS_KEY_ID>
  secretAccessKey: <YOUR_SECRET_ACCESS_KEY>
  endpoint: https://hn.ss.bfcplatform.vn
```

Áp dụng secret:

```bash
kubectl apply -f secret.yaml
```

### 3. Tạo PersistentVolumeClaim (PVC)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: csi-s3-pvc
  namespace: default
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: csi-s3
```

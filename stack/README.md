# {{STACK_NAME}}

Tài liệu hướng dẫn cài đặt và cấu hình {{STACK_NAME}} trên cụm Bizfly Kubernetes Engine (BKE).

## Cài đặt bằng Helm

```bash
helm repo add {{HELM_REPO_NAME}} {{HELM_REPO_URL}}
helm repo update
helm upgrade --install {{STACK_NAME}} {{CHART_NAME}} \
  --namespace {{NAMESPACE}} \
  --create-namespace \
  --version {{CHART_VERSION}}
```

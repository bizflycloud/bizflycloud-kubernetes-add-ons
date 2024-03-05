# Đóng góp add-ons

**Yêu cầu: Ứng dụng phải được triển khai sử dụng Helm 3**

Để đóng góp thêm vào [Bizflycloud Kubernetes Add-ons](https://github.com/bizflycloud/bizflycloud-kubernetes-add-ons) cần làm các bước sau:

Cài đặt Helm3 lên máy. [Instructions](https://helm.sh/docs/intro/install/)

## Thêm ứng dụng theo các bước

1. Clone hoặc fork từ [Bizflycloud Kubernetes Add-ons](https://github.com/bizflycloud/bizflycloud-kubernetes-add-ons) repository
2. Tạo một git branch có tên app(ví dụ: `$APP_NAME-PR`)
3. Chạy lệnh sau để tạo các file `deploy.sh`, `upgrade.sh`, `uninstall.sh` và `values.yml`. File sẽ tồn tại ở `/$APP_NAME`

    ```bash
    export HELM_REPO_NAME=$REPO_NAME
    export HELM_REPO_URL=$REPO_URL
    export STACK_NAME=$APP_NAME
    export CHART_NAME=$REPO_NAME/$APP_NAME
    export CHART_VERSION=1.0.0
    export NAMESPACE=$APP_NAME

    ./stack-generate.sh
    ```

4. Có thể tùy biến các file `deploy.sh`, `upgrade.sh`, `uninstall.sh` và các cấu hình trong file `values.yml`. Viết nội dung vào `INFORMATION.md` và mô tả vào `README.md` trong từng thư mục. Có thể bổ sung thêm ảnh vào thư mục `/$APP_NAME/image`
5. Chạy lệnh `chmod +x *.sh` trong thư mục `/$APP_NAME` để đảm bảo các script có quyền excecute
6. Kiểm tra bằng cách cài lên cụm k8s: `./$APP_NAME/deploy.sh`
7. Kiểm trang nâng cấp sử dụng: `./$APP_NAME/upgrade.sh`
8. Kiểm tra việc gỡ cài đặt sử dụng: `./$APP_NAME/uninstall.sh`
9. Tạo Pull Request
10. Đợi Pull Request được review

## Cập nhật ứng dụng

1. Để cập nhật ứng dụng lên phiên bản mới của Helm chart, hãy cập nhật `CHART_VERSION` trong `/$APP_NAME/deploy.sh`. Nếu cần thiết hãy cập nhật cả file `values.yml`.
2. Tạo Pull Request
3. Đợi Pull Request được review

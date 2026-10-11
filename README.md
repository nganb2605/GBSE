# GBSE Web

Dự án web sử dụng Java 17, Spring Boot, Maven và PostgreSQL. Hướng dẫn dưới đây dành cho thành viên mới chạy và phát triển dự án trên máy cá nhân.

## 1. Chuẩn bị

- Git và quyền truy cập repository GitHub của nhóm.
- JDK 17. Kiểm tra bằng `java -version`; cấu hình `JAVA_HOME` trỏ đến JDK nếu Maven chưa tìm thấy Java.
- Docker Desktop đang chạy, sử dụng Linux containers.
- IDE tùy chọn: IntelliJ IDEA hoặc VS Code có hỗ trợ Java.

Dự án có Maven Wrapper nên không cần cài Maven riêng. Lần chạy đầu cần Internet để tải Maven, thư viện và image PostgreSQL.

## 2. Lấy code từ develop

Nếu chưa có dự án trên máy:

```bash
git clone --branch develop [https://github.com/nganb2605/GBSE.git](https://github.com/nganb2605/GBSE.git)
cd GBSE
```

Nếu đã clone dự án, chạy trong thư mục dự án:

```bash
git fetch origin
git switch develop
git pull --ff-only origin develop
```

Nếu chưa có branch local `develop` nhưng đã có `origin/develop`, dùng `git switch --track origin/develop`. Nếu remote chưa có branch này, liên hệ người quản lý repository để đẩy branch lên. Commit hoặc stash công việc đang làm trước khi chuyển branch.

## 3. Khởi động database

Mở Docker Desktop, chờ Docker sẵn sàng rồi chạy tại thư mục chứa `docker-compose.yml`:

```bash
docker compose up -d
docker compose ps
```

Chờ service `db` có trạng thái `healthy`. Cấu hình database local:

| Thông tin | Giá trị |
| --- | --- |
| Host | `localhost` |
| Port | `5432` |
| Database | `vanbom_db` |
| Username | `postgres` |
| Password | `postgres` |

Docker Compose hiện chỉ chạy PostgreSQL. Ứng dụng Java được chạy riêng ở bước 5.

## 4. Tạo cấu hình riêng trên máy

Tạo file `src/main/resources/application-local.properties` và chép nội dung sau. Thay mật khẩu admin mẫu bằng mật khẩu local của bạn **trước lần chạy đầu tiên**:

```properties
DB_URL=jdbc:postgresql://localhost:5432/vanbom_db
DB_USERNAME=postgres
DB_PASSWORD=postgres

ADMIN_USERNAME=admin
ADMIN_PASSWORD=để là gì cũng được, khi chạy project lần đâu sẽ dùng mk này để log vào trang admin

# Có thể để trống nếu chưa cần thử gửi email.
RESEND_API_KEY=
MAIL_FROM=
MAIL_RECEIVER=

# Tắt cache khi phát triển giao diện.
spring.thymeleaf.cache=false
spring.web.resources.cache.cachecontrol.max-age=0
spring.web.resources.cache.cachecontrol.no-store=true
```

File này đã được `.gitignore` loại trừ; mỗi thành viên tự tạo trên máy của mình. Không commit mật khẩu hoặc API key vào Git. Dự án hiện chưa tự đọc file `.env`; chỉ tạo `.env` là chưa đủ cho cách chạy bằng Maven bên dưới.

Giữ kết nối database ở `localhost` khi làm theo hướng dẫn này. Flyway tự chạy migration khi khởi động; một số migration thay đổi hoặc thay thế dữ liệu catalogue, vì vậy không dùng thông tin database production để thử local.

Tài khoản admin chỉ được tạo nếu username chưa tồn tại. Sửa `ADMIN_PASSWORD` rồi khởi động lại **không đổi mật khẩu tài khoản đã có**.

### Cấu hình email Resend (tùy chọn)

Nếu chưa cần kiểm tra email, giữ ba biến email trống; ứng dụng sẽ bỏ qua gửi thông báo.

Khi cần kiểm tra email, điền vào file cấu hình local:

- `RESEND_API_KEY`: API key dành cho phát triển, lấy từ người quản lý Resend của nhóm.
- `MAIL_FROM`: địa chỉ gửi được Resend cho phép sử dụng.
- `MAIL_RECEIVER`: địa chỉ nhận email thử nghiệm.

Nên tạo key riêng cho mỗi thành viên với quyền **Sending access**, và tách key production. Các key cùng team dùng chung hạn mức gửi. Nhận key qua kênh riêng, không đưa vào README hoặc commit. Xem [quyền API key]([https://resend.com/changelog/new-api-key-permissions](https://resend.com/changelog/new-api-key-permissions)) và [Resend Teams]([https://resend.com/blog/multiple-teams](https://resend.com/blog/multiple-teams)).

## 5. Chạy ứng dụng
Chạy lệnh này trtong terminal

./mvnw spring-boot:run -Dspring-boot.run.profiles=local

Chờ ứng dụng khởi động thành công rồi mở **http://localhost:8080**. 


## 6. Làm việc cùng nhóm

Tạo branch riêng từ `develop` đã cập nhật cho mỗi công việc:

```bash
git switch develop
git pull --ff-only origin develop
git switch -c feature/ten-chuc-nang
```

Sau khi sửa code, kiểm tra thay đổi bằng `git status` và `git diff`, rồi stage đúng các file cần gửi. Kiểm tra không có thông tin bí mật trong `git diff --cached`, sau đó:

```bash
git commit -m "Mo ta thay doi"
git push -u origin feature/ten-chuc-nang
```

Tạo Pull Request trên GitHub với branch đích là **develop** để nhóm review và merge. Thay `feature/ten-chuc-nang` bằng tên branch thực tế; có thể dùng tiền tố `fix/` cho sửa lỗi.



## 7. Dừng và chạy lại

- Dừng ứng dụng: nhấn `Ctrl+C` tại terminal đang chạy Maven.
- Dừng database: `docker compose down`. Dữ liệu vẫn được giữ trong Docker volume.
- Lần làm việc tiếp theo: mở Docker Desktop, chạy `docker compose up -d`, rồi chạy ứng dụng với profile `local`.
- Không thêm `-v` vào lệnh `docker compose down` nếu muốn giữ dữ liệu; tùy chọn này xóa volume database local.

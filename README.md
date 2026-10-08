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
git clone --branch develop https://github.com/nganb2605/GBSE.git
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
ADMIN_PASSWORD=change-this-local-password

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

Nên tạo key riêng cho mỗi thành viên với quyền **Sending access**, và tách key production. Các key cùng team dùng chung hạn mức gửi. Nhận key qua kênh riêng, không đưa vào README hoặc commit. Xem [quyền API key](https://resend.com/changelog/new-api-key-permissions) và [Resend Teams](https://resend.com/blog/multiple-teams).

## 5. Chạy ứng dụng

Chạy từ thư mục chứa `pom.xml`, với profile `local` để nạp file cấu hình vừa tạo.

**Git Bash / macOS / Linux:**

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
```

**PowerShell trên Windows:**

```powershell
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=local"
```

Nếu chạy qua IDE, đặt active profile là `local` hoặc thêm program argument `--spring.profiles.active=local` vào cấu hình chạy ứng dụng.

Chờ ứng dụng khởi động thành công rồi mở **http://localhost:8080**. Flyway sẽ thiết lập schema và dữ liệu có trong migration trên database local.

Database mỗi máy là riêng biệt. Dữ liệu bạn đã nhập trên máy khác và các file trong thư mục `uploads/` không tự đồng bộ khi pull Git. Nếu cần giống dữ liệu của thành viên khác, trao đổi thêm bản export database local và các file upload cần thiết.

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

Chạy kiểm thử khi thay đổi logic ứng dụng:

```bash
# Git Bash / macOS / Linux
./mvnw test
```

```powershell
# PowerShell
.\mvnw.cmd test
```

## 7. Dừng và chạy lại

- Dừng ứng dụng: nhấn `Ctrl+C` tại terminal đang chạy Maven.
- Dừng database: `docker compose down`. Dữ liệu vẫn được giữ trong Docker volume.
- Lần làm việc tiếp theo: mở Docker Desktop, chạy `docker compose up -d`, rồi chạy ứng dụng với profile `local`.
- Không thêm `-v` vào lệnh `docker compose down` nếu muốn giữ dữ liệu; tùy chọn này xóa volume database local.

## 8. Lỗi thường gặp

| Hiện tượng | Cách kiểm tra |
| --- | --- |
| Docker không kết nối được daemon | Mở Docker Desktop và chờ khởi động xong. |
| Cổng `5432` đang được sử dụng | Kiểm tra PostgreSQL hoặc container khác đang chạy. Nếu đổi cổng host trong Compose, cập nhật cổng trong `DB_URL` tương ứng. |
| Không tìm thấy `DB_URL` hoặc không kết nối được database | Kiểm tra file cấu hình, profile `local`, và `docker compose ps`. Xem log bằng `docker compose logs db`. |
| Sai username/password database | Đối chiếu cấu hình local với Compose. Volume đã tồn tại giữ thông tin khởi tạo cũ; đổi biến trong Compose không tự đổi mật khẩu database đã tạo. |
| Cổng `8080` đang được sử dụng | Dừng ứng dụng đang chiếm cổng hoặc thêm `PORT=8081` vào cấu hình local rồi mở cổng tương ứng. |
| Không đăng nhập được admin sau khi đổi cấu hình | `ADMIN_PASSWORD` chỉ có tác dụng khi tạo tài khoản mới; tài khoản đã có giữ mật khẩu cũ. |
| Không nhận được email | Kiểm tra ba biến email, quyền gửi của Resend và log ứng dụng. |
| Java/Maven không chạy | Kiểm tra `java -version`, `JAVA_HOME`, và dùng đúng lệnh wrapper cho terminal đang sử dụng. |

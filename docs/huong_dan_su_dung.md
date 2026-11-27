# Hướng dẫn sử dụng và chạy kiểm thử CPU V1

## 1. Phạm vi

- Hướng dẫn chuẩn bị công cụ và chạy lại CPU single-cycle V1 trong repository.
- Chương trình mẫu: `programs/cpu_v1.hex`; test tích hợp: `tb/integration/tb_cpu_top.v`.
- Dành cho người muốn lấy mã nguồn, chạy chương trình kiểm thử và kiểm tra kết quả mô phỏng.

## 2. Chuẩn bị công cụ và mã nguồn

- **Icarus Verilog:** cần có `iverilog` để biên dịch và `vvp` để chạy mô phỏng.
- **VS Code:** dùng để mở repo và terminal.
- **Git/GitHub Desktop:** dùng để lấy code và chọn branch cần kiểm tra.
- Tải toàn bộ repository qua **Code → Download ZIP** trên GitHub rồi giải nén; hoặc dùng Git:

```bash
git clone https://github.com/dinhvu07112k6-cmyk/RV32I-5Stage-Pipeline.git
cd RV32I-5Stage-Pipeline
```

- Không chạy riêng từ gói chỉ chứa các file bổ sung.
- Chọn branch/commit cần kiểm tra, mở thư mục gốc repo trong VS Code rồi chọn **Terminal → New Terminal**.
- Thư mục gốc phải có `rtl/`, `tb/`, `programs/` và `simulation/`.

Nếu Icarus đã có trong PATH, kiểm tra:

```powershell
iverilog -V
vvp -V
```

Nếu terminal không nhận lệnh, vẫn có thể dùng script với tham số `-IcarusBin` ở mục 3.2.

## 3. Chạy trên Windows

### 3.1. Dùng vị trí cài Icarus mặc định

Tại thư mục gốc repo, chạy:

```powershell
powershell -ExecutionPolicy Bypass -File simulation/run_v1.ps1
```

Script mặc định tìm Icarus tại `%LOCALAPPDATA%/Programs/IcarusVerilog/bin`.

### 3.2. Chỉ định vị trí cài Icarus

Nếu cài ở vị trí khác, truyền đường dẫn thư mục chứa `iverilog.exe` và `vvp.exe`:

```powershell
powershell -ExecutionPolicy Bypass -File simulation/run_v1.ps1 -IcarusBin "C:/iverilog/bin"
```

`C:/iverilog/bin` là ví dụ, cần thay bằng vị trí cài trên máy đang chạy.

### 3.3. Nội dung script thực hiện

1. Biên dịch và chạy riêng tám testbench trong `tb/verification/`.
2. Biên dịch và chạy `tb/integration/tb_cpu_top.v`.
3. Ghi log vào `simulation/`; dừng và báo lỗi nếu phát hiện compile hoặc test thất bại.

Script không chạy các test trong `tb/unit/` hay `tb/system/`.

## 4. Chạy trên Linux hoặc macOS

Yêu cầu `iverilog` và `vvp` đã có trong PATH. Tại thư mục gốc repo:

```bash
bash simulation/run_v1.sh
```

Để chỉ chạy test tích hợp:

```bash
iverilog -g2012 -s tb_cpu_top -o simulation/tb_cpu_top.out rtl/common/*.v rtl/single_cycle/cpu_top.v tb/integration/tb_cpu_top.v
vvp simulation/tb_cpu_top.out
```

## 5. Kiểm tra kết quả đầu ra

| File | Nội dung |
|---|---|
| `simulation/tb_<module>_full.log` | Kết quả từng testbench verification |
| `simulation/tb_cpu_top.log` | Kết quả test tích hợp khi chạy bằng script |
| `simulation/tb_cpu_top.out` | File mô phỏng CPU đã biên dịch |
| `simulation/cpu_top_v1.vcd` | Waveform do testbench CPU tạo |

- Bản test tích hợp hiện tại khi đạt có dòng `CPU V1 PASS=102 FAIL=0`.
- Khi thay đổi testbench, số lượt PASS có thể thay đổi; cần đối chiếu đúng phiên bản code.
- Mở log tích hợp trong VS Code để tìm dòng tổng kết PASS/FAIL:

```powershell
Get-Content simulation/tb_cpu_top.log -Tail 10
```

- Nếu script dừng với `Compile FAIL`, `Simulation FAIL` hoặc `FATAL`, lần chạy chưa đạt; xem thông báo và file log tương ứng.
- File VCD chứa dữ liệu waveform; có thể mở bằng GTKWave nếu đã cài. Phân tích tín hiệu chi tiết nằm ngoài phạm vi hướng dẫn chạy này.
- Các file `.out` và `.vcd` là file sinh ra khi mô phỏng, đã được `.gitignore` loại trừ.

## 6. Lỗi khi khởi chạy thường gặp

| Hiện tượng | Cách xử lý |
|---|---|
| Không tìm thấy `tb/verification`, `rtl` hoặc `programs` | Mở đúng repository đầy đủ; chạy từ thư mục gốc |
| Không tìm thấy Icarus | Truyền `-IcarusBin` trỏ đến thư mục bin thực tế |
| `Invalid argument` với đường dẫn tuyệt đối có dấu | Dùng script hiện tại với đường dẫn nguồn tương đối; nếu vẫn lỗi, thử bản sao repo ở đường dẫn không dấu |
| Tiếng Việt trong terminal bị lỗi dấu | Dùng script PowerShell hiện tại đã thiết lập UTF-8 và chạy lại |
| `Compile FAIL`, `Simulation FAIL`, `FAIL` hoặc `FATAL` | Kiểm tra thông báo lỗi và log của test bị dừng; khi báo lỗi, kèm branch/commit và lệnh đã chạy |
| Không có file VCD | Kiểm tra đã chạy test tích hợp chưa và xem lỗi khiến mô phỏng dừng sớm |

## 7. Tài liệu liên quan

- [Thiết kế CPU V1, chương trình mẫu và kết quả kiểm thử](cpu_top_v1.md).
- [Giao diện các module](module_interface.md).

# RV32I 5-Stage Pipeline CPU

**Bài tập lớn MI4344 – Kiến trúc máy tính – Nhóm 4**

## 1. Giới thiệu dự án

Thiết kế và mô phỏng CPU RISC-V RV32I bằng Verilog, hỗ trợ 16 lệnh cơ bản. Dự án được triển khai theo các giai đoạn:

- Giai đoạn 1: Xây dựng CPU tuần tự, kiểm thử các module và tích hợp.
- Giai đoạn 2: Phát triển thành CPU Pipeline 5 giai đoạn (IF, ID, EX, MEM, WB).
- Giai đoạn 3: Tìm hiểu và xử lý các vấn đề Hazard.
- Giai đoạn 4: Mở rộng nếu còn thời gian.

## 2. Cấu trúc Repository

```text
RV32I-5Stage-Pipeline/
│
├── rtl/                  # Mã nguồn Verilog của các module CPU
│
├── tb/                   # Testbench kiểm thử
│   ├── unit/             # Người viết module tự kiểm thử
│   ├── verification/     # Kiểm thử độc lập, chuyên sâu từng module
│   ├── integration/      # Kiểm thử kết nối và phối hợp giữa các module
│   └── system/           # Kiểm thử CPU hoàn chỉnh bằng chương trình RV32I
│
├── programs/             # Chương trình RV32I dạng mã máy (.hex)
│
├── docs/                 # Tài liệu thiết kế, sơ đồ và báo cáo
│
└── simulation/           # Kết quả mô phỏng, waveform và log
```

## 3. Phân công nhiệm vụ

| Thành viên | Phụ trách |
|---|---|
| Phạm Đình Vũ       | PC, Control Unit, bảng giải mã lệnh, tích hợp CPU, Control Hazard; quản lý code |
| Trần Quốc Hùng     | ALU, Immediate Generator, MUX; Data Hazard và Forwarding |
| Đinh Thế Vinh      | Instruction Memory, Register File, Data Memory |
| Nguyễn Khắc An Phú | Testbench, kiểm thử chung, waveform, theo dõi lỗi |
| Lê Xuân Tùng       | Thiết kế, tài liệu, slide, nghiên cứu chuyển CPU sang Pipeline |

## 4. Tập lệnh hỗ trợ

16 lệnh RV32I đã được nhóm lựa chọn:

| Nhóm | Instruction |
|---|---|
| R-type      | ADD, SUB, AND, OR, XOR, SLT, SLL, SRL |
| I-type      | ADDI, ANDI, ORI, SLTI |
| Load/Store  | LW, SW |
| Branch/Jump | BEQ, JAL |

## 5. Công cụ phát triển

- Ngôn ngữ: Verilog
- Code Editor: VS Code
- Compiler/Simulator: Icarus Verilog
- Waveform Viewer: GTKWave
- Version Control: Git/GitHub

## 6. Quy định làm việc chung

1. Mỗi thành viên tự phát triển các module theo phân công.
2. Code Verilog đặt trong `rtl/`, testbench đặt trong `tb/` theo từng loại:
   - `unit/`: Người viết module tự kiểm thử chức năng cơ bản.
   - `verification/`: Người phụ trách kiểm thử thực hiện kiểm thử đầy đủ hơn unit test cho từng chúc năng
   - `integration/`: Người phụ trách kiểm thử kết nối và phối hợp giữa các module.
   - `system/`: Người phụ trách kiểm thử CPU hoàn chỉnh bằng chương trình RV32I.
3. Tài liệu kỹ thuật lưu trong `docs/`, kết quả mô phỏng lưu trong `simulation/`.
4. Thống nhất tên module, các cổng tín hiệu, độ rộng dữ liệu và quy ước reset trước khi tích hợp.
5. Mỗi thành viên làm việc trên branch riêng, không chỉnh sửa trực tiếp `main`.
6. Sau khi hoàn thành một phần công việc, Commit với nội dung mô tả rõ thay đổi.
7. Tạo Pull Request để kiểm tra trước khi merge vào `main`.
8. Mỗi module phải được người lập trình tự kiểm thử trước khi bàn giao; người phụ trách kiểm thử sẽ kiểm tra độc lập trước khi tích hợp.
9. Nếu phát hiện lỗi, thông báo cho thành viên phụ trách để phối hợp sửa và kiểm thử lại.

## 7. Tiến độ

| Thời gian | Nội dung |
|---|---|
| 10/11/2026 – 22h | Rà soát tiến độ và nộp tài liệu phiên bản 1 |
| 14/11/2026 – 21h | Hạn cuối tài liệu phiên bản 2 |
| 14–19/11/2026    | Phát triển CPU Pipeline |
| 19–24/11/2026    | Xử lý Hazard |

## 8. Lưu ý

Repository là nơi lưu trữ mã nguồn chung của nhóm. Các thành viên chủ động cập nhật tiến độ và trao đổi khi gặp khó khăn, đặc biệt là những vấn đề liên quan đến giao diện module và tích hợp CPU.

**Trưởng đội lập trình & phát triển:** Phạm Đình Vũ.

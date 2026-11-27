# RV32I 5-Stage Pipeline CPU

**Bài tập lớn MI4344 – Kiến trúc máy tính – Nhóm 4**

## 1. Giới thiệu thành viên và phân công

| Thành viên | MSSV | GitHub | Phụ trách |
|---|---|---|---|
| Phạm Đình Vũ | 202419021 | [@dinhvu07112k6-cmyk](https://github.com/dinhvu07112k6-cmyk) | PC, Control Unit, bảng giải mã lệnh, tích hợp CPU, Control Hazard; quản lý code |
| Trần Quốc Hùng | 202418909 | [@HungkookVN](https://github.com/HungkookVN) | ALU, Immediate Generator, MUX; Data Hazard và Forwarding |
| Đinh Thế Vinh | 202419017 | [@Vithx06](https://github.com/Vithx06) | Instruction Memory, Register File, Data Memory |
| Nguyễn Khắc An Phú | 202418961 | [@phuan-tech](https://github.com/phuan-tech) | Testbench, kiểm thử chung, waveform, theo dõi lỗi |
| Lê Xuân Tùng | 202419013 | [@KinoStriker](https://github.com/KinoStriker) | Thiết kế, tài liệu, slide, nghiên cứu chuyển CPU sang Pipeline |

## 2. Giới thiệu dự án

Thiết kế và mô phỏng CPU RISC-V RV32I bằng Verilog, hỗ trợ 16 lệnh cơ bản. Dự án được triển khai theo các giai đoạn:

- Giai đoạn 1: Xây dựng CPU tuần tự, kiểm thử các module và tích hợp.
- Giai đoạn 2: Phát triển thành CPU Pipeline 5 giai đoạn (IF, ID, EX, MEM, WB).
- Giai đoạn 3: Tìm hiểu và xử lý các vấn đề Hazard.
- Giai đoạn 4: Mở rộng nếu còn thời gian.

## 3. Cấu trúc Repository

```text
RV32I-5Stage-Pipeline/
├── .gitignore
├── LICENSE
├── README.md
├── rtl/
│   ├── common/                    # Các module dùng chung
│   │   ├── pc.v
│   │   ├── control_unit.v
│   │   ├── alu.v
│   │   ├── imm_generator.v
│   │   ├── mux2_1.v
│   │   ├── instruction_memory.v
│   │   ├── register_file.v
│   │   └── data_memory.v
│   ├── single_cycle/
│   │   └── cpu_top.v              # Top CPU V1
│   └── pipeline/                  # RTL riêng của CPU ID6
├── tb/
│   ├── unit/                      # Kiểm thử module cơ bản
│   ├── verification/              # Kiểm thử module độc lập
│   ├── integration/
│   │   └── tb_cpu_top.v           # Kiểm thử tích hợp CPU
│   └── system/                    # Thư mục kiểm thử hệ thống
├── programs/
│   └── cpu_v1.hex                 # Chương trình mã máy kiểm thử
├── docs/
│   ├── README.md
│   ├── module_interface.md
│   ├── cpu_top_v1.md              # Thiết kế và kiểm thử CPU V1
│   ├── huong_dan_su_dung.md       # Hướng dẫn chạy
│   └── pipeline_interface.md      # Giao diện và cây module pipeline
└── simulation/
    ├── README.md
    ├── run_v1.ps1                 # Chạy kiểm thử trên Windows
    └── run_v1.sh                  # Chạy kiểm thử trên Linux/macOS
```

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

## 6. Hướng dẫn sử dụng

- [Hướng dẫn sử dụng và chạy kiểm thử](docs/huong_dan_su_dung.md).
- [Thiết kế và kiểm thử CPU V1](docs/cpu_top_v1.md).
- [Giao diện các module](docs/module_interface.md).
- [Giao diện pipeline ID6](docs/pipeline_interface.md).

## 7. Quy định làm việc chung

1. Mỗi thành viên tự phát triển các module theo phân công.
2. Code Verilog đặt trong `rtl/`, testbench đặt trong `tb/` theo từng loại:
   - `unit/`: Người viết module tự kiểm thử chức năng cơ bản.
   - `verification/`: Người phụ trách kiểm thử thực hiện kiểm thử đầy đủ hơn unit test cho từng chức năng.
   - `integration/`: Người phụ trách kiểm thử kết nối và phối hợp giữa các module.
   - `system/`: Người phụ trách kiểm thử CPU hoàn chỉnh bằng chương trình RV32I.
3. Tài liệu kỹ thuật lưu trong `docs/`, kết quả mô phỏng lưu trong `simulation/`.
4. Thống nhất tên module, các cổng tín hiệu, độ rộng dữ liệu và quy ước reset trước khi tích hợp.
5. Mỗi thành viên làm việc trên branch riêng, không chỉnh sửa trực tiếp `main`.
6. Sau khi hoàn thành một phần công việc, Commit với nội dung mô tả rõ thay đổi.
7. Tạo Pull Request để kiểm tra trước khi merge vào `main`.
8. Mỗi module phải được người lập trình tự kiểm thử trước khi bàn giao; người phụ trách kiểm thử sẽ kiểm tra độc lập trước khi tích hợp.
9. Nếu phát hiện lỗi, thông báo cho thành viên phụ trách để phối hợp sửa và kiểm thử lại.

## 8. Tiến độ phát triển code

| Thời gian | Nội dung | Hoàn thành |
|---|---|:---:|
| 10/11/2026 | Xây dựng các module CPU V1 và kiểm thử module | ✓ |
| 14–17/11/2026 | Tích hợp CPU single-cycle V1, chạy kiểm thử và merge PR #11 | ✓ |
| 14–19/11/2026 | Phát triển CPU Pipeline 5 giai đoạn | ☐ |
| 19–24/11/2026 | Triển khai và kiểm thử Hazard trên CPU Pipeline | ☐ |

✓: đã hoàn thành; ☐: chưa hoàn thành. Các mốc Pipeline và Hazard theo kế hoạch ban đầu, cập nhật khi nhóm thống nhất điều chỉnh.

## 9. Lưu ý

Repository là nơi lưu trữ mã nguồn chung của nhóm. Các thành viên chủ động cập nhật tiến độ và trao đổi khi gặp khó khăn, đặc biệt là những vấn đề liên quan đến giao diện module và tích hợp CPU.

**Trưởng đội lập trình & phát triển:** Phạm Đình Vũ.

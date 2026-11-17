# CPU top V1 – thiết kế và kiểm thử tích hợp

Đây là CPU single-cycle: mỗi cạnh lên hoàn tất một lệnh. Dùng nguyên tám module V1; chưa có pipeline/hazard.

## Giao diện và đường dữ liệu

`cpu_top(clk, rst, pc_out, instr)`: hai đầu ra để quan sát PC và mã lệnh.
Reset đồng bộ, active-high: PC và toàn bộ thanh ghi về 0 ở cạnh lên.
Data Memory không reset; CPU chặn ghi bộ nhớ khi rst=1.

- PC → Instruction Memory → Control Unit, Register File, ImmGen.
- ALU A = rs1; ALU B chọn rs2/immediate bằng alu_src.
- SW ghi read_data2 tại địa chỉ kết quả ALU.
- result_src 00/01/10 chọn ALU/Data Memory/PC+4.
- pc_next = (jump || (branch && zero)) ? PC+imm : PC+4.
- Instance memory: u_imem.memory và u_dmem.memory; RF: u_rf.registers.
- Nạp mã máy từ testbench qua u_imem.memory; giữ nguyên giao diện các module V1.

## Công cụ và cách chạy

Yêu cầu: Icarus Verilog (iverilog và vvp). GTKWave dùng để xem waveform.
Chạy từ thư mục gốc của repository đầy đủ, có rtl/, tb/, programs/ và simulation/.

### Windows (PowerShell)

Chạy toàn bộ tám testbench module và testbench tích hợp:

```powershell
powershell -ExecutionPolicy Bypass -File simulation/run_v1.ps1
```

Script mặc định tìm Icarus tại thư mục cài theo người dùng:
%LOCALAPPDATA%/Programs/IcarusVerilog/bin.
Nếu cài tại vị trí khác, truyền đường dẫn thư mục bin thực tế qua -IcarusBin:

```powershell
powershell -ExecutionPolicy Bypass -File simulation/run_v1.ps1 -IcarusBin "C:/tools/iverilog/bin"
```

Đường dẫn trên chỉ là ví dụ; không yêu cầu tên tài khoản hay vị trí repo cố định.
Script dùng UTF-8 để hiển thị tiếng Việt và ghi log trong simulation/.

### Linux / macOS (Bash)

Chạy toàn bộ tám testbench module và testbench tích hợp tự động:

```bash
chmod +x simulation/run_v1.sh
./simulation/run_v1.sh
```

### Chạy riêng test tích hợp bằng dòng lệnh

Khi iverilog và vvp đã có trong PATH, có thể chạy bằng Bash trên Linux/macOS:

```bash
iverilog -g2012 -s tb_cpu_top -o simulation/tb_cpu_top.out rtl/*.v tb/integration/tb_cpu_top.v
vvp simulation/tb_cpu_top.out
```

Testbench dừng bằng $fatal nếu kiểm tra sai hoặc quá thời gian.
Waveform được tạo tại simulation/cpu_top_v1.vcd; mở bằng GTKWave.
Các file .out và .vcd là kết quả sinh ra khi chạy, không cần đưa vào Git.

## Chương trình programs/cpu_v1.hex (32 lệnh)

| PC | Lệnh |
|---:|---|
| 0 | ADDI x1,x0,10 |
| 4 | ADDI x2,x0,-3 |
| 8 | ADD x3,x1,x2 |
| 12 | SUB x4,x1,x2 |
| 16 | AND x5,x1,x2 |
| 20 | OR x6,x1,x2 |
| 24 | XOR x7,x1,x2 |
| 28 | SLT x8,x2,x1 |
| 32 | SLL x9,x1,x8 |
| 36 | SRL x10,x9,x8 |
| 40 | ANDI x11,x2,15 |
| 44 | ORI x12,x11,-16 |
| 48 | SLTI x13,x2,-2 |
| 52 | SW x3,4(x0) |
| 56 | LW x14,4(x0) |
| 60 | BEQ x14,x1,+8 (không lấy nhánh) |
| 64 | BEQ x14,x3,+8 (lấy nhánh) |
| 68 | ADDI x15,x0,99 (bị bỏ qua) |
| 72 | JAL x16,+8 (link=76) |
| 76 | ADDI x17,x0,99 (bị bỏ qua) |
| 80 | ADDI x0,x0,99 (x0 giữ 0) |
| 84 | ADDI x18,x0,2 |
| 88 | ADDI x18,x18,-1 |
| 92 | BEQ x18,x0,+8 |
| 96 | JAL x0,-8 |
| 100 | ADDI x19,x0,16 |
| 104 | SW x2,-4(x19) |
| 108 | LW x20,-4(x19) |
| 112 | ADDI x21,x0,2 |
| 116 | ADDI x21,x21,-1 |
| 120 | BEQ x21,x0,-4 |
| 124 | JAL x0,-8 |

Test kiểm PC sau từng cạnh, kết quả đủ 16 lệnh, phụ thuộc liên tiếp, signed immediate,
BEQ lấy/không lấy nhánh và offset âm/dương, JAL link/offset âm/x0,
SW/LW với offset âm, x0, reset giữa chương trình và chạy lại sau reset.
Sau nhánh lùi cuối, test thay lệnh tại PC=116 thành SW rồi bật reset trước cạnh lên:
PC/RF chưa đổi trước cạnh, về 0 sau cạnh; bộ nhớ giữ dữ liệu và không nhận SW.

## Kết quả kiểm thử

Theo các log hiện có trong simulation/:

| Testbench | PASS | FAIL |
|---|---:|---:|
| ALU | 28 | 0 |
| Control Unit | 23 | 0 |
| Data Memory | 22 | 0 |
| Immediate Generator | 18 | 0 |
| Instruction Memory | 17 | 0 |
| MUX 2:1 | 18 | 0 |
| PC | 11 | 0 |
| Register File | 39 | 0 |
| **Tổng kiểm thử module** | **176** | **0** |
| **CPU tích hợp (tb_cpu_top)** | **102** | **0** |

Log module: simulation/tb_<module>_full.log.
Log tích hợp: simulation/tb_cpu_top.log, có dòng CPU V1 PASS=102 FAIL=0.

PASS là số lượt kiểm tra trong testbench, không phải số chương trình hoặc tỷ lệ coverage.
Kết quả xác nhận các trường hợp đã liệt kê ở trên; chưa chứng minh toàn bộ trường hợp RV32I.
Chạy lại kiểm thử sau mỗi thay đổi RTL, chương trình hoặc testbench và lưu log tương ứng.

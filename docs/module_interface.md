# Module Interface Specification

**Project:** RV32I 5-Stage Pipeline CPU  
**Group:** 4  
**Status:** Draft – Pending Team Review

## 1. Quy ước chung (đề xuất)

| Thành phần | Quy ước |
|---|---|
| Data width       | 32 bit |
| Address width    | 32 bit |
| Register file    | 32 thanh ghi, mỗi thanh ghi 32 bit |
| Register index   | 5 bit |
| Clock            | `clk` |
| Reset            | `rst`, active-high (đề xuất) |
| Naming convention| lowercase_snake_case |

## 2. Module Interfaces

Các thành viên đề xuất giao diện cho module mình phụ trách, bao gồm:

- Module name
- Input signals (tên, độ rộng, chức năng)
- Output signals (tên, độ rộng, chức năng)
- Clock/reset (nếu sử dụng)
- Ghi chú về cách kết nối với module khác

### Vũ
- PC
- Control Unit

### Hùng
### Hùng – Khối xử lý dữ liệu

#### 1. ALU (`alu`)

| Tên tín hiệu | Hướng | Độ rộng (bit) | Chức năng |
|---|---|---|---|
| `alu_ctrl` | Đầu vào | 4 | Mã điều khiển phép toán từ Control Unit |
| `src_a` | Đầu vào | 32 | Toán hạng thứ nhất |
| `src_b` | Đầu vào | 32 | Toán hạng thứ hai |
| `alu_result` | Đầu ra | 32 | Kết quả phép toán |
| `zero` | Đầu ra | 1 | Bằng 1 khi kết quả ALU bằng 0; dùng cho BEQ |

**Bảng mã điều khiển ALU (V1)**

| `alu_ctrl` | Phép toán | Lệnh sử dụng |
|---|---|---|
| `0000` | Cộng (ADD) | ADD, ADDI, LW, SW |
| `0001` | Trừ (SUB) | SUB, BEQ |
| `0010` | AND | AND, ANDI |
| `0011` | OR | OR, ORI |
| `0100` | XOR | XOR |
| `0101` | So sánh nhỏ hơn có dấu (SLT) | SLT, SLTI |
| `0110` | Dịch trái logic (SLL) | SLL |
| `0111` | Dịch phải logic (SRL) | SRL |

Các mã còn lại dành cho mở rộng. Với BEQ, ALU thực hiện phép trừ và `zero = 1` khi hai toán hạng bằng nhau.

#### 2. Immediate Generator (`imm_generator`)

| Tên tín hiệu | Hướng | Độ rộng (bit) | Chức năng |
|---|---|---|---|
| `instr` | Đầu vào | 32 | Mã lệnh từ Instruction Memory |
| `imm_ext` | Đầu ra | 32 | Giá trị immediate sau khi trích xuất và mở rộng dấu |

**Chức năng:** Giải mã immediate của các dạng I-type, S-type, B-type và J-type phục vụ 16 lệnh đã chọn. U-type có thể hỗ trợ để mở rộng về sau. Cần thống nhất cách chọn dạng immediate theo `opcode`.

#### 3. MUX 2-to-1 (`mux2_1`)

| Tên tín hiệu | Hướng | Độ rộng (bit) | Chức năng |
|---|---|---|---|
| `in0` | Đầu vào | 32 | Dữ liệu đầu vào thứ nhất |
| `in1` | Đầu vào | 32 | Dữ liệu đầu vào thứ hai |
| `sel` | Đầu vào | 1 | Tín hiệu lựa chọn |
| `out` | Đầu ra | 32 | Dữ liệu đầu ra được chọn |

**Quy tắc:** `sel = 0` chọn `in0`; `sel = 1` chọn `in1`.

**Trạng thái:** Giao diện đề xuất V1 cho CPU tuần tự. Các thay đổi khi tích hợp cần được thống nhất trong nhóm.

### Vinh
- Instruction Memory
- Register File
- Data Memory

### Phú
- Yêu cầu kiểm thử và các tín hiệu cần quan sát

## 3. Nội dung cần thống nhất

- Quy ước clock và reset
- Tên và độ rộng input/output
- Mã hóa tín hiệu điều khiển ALU
- Cách cập nhật PC và xử lý branch/jump
- Quy ước địa chỉ bộ nhớ và truy cập dữ liệu
- Cách kết nối các module trong CPU tuần tự

## 4. Trạng thái

Chưa chốt chính thức. Chờ các thành viên đề xuất, thảo luận và thống nhất trước khi triển khai code.

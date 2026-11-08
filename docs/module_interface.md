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
- **ALU (`alu`)**
  - **Inputs:**
    - `alu_ctrl` (4 bit): Tín hiệu điều khiển phép toán từ ALU Control.
    - `src_a` (32 bit): Toán hạng thứ nhất.
    - `src_b` (32 bit): Toán hạng thứ hai.
  - **Outputs:**
    - `alu_result` (32 bit): Kết quả tính toán.
    - `zero` (1 bit): Cờ báo kết quả bằng 0 (dùng cho lệnh Branch).
  - **Chức năng:** Thực hiện các phép toán số học (add, sub) và logic (and, or, xor, shift, so sánh) dựa trên tín hiệu `alu_ctrl`.

- **Immediate Generator (`imm_generator`)**
  - **Inputs:**
    - `inst` (32 bit): Mã lệnh đầy đủ lấy từ Instruction Memory.
  - **Outputs:**
    - `imm_ext` (32 bit): Giá trị immediate đã được trích xuất và mở rộng dấu (Sign-extend).
  - **Chức năng:** Giải mã các loại lệnh (I-type, S-type, B-type, J-type, U-type) để cắt đúng các bit chứa số tức thời và mở rộng chúng thành số 32 bit hợp lệ đưa vào ALU.

- **MUX 2-to-1 (`mux2_1`)**
  - **Inputs:**
    - `in0` (32 bit): Dữ liệu đầu vào 0.
    - `in1` (32 bit): Dữ liệu đầu vào 1.
    - `sel` (1 bit): Tín hiệu lựa chọn.
  - **Outputs:**
    - `out` (32 bit): Dữ liệu đầu ra được chọn.
  - **Chức năng:** Đóng vai trò làm bộ dồn kênh (như ALUSrc hay MemtoReg). Nếu `sel = 0` thì `out = in0`, nếu `sel = 1` thì `out = in1`.

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

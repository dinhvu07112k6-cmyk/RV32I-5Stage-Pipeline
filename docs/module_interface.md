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
 | Tên tín hiệu | 	Hướng | Độ rộng (bit) | 	Chức năng |
|---|---|---|---|
| clk | Input | 1 | Clock |
| rst | Input | 1 | Reset mức cao |
| pc_next | Input | 32 | Địa chỉ lệnh tiếp theo |
| pc_out | Output | 32 | Địa chỉ lệnh hiện tại |
- Control Unit
### Control Unit – Bộ điều khiển

| Tên tín hiệu | Hướng | Độ rộng (bit) | Chức năng |
|---|---|---|---|
| `opcode` | Đầu vào | 7 | Xác định nhóm lệnh |
| `funct3` | Đầu vào | 3 | Phân biệt các phép toán |
| `funct7` | Đầu vào | 7 | Phân biệt bổ sung các phép toán |
| `reg_write` | Đầu ra | 1 | Cho phép ghi vào thanh ghi |
| `alu_src` | Đầu ra | 1 | Chọn toán hạng thứ hai của ALU |
| `alu_ctrl` | Đầu ra | 4 (đề xuất) | Xác định phép toán ALU thực hiện |
| `mem_read` | Đầu ra | 1 | Cho phép đọc bộ nhớ dữ liệu (nếu sử dụng) |
| `mem_write` | Đầu ra | 1 | Cho phép ghi bộ nhớ dữ liệu |
| `result_src` | Đầu ra | 2 (đề xuất) | Chọn dữ liệu ghi về thanh ghi |
| `branch` | Đầu ra | 1 | Xác định lệnh rẽ nhánh |
| `jump` | Đầu ra | 1 | Xác định lệnh nhảy |

**Trạng thái:** Đề xuất, chưa thống nhất chính thức.
### Hùng
- ALU
- Immediate Generator
- MUX

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

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
- ALU
- Immediate Generator
- MUX

### Vinh

#### Instruction Memory – Bộ nhớ lệnh

| **Tên tín hiệu** | **Hướng** | **Độ rộng (bit)** | **Chức năng** |
|---|---|---|---|
| `addr` | Đầu vào | 32 | Địa chỉ lệnh từ PC |
| `instr` | Đầu ra | 32 | Lệnh được đọc từ bộ nhớ |

**Clock/Reset:** Không sử dụng (đọc tổ hợp).

**Kết nối:** Nhận `pc_out` từ PC, đưa `instr` đến thanh ghi pipeline IF/ID.

#### Register File – Bộ thanh ghi

| **Tên tín hiệu** | **Hướng** | **Độ rộng (bit)** | **Chức năng** |
|---|---|---|---|
| `clk` | Đầu vào | 1 | Clock |
| `rst` | Đầu vào | 1 | Reset mức cao |
| `rs1` | Đầu vào | 5 | Địa chỉ thanh ghi nguồn thứ nhất |
| `rs2` | Đầu vào | 5 | Địa chỉ thanh ghi nguồn thứ hai |
| `rd` | Đầu vào | 5 | Địa chỉ thanh ghi đích |
| `write_data` | Đầu vào | 32 | Dữ liệu ghi vào thanh ghi |
| `reg_write` | Đầu vào | 1 | Cho phép ghi thanh ghi |
| `read_data1` | Đầu ra | 32 | Dữ liệu đọc từ thanh ghi nguồn thứ nhất |
| `read_data2` | Đầu ra | 32 | Dữ liệu đọc từ thanh ghi nguồn thứ hai |

**Clock/Reset:** Ghi tại cạnh lên `clk`, đọc tổ hợp, `rst` active-high (đề xuất reset đồng bộ).

**Kết nối:** Nhận `rs1`, `rs2` từ lệnh ở giai đoạn ID; nhận `rd`, `write_data`, `reg_write` từ giai đoạn WB; đưa dữ liệu đọc đến ID/EX.

#### Data Memory – Bộ nhớ dữ liệu

| **Tên tín hiệu** | **Hướng** | **Độ rộng (bit)** | **Chức năng** |
|---|---|---|---|
| `clk` | Đầu vào | 1 | Clock |
| `addr` | Đầu vào | 32 | Địa chỉ truy cập bộ nhớ |
| `write_data` | Đầu vào | 32 | Dữ liệu ghi vào bộ nhớ |
| `mem_read` | Đầu vào | 1 | Cho phép đọc bộ nhớ |
| `mem_write` | Đầu vào | 1 | Cho phép ghi bộ nhớ |
| `read_data` | Đầu ra | 32 | Dữ liệu đọc từ bộ nhớ |

**Clock/Reset:** Ghi tại cạnh lên `clk`, đọc tổ hợp, không sử dụng reset.

**Kết nối:** Nhận địa chỉ từ kết quả ALU, nhận `mem_read`, `mem_write` từ tín hiệu điều khiển qua pipeline EX/MEM; đưa `read_data` đến MEM/WB.

**Trạng thái:** Đề xuất, chưa thống nhất chính thức.

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

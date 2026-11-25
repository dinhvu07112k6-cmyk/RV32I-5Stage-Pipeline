# Giao diện module pipeline ID6

## 1. Quy ước chung

- Hậu tố `_F`, `_D`, `_E`, `_M`, `_W` ứng với IF, ID, EX, MEM, WB.
- Bốn thanh ghi tầng có hai đầu vào 1 bit `clk` và `rst`. Chốt toàn bộ đầu vào tại cạnh lên. Reset đồng bộ mức 1 đưa tất cả đầu ra về 0.
- `valid=1` là lệnh hợp lệ, `valid=0` là ô trống. Top nối `valid_F` mức 1. Giao diện ID6 cơ bản vận hành với chương trình đã sắp lịch và chèn NOP, chưa có cổng stall, flush hoặc forwarding.
- Các module V1 dùng giao diện trong [module_interface.md](module_interface.md).

## 2. Thanh ghi giữa các tầng

### IF → ID — `pipe_if_id`

| Đầu vào | Đầu ra | Bit mỗi cổng | Chức năng |
|---|---|---:|---|
| `valid_F` | `valid_D` | 1 | Lệnh hợp lệ |
| `pc_F`, `instr_F` | `pc_D`, `instr_D` | 32 | PC và mã lệnh |

### ID → EX — `pipe_id_ex`

| Đầu vào | Đầu ra | Bit mỗi cổng | Chức năng |
|---|---|---:|---|
| `valid_D` | `valid_E` | 1 | Lệnh hợp lệ |
| `pc_D`, `imm_D` | `pc_E`, `imm_E` | 32 | PC của lệnh và immediate đã mở rộng dấu |
| `rs1_value_D`, `rs2_value_D` | `rs1_value_E`, `rs2_value_E` | 32 | Hai giá trị đọc từ Register File |
| `rd_D` | `rd_E` | 5 | Chỉ số thanh ghi đích |
| `alu_src_D` | `alu_src_E` | 1 | Chọn toán hạng B của ALU (0 → rs2, 1 → immediate) |
| `alu_ctrl_D` | `alu_ctrl_E` | 4 | Mã phép toán ALU theo V1 |
| `branch_D`, `jump_D` | `branch_E`, `jump_E` | 1 | Điều khiển BEQ và JAL |
| `mem_read_D`, `mem_write_D`, `reg_write_D` | `mem_read_E`, `mem_write_E`, `reg_write_E` | 1 | Cho phép đọc bộ nhớ, ghi bộ nhớ, ghi thanh ghi |
| `result_src_D` | `result_src_E` | 2 | Chọn nguồn ghi về ở WB |

### EX → MEM — `pipe_ex_mem`

| Đầu vào | Đầu ra | Bit mỗi cổng | Chức năng |
|---|---|---:|---|
| `valid_E` | `valid_M` | 1 | Lệnh hợp lệ |
| `alu_result_E`, `store_data_E`, `pc_plus4_E` | `alu_result_M`, `store_data_M`, `pc_plus4_M` | 32 | Kết quả ALU (địa chỉ LW/SW), dữ liệu SW, địa chỉ trở về của JAL |
| `rd_E` | `rd_M` | 5 | Chỉ số thanh ghi đích |
| `mem_read_E`, `mem_write_E`, `reg_write_E` | `mem_read_M`, `mem_write_M`, `reg_write_M` | 1 | Cho phép đọc bộ nhớ, ghi bộ nhớ, ghi thanh ghi |
| `result_src_E` | `result_src_M` | 2 | Chọn nguồn ghi về ở WB |

### MEM → WB — `pipe_mem_wb`

| Đầu vào | Đầu ra | Bit mỗi cổng | Chức năng |
|---|---|---:|---|
| `valid_M`, `reg_write_M` | `valid_W`, `reg_write_W` | 1 | Lệnh hợp lệ và quyền ghi Register File |
| `alu_result_M`, `mem_data_M`, `pc_plus4_M` | `alu_result_W`, `mem_data_W`, `pc_plus4_W` | 32 | Kết quả ALU, dữ liệu LW, địa chỉ trở về của JAL |
| `rd_M` | `rd_W` | 5 | Chỉ số thanh ghi đích |
| `result_src_M` | `result_src_W` | 2 | Chọn nguồn ghi về ở WB |

## 3. Khối tổ hợp

### EX — `pipeline_execute`

| Tên tín hiệu | Hướng | Bit mỗi cổng | Chức năng |
|---|---|---:|---|
| `valid_E`, `alu_src_E`, `branch_E`, `jump_E` | Đầu vào | 1 | Hợp lệ, chọn toán hạng B, BEQ, JAL |
| `pc_E`, `rs1_value_E`, `rs2_value_E`, `imm_E` | Đầu vào | 32 | PC, hai giá trị thanh ghi nguồn, immediate |
| `alu_ctrl_E` | Đầu vào | 4 | Mã phép toán ALU |
| `alu_result_E`, `store_data_E`, `pc_plus4_E`, `target_E` | Đầu ra | 32 | Kết quả ALU, giá trị rs2, PC của lệnh + 4, PC của lệnh + immediate |
| `redirect_E` | Đầu ra | 1 | Bật khi lệnh hợp lệ và là JAL hoặc BEQ có hai toán hạng bằng nhau |

### WB — `pipeline_writeback`

| Tên tín hiệu | Hướng | Bit mỗi cổng | Chức năng |
|---|---|---:|---|
| `rst`, `valid_W`, `reg_write_W` | Đầu vào | 1 | Reset, lệnh hợp lệ, quyền ghi Register File |
| `rd_W` | Đầu vào | 5 | Chỉ số thanh ghi đích |
| `result_src_W` | Đầu vào | 2 | `00` → ALU, `01` → dữ liệu LW, `10` → PC + 4 của JAL, `11` → xuất 0 và chặn ghi |
| `alu_result_W`, `mem_data_W`, `pc_plus4_W` | Đầu vào | 32 | Ba nguồn dữ liệu ghi về |
| `write_data_W` | Đầu ra | 32 | Dữ liệu ghi về đã chọn |
| `wb_write_en` | Đầu ra | 1 | Cho ghi khi `rst=0`, `valid_W=1`, `reg_write_W=1`, `rd_W≠0` và `result_src_W≠11` |

## 4. Module tổng — `cpu_pipeline`

| Tên tín hiệu | Hướng | Bit mỗi cổng | Chức năng |
|---|---|---:|---|
| `clk`, `rst` | Đầu vào | 1 | Clock và reset đồng bộ mức 1 |
| `pc_F`, `instr_F` | Đầu ra | 32 | PC và mã lệnh đang lấy ở IF |
| `valid_W`, `wb_write_en` | Đầu ra | 1 | Lệnh hợp lệ ở WB và quyền ghi Register File |
| `rd_W` | Đầu ra | 5 | Chỉ số thanh ghi đích ở WB |
| `write_data_W` | Đầu ra | 32 | Dữ liệu ghi Register File |

- **ID** giải mã `instr_D`. **IF** chọn `target_E` khi `redirect_E=1`, bình thường chọn `pc_F + 4`. Reset đưa PC về 0.
- **MEM** dùng `alu_result_M` làm địa chỉ và `store_data_M` làm dữ liệu ghi. Đọc hoặc ghi khi `rst=0`, `valid_M=1` và tín hiệu điều khiển tương ứng bật.
- **WB** nối `rd_W`, `write_data_W`, `wb_write_en` về Register File.

// Chức năng: lưu và đọc lệnh 32 bit cho CPU, không dùng clock/reset.
// - addr là địa chỉ byte từ PC; mỗi lệnh chiếm 4 byte.
// - Mặc định có 256 lệnh; dữ liệu kiểm thử được gán từ testbench.
// - Ô chưa nạp, địa chỉ ngoài bộ nhớ hoặc không chia hết cho 4 trả về NOP.
module instruction_memory #(
    parameter integer depth = 256
) (
    input  wire [31:0] addr,       // Địa chỉ lệnh từ PC
    output wire [31:0] instr       // Lệnh đưa đến IF/ID
);

    // 1. Mỗi phần tử chứa một lệnh; NOP là ADDI x0, x0, 0.
    localparam [31:0] nop = 32'h00000013;
    reg [31:0] memory [0:depth-1];
    integer i;

    // 2. Khởi tạo mọi ô nhớ bằng lệnh NOP.
    initial begin
        for (i = 0; i < depth; i = i + 1)
            memory[i] = nop;
    end

    // 3. Bỏ 2 bit thấp để đổi địa chỉ byte thành chỉ số lệnh.
    assign instr = ((addr[1:0] == 2'b00) && (addr[31:2] < depth))
                   ? memory[addr[31:2]] : nop;

endmodule

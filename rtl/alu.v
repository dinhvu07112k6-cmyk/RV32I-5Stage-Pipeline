// ============================================================================
// Module: ALU (Arithmetic Logic Unit)
// Phụ trách: Trần Quốc Hùng
// Mô tả: Thực hiện các phép toán số học và logic cho CPU RV32I
// ============================================================================

module alu (
    input  [3:0]  alu_ctrl,    // Mã điều khiển phép toán từ Control Unit
    input  [31:0] src_a,       // Toán hạng 1 (từ Register File)
    input  [31:0] src_b,       // Toán hạng 2 (từ Register File hoặc Imm)
    output reg [31:0] alu_result, // Kết quả tính toán 32-bit
    output        zero         // Cờ báo kết quả bằng 0 (dùng cho lệnh BEQ)
);

    // Cờ zero bật lên 1 khi hai toán hạng bằng nhau (src_a - src_b = 0)
    assign zero = (alu_result == 32'b0);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: alu_result = src_a + src_b;                           // ADD, ADDI, LW, SW
            4'b0001: alu_result = src_a - src_b;                           // SUB, BEQ
            4'b0010: alu_result = src_a & src_b;                           // AND, ANDI
            4'b0011: alu_result = src_a | src_b;                           // OR, ORI
            4'b0100: alu_result = src_a ^ src_b;                           // XOR
            4'b0101: alu_result = ($signed(src_a) < $signed(src_b)) ? 32'd1 : 32'd0; // SLT, SLTI (So sánh có dấu)
            4'b0110: alu_result = src_a << src_b[4:0];                     // SLL (Dịch trái logic)
            4'b0111: alu_result = src_a >> src_b[4:0];                     // SRL (Dịch phải logic)
            default: alu_result = 32'b0;
        endcase
    end

endmodule
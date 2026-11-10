// ============================================================================
// Module: Immediate Generator
// Phụ trách: Trần Quốc Hùng
// Mô tả: Trích xuất và mở rộng dấu Immediate từ mã lệnh 32-bit
// ============================================================================

module imm_generator (
    input  [31:0] instr,      // Mã lệnh 32-bit từ Instruction Memory
    output reg [31:0] imm_ext // Giá trị Immediate 32-bit sau khi mở rộng dấu
);

    // Opcode nằm ở 7 bit cuối [6:0]
    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            // I-type: ADDI, ANDI, ORI, SLTI, LW
            7'b0010011, 7'b0000011: begin
                imm_ext = {{20{instr[31]}}, instr[31:20]};
            end

            // S-type: SW
            7'b0100011: begin
                imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            // B-type: BEQ (chú ý bit cuối cùng luôn bằng 0 do địa chỉ lệnh chẵn)
            7'b1100011: begin
                imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            // J-type: JAL (chú ý bit cuối cùng luôn bằng 0)
            7'b1101111: begin
                imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            // Mặc định (các lệnh R-type không dùng Immediate)
            default: begin
                imm_ext = 32'b0;
            end
        endcase
    end

endmodule

module control_unit (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,

    output reg reg_write,
    output reg alu_src,
    output reg [3:0] alu_ctrl,
    output reg mem_read,
    output reg mem_write,
    output reg [1:0] result_src,
    output reg branch,
    output reg jump
);

    // Bang ma ALU V1
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;
    localparam ALU_SLT = 4'b0101;
    localparam ALU_SLL = 4'b0110;
    localparam ALU_SRL = 4'b0111;

    always @(*) begin
        // Gia tri mac dinh
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        alu_ctrl   = ALU_ADD;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        result_src = 2'b00;
        branch     = 1'b0;
        jump       = 1'b0;

        case (opcode)

            // R-type: ADD, SUB, AND, OR,
            // XOR, SLT, SLL, SRL
            7'b0110011: begin
                case ({funct7, funct3})
                    10'b0000000_000: begin
                        reg_write = 1'b1;
                        alu_ctrl = ALU_ADD;
                    end
                    10'b0100000_000: begin
                        reg_write = 1'b1;
                        alu_ctrl = ALU_SUB;
                    end
                    10'b0000000_111: begin
                        reg_write = 1'b1;
                        alu_ctrl = ALU_AND;
                    end
                    10'b0000000_110: begin
                        reg_write = 1'b1;
                        alu_ctrl = ALU_OR;
                    end
                    10'b0000000_100: begin
                        reg_write = 1'b1;
                        alu_ctrl = ALU_XOR;
                    end
                    10'b0000000_010: begin
                        reg_write = 1'b1;
                        alu_ctrl = ALU_SLT;
                    end
                    10'b0000000_001: begin
                        reg_write = 1'b1;
                        alu_ctrl = ALU_SLL;
                    end
                    10'b0000000_101: begin
                        reg_write = 1'b1;
                        alu_ctrl = ALU_SRL;
                    end
                    default: begin
                        // Lenh chua duoc ho tro
                    end
                endcase
            end

            // I-type: ADDI, ANDI, ORI, SLTI
            7'b0010011: begin
                alu_src = 1'b1;
                case (funct3)
                    3'b000: begin
                        reg_write = 1'b1;
                        alu_ctrl = ALU_ADD;
                    end
                    3'b111: begin
                        reg_write = 1'b1;
                        alu_ctrl = ALU_AND;
                    end
                    3'b110: begin
                        reg_write = 1'b1;
                        alu_ctrl = ALU_OR;
                    end
                    3'b010: begin
                        reg_write = 1'b1;
                        alu_ctrl = ALU_SLT;
                    end
                    default: begin
                        // Lenh chua duoc ho tro
                    end
                endcase
            end

            // LW
            7'b0000011: begin
                if (funct3 == 3'b010) begin
                    reg_write  = 1'b1;
                    alu_src    = 1'b1;
                    alu_ctrl   = ALU_ADD;
                    mem_read   = 1'b1;
                    result_src = 2'b01;
                end
            end

            // SW
            7'b0100011: begin
                if (funct3 == 3'b010) begin
                    alu_src   = 1'b1;
                    alu_ctrl  = ALU_ADD;
                    mem_write = 1'b1;
                end
            end

            // BEQ
            7'b1100011: begin
                if (funct3 == 3'b000) begin
                    branch   = 1'b1;
                    alu_ctrl = ALU_SUB;
                end
            end

            // JAL
            7'b1101111: begin
                jump       = 1'b1;
                reg_write  = 1'b1;
                result_src = 2'b10;
            end

            default: begin
                // Mac dinh khong ghi thanh ghi
                // va khong ghi bo nho
            end
        endcase
    end

endmodule

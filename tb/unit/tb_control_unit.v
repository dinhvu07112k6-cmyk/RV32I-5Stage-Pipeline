
`timescale 1ns/1ps

module tb_control_unit;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire reg_write, alu_src;
    wire [3:0] alu_ctrl;
    wire mem_read, mem_write;
    wire [1:0] result_src;
    wire branch, jump;

    integer passed = 0;
    integer failed = 0;

    control_unit uut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_ctrl(alu_ctrl),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .result_src(result_src),
        .branch(branch),
        .jump(jump)
    );

    // Thu tu bit:
    // reg_write, alu_src, alu_ctrl[3:0],
    // mem_read, mem_write, result_src[1:0],
    // branch, jump
    wire [11:0] actual = {
        reg_write, alu_src, alu_ctrl,
        mem_read, mem_write, result_src,
        branch, jump
    };

    task check;
        input [95:0] name;
        input [6:0] op;
        input [2:0] f3;
        input [6:0] f7;
        input [11:0] expected;
        begin
            opcode = op;
            funct3 = f3;
            funct7 = f7;
            #1;

            if (actual === expected) begin
                $display("PASS: %0s", name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %0s | got=%h expected=%h",
                         name, actual, expected);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        // 8 lenh R-type
        check("ADD", 7'b0110011, 3'b000,
              7'b0000000, 12'h800);
        check("SUB", 7'b0110011, 3'b000,
              7'b0100000, 12'h840);
        check("AND", 7'b0110011, 3'b111,
              7'b0000000, 12'h880);
        check("OR", 7'b0110011, 3'b110,
              7'b0000000, 12'h8C0);
        check("XOR", 7'b0110011, 3'b100,
              7'b0000000, 12'h900);
        check("SLT", 7'b0110011, 3'b010,
              7'b0000000, 12'h940);
        check("SLL", 7'b0110011, 3'b001,
              7'b0000000, 12'h980);
        check("SRL", 7'b0110011, 3'b101,
              7'b0000000, 12'h9C0);

        // 4 lenh I-type
        check("ADDI", 7'b0010011, 3'b000,
              7'b0000000, 12'hC00);
        check("ANDI", 7'b0010011, 3'b111,
              7'b0000000, 12'hC80);
        check("ORI", 7'b0010011, 3'b110,
              7'b0000000, 12'hCC0);
        check("SLTI", 7'b0010011, 3'b010,
              7'b0000000, 12'hD40);

        // Load va Store
        check("LW", 7'b0000011, 3'b010,
              7'b0000000, 12'hC24);
        check("SW", 7'b0100011, 3'b010,
              7'b0000000, 12'h410);

        // Branch va Jump
        check("BEQ", 7'b1100011, 3'b000,
              7'b0000000, 12'h042);
        check("JAL", 7'b1101111, 3'b000,
              7'b0000000, 12'h809);

        // Hai truong hop khong ho tro
        check("INVALID_R", 7'b0110011, 3'b000,
              7'b1111111, 12'h000);
        check("INVALID_OP", 7'b1111111, 3'b000,
              7'b0000000, 12'h000);

        $display("---------------------------");
        $display("PASSED = %0d", passed);
        $display("FAILED = %0d", failed);

        if (failed == 0)
            $display("ALL CONTROL UNIT TESTS PASSED");
        else
            $display("CONTROL UNIT TESTS FAILED");

        $finish;
    end

endmodule

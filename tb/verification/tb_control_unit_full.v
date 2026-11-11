`timescale 1ns/1ps

module tb_control_unit_full;

    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg  [6:0] funct7;

    wire       reg_write;
    wire       alu_src;
    wire [3:0] alu_ctrl;
    wire       mem_read;
    wire       mem_write;
    wire [1:0] result_src;
    wire       branch;
    wire       jump;

    integer passed = 0;
    integer failed = 0;

    // DUT
    control_unit dut (
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

    // Ghép 12 bit điều khiển để kiểm tra dễ dàng:
    // {reg_write, alu_src, alu_ctrl[3:0], mem_read, mem_write, result_src[1:0], branch, jump}
    wire [11:0] actual_bus = {
        reg_write, alu_src, alu_ctrl,
        mem_read, mem_write, result_src,
        branch, jump
    };

    task verify_inst;
        input [8*40:1] name;
        input [6:0]   op;
        input [2:0]   f3;
        input [6:0]   f7;
        input [11:0]  expected_bus;
        begin
            opcode = op;
            funct3 = f3;
            funct7 = f7;
            #5; // Đợi lan truyền mạch tổ hợp

            if (actual_bus === expected_bus) begin
                $display("[PASS] %0s | Bus=%b (alu_ctrl=%b, result_src=%b)", 
                         name, actual_bus, alu_ctrl, result_src);
                passed = passed + 1;
            end else begin
                $display("[FAIL] %0s | Nhận=%b, Kỳ vọng=%b", 
                         name, actual_bus, expected_bus);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("simulation/tb_control_unit_full.vcd");
        $dumpvars(0, tb_control_unit_full);

        // Định dạng bit:
        // reg_write (1b), alu_src (1b), alu_ctrl (4b),
        // mem_read (1b), mem_write (1b), result_src (2b),
        // branch (1b), jump (1b)

        // --------------------------------------------------------------------
        // 1. NHÓM R-TYPE (8 LỆNH: ADD, SUB, AND, OR, XOR, SLT, SLL, SRL)
        // Opcode = 7'b0110011, alu_src=0, mem_read=0, mem_write=0, res_src=00, br=0, jp=0
        // --------------------------------------------------------------------
        $display("\n--- 1. KIỂM THỬ NHÓM R-TYPE ---");
        verify_inst("ADD ", 7'b0110011, 3'b000, 7'b0000000, 12'b1_0_0000_0_0_00_0_0);
        verify_inst("SUB ", 7'b0110011, 3'b000, 7'b0100000, 12'b1_0_0001_0_0_00_0_0);
        verify_inst("AND ", 7'b0110011, 3'b111, 7'b0000000, 12'b1_0_0010_0_0_00_0_0);
        verify_inst("OR  ", 7'b0110011, 3'b110, 7'b0000000, 12'b1_0_0011_0_0_00_0_0);
        verify_inst("XOR ", 7'b0110011, 3'b100, 7'b0000000, 12'b1_0_0100_0_0_00_0_0);
        verify_inst("SLT ", 7'b0110011, 3'b010, 7'b0000000, 12'b1_0_0101_0_0_00_0_0);
        verify_inst("SLL ", 7'b0110011, 3'b001, 7'b0000000, 12'b1_0_0110_0_0_00_0_0);
        verify_inst("SRL ", 7'b0110011, 3'b101, 7'b0000000, 12'b1_0_0111_0_0_00_0_0);

        // --------------------------------------------------------------------
        // 2. NHÓM I-TYPE (4 LỆNH: ADDI, ANDI, ORI, SLTI)
        // Opcode = 7'b0010011, alu_src=1, mem_read=0, mem_write=0, res_src=00, br=0, jp=0
        // --------------------------------------------------------------------
        $display("\n--- 2. KIỂM THỬ NHÓM I-TYPE TOÁN HỌC ---");
        verify_inst("ADDI", 7'b0010011, 3'b000, 7'b0000000, 12'b1_1_0000_0_0_00_0_0);
        verify_inst("ANDI", 7'b0010011, 3'b111, 7'b0000000, 12'b1_1_0010_0_0_00_0_0);
        verify_inst("ORI ", 7'b0010011, 3'b110, 7'b0000000, 12'b1_1_0011_0_0_00_0_0);
        verify_inst("SLTI", 7'b0010011, 3'b010, 7'b0000000, 12'b1_1_0101_0_0_00_0_0);

        // --------------------------------------------------------------------
        // 3. NHÓM LOAD / STORE (LW, SW)
        // --------------------------------------------------------------------
        $display("\n--- 3. KIỂM THỬ NHÓM LOAD / STORE ---");
        // LW: reg_write=1, alu_src=1, alu_ctrl=ADD(0000), mem_read=1, mem_write=0, result_src=01
        verify_inst("LW  ", 7'b0000011, 3'b010, 7'b0000000, 12'b1_1_0000_1_0_01_0_0);
        // SW: reg_write=0, alu_src=1, alu_ctrl=ADD(0000), mem_read=0, mem_write=1, result_src=00
        verify_inst("SW  ", 7'b0100011, 3'b010, 7'b0000000, 12'b0_1_0000_0_1_00_0_0);

        // --------------------------------------------------------------------
        // 4. NHÓM BRANCH / JUMP (BEQ, JAL)
        // --------------------------------------------------------------------
        $display("\n--- 4. KIỂM THỬ NHÓM BRANCH / JUMP ---");
        // BEQ: branch=1, alu_ctrl=SUB(0001), alu_src=0, reg_write=0
        verify_inst("BEQ ", 7'b1100011, 3'b000, 7'b0000000, 12'b0_0_0001_0_0_00_1_0);
        // JAL: jump=1, reg_write=1, result_src=10 (PC+4)
        verify_inst("JAL ", 7'b1101111, 3'b000, 7'b0000000, 12'b1_0_0000_0_0_10_0_1);

        // --------------------------------------------------------------------
        // 5. CÁC TRƯỜNG HỢP BIÊN & NGOẠI LỆ (CORNER CASES / ILLEGAL OPCODES)
        // Kiểm tra tính an toàn: không được phép ghi nhầm thanh ghi hoặc bộ nhớ
        // --------------------------------------------------------------------
        $display("\n--- 5. KIỂM THỬ NGOẠI LỆ & LỆNH KHÔNG HỢP LỆ ---");
        
        // 5.1 Opcode lạ hoàn toàn (toàn 0 hoặc toàn 1)
        verify_inst("ILLEGAL OP 0x00", 7'b0000000, 3'b000, 7'b0000000, 12'b0_0_0000_0_0_00_0_0);
        verify_inst("ILLEGAL OP 0x7F", 7'b1111111, 3'b111, 7'b1111111, 12'b0_0_0000_0_0_00_0_0);

        // 5.2 R-type với funct3 chưa hỗ trợ (ví dụ f3 = 3'b011)
        verify_inst("R-TYPE INVALID FUNCT3", 7'b0110011, 3'b011, 7'b0000000, 12'b0_0_0000_0_0_00_0_0);

        // 5.3 R-type với funct7 lạ (ví dụ ADD nhưng funct7 = 0000001)
        verify_inst("R-TYPE INVALID FUNCT7", 7'b0110011, 3'b000, 7'b0000001, 12'b0_0_0000_0_0_00_0_0);

        // 5.4 I-type với funct3 chưa hỗ trợ (ví dụ f3 = 3'b100)
        verify_inst("I-TYPE INVALID FUNCT3", 7'b0010011, 3'b100, 7'b0000000, 12'b0_1_0000_0_0_00_0_0);

        // 5.5 Lệnh Load với funct3 sai (không phải LW byte-aligned f3=010)
        verify_inst("LOAD INVALID FUNCT3", 7'b0000011, 3'b000, 7'b0000000, 12'b0_0_0000_0_0_00_0_0);

        // 5.6 Lệnh Branch với funct3 sai (không phải BEQ f3=000)
        verify_inst("BRANCH INVALID FUNCT3", 7'b1100011, 3'b001, 7'b0000000, 12'b0_0_0000_0_0_00_0_0);

        // Tổng kết
        $display("\n==================================================");
        $display("   TỔNG KẾT CONTROL_UNIT_TB: %0d PASSED, %0d FAILED", passed, failed);
        $display("==================================================");

        if (failed == 0)
            $display(">>> KẾT QUẢ: TOÀN BỘ 16 LỆNH VÀ CÁC CA NGOẠI LỆ ĐÃ ĐẠT! <<<");
        else
            $display(">>> KẾT QUẢ: CÓ SAI LỆCH TÍN HIỆU ĐIỀU KHIỂN! <<<");

        $finish;
    end

endmodule


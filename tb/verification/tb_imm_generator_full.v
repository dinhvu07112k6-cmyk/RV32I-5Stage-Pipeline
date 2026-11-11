`timescale 1ns/1ps

module tb_imm_generator_full;

    reg  [31:0] instr;
    wire [31:0] imm_ext;

    integer passed = 0;
    integer failed = 0;

    // DUT
    imm_generator dut (
        .instr(instr),
        .imm_ext(imm_ext)
    );

    task check_imm;
        input [8*45:1] name;
        input [31:0]   expected_imm;
        begin
            #2; // Thời gian lan truyền
            if (imm_ext === expected_imm) begin
                $display("[PASS] %0s | Imm = %h (%0d)", 
                         name, imm_ext, $signed(imm_ext));
                passed = passed + 1;
            end else begin
                $display("[FAIL] %0s | Nhận: %h (%0d), Kỳ vọng: %h (%0d)", 
                         name, imm_ext, $signed(imm_ext), expected_imm, $signed(expected_imm));
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("simulation/tb_imm_generator_full.vcd");
        $dumpvars(0, tb_imm_generator_full);

        // --------------------------------------------------------------------
        // 1. KHUÔN DẠNG I-TYPE (ADDI, ANDI, ORI, SLTI, LW)
        // --------------------------------------------------------------------
        $display("\n--- 1. KIỂM THỬ KHUÔN DẠNG I-TYPE ---");
        // ADDI: opcode = 7'b0010011, rd=x1, rs1=x2, funct3=000
        // Immediate dương: +15 (12'h00F)
        instr = {12'h00F, 5'd2, 3'b000, 5'd1, 7'b0010011};
        check_imm("I-type ADDI: Imm duong (+15)", 32'd15);

        // Immediate duong lon nhat: +2047 (12'h7FF)
        instr = {12'h7FF, 5'd2, 3'b000, 5'd1, 7'b0010011};
        check_imm("I-type ADDI: Imm duong max (+2047)", 32'd2047);

        // Immediate am: -1 (12'hFFF)
        instr = {12'hFFF, 5'd2, 3'b000, 5'd1, 7'b0010011};
        check_imm("I-type ADDI: Imm am (-1)", -32'd1);

        // Immediate am nho nhat: -2048 (12'h800)
        instr = {12'h800, 5'd2, 3'b000, 5'd1, 7'b0010011};
        check_imm("I-type ADDI: Imm am min (-2048)", -32'd2048);

        // LW: opcode = 7'b0000011
        // Offset duong: +64 (12'h040)
        instr = {12'h040, 5'd2, 3'b010, 5'd1, 7'b0000011};
        check_imm("I-type LW: Offset (+64)", 32'd64);

        // Offset am: -32 (12'hFE0)
        instr = {12'hFE0, 5'd2, 3'b010, 5'd1, 7'b0000011};
        check_imm("I-type LW: Offset am (-32)", -32'd32);

        // --------------------------------------------------------------------
        // 2. KHUÔN DẠNG S-TYPE (SW) - Opcode = 7'b0100011
        // Tách đôi: imm[11:5] nằm ở instr[31:25], imm[4:0] nằm ở instr[11:7]
        // --------------------------------------------------------------------
        $display("\n--- 2. KIỂM THỬ KHUÔN DẠNG S-TYPE ---");
        // Offset duong: +40 = 12'h028 = 12'b0000001_01000
        // imm[11:5] = 7'b0000001, imm[4:0] = 5'b01000
        instr = {7'b0000001, 5'd3, 5'd2, 3'b010, 5'b01000, 7'b0100011};
        check_imm("S-type SW: Offset duong (+40)", 32'd40);

        // Offset am: -20 = 12'hFEC = 12'b1111111_01100
        // imm[11:5] = 7'b1111111, imm[4:0] = 5'b01100
        instr = {7'b1111111, 5'd3, 5'd2, 3'b010, 5'b01100, 7'b0100011};
        check_imm("S-type SW: Offset am (-20)", -32'd20);

        // --------------------------------------------------------------------
        // 3. KHUÔN DẠNG B-TYPE (BEQ) - Opcode = 7'b1100011
        // Trộn bit: imm[12]=instr[31], imm[11]=instr[7], imm[10:5]=instr[30:25],
        //           imm[4:1]=instr[11:8], imm[0]=0
        // --------------------------------------------------------------------
        $display("\n--- 3. KIỂM THỬ KHUÔN DẠNG B-TYPE (BRANCH) ---");
        // Nhay tien +16 (13'b0_0000_0001_0000)
        // imm[12]=0, imm[11]=0, imm[10:5]=6'b000000, imm[4:1]=4'b1000, imm[0]=0
        // instr[31]=0, instr[30:25]=000000, instr[11:8]=1000, instr[7]=0
        instr = {1'b0, 6'b000000, 5'd2, 5'd1, 3'b000, 4'b1000, 1'b0, 7'b1100011};
        check_imm("B-type BEQ: Nhay tien (+16)", 32'd16);

        // Test rieng bit imm[11] = 1 (Nhay +2048):
        // instr[31]=0, instr[7]=1, cac bit khac = 0
        instr = {1'b0, 6'b000000, 5'd2, 5'd1, 3'b000, 4'b0000, 1'b1, 7'b1100011};
        check_imm("B-type BEQ: Test bit 11 (+2048)", 32'd2048);

        // Nhay lui (so am): -4 (13'b1_1111_1111_1100)
        // imm[12]=1, imm[11]=1, imm[10:5]=6'b111111, imm[4:1]=4'b1110, imm[0]=0
        // instr[31]=1, instr[30:25]=111111, instr[11:8]=1110, instr[7]=1
        instr = {1'b1, 6'b111111, 5'd2, 5'd1, 3'b000, 4'b1110, 1'b1, 7'b1100011};
        check_imm("B-type BEQ: Nhay lui (-4)", -32'd4);

        // Nhay lui lon: -40
        // -40 = 13'h1FD8 = 13'b1_1111_1101_1000
        // imm[12]=1, imm[11]=1, imm[10:5]=6'b111110, imm[4:1]=4'b1100
        instr = {1'b1, 6'b111110, 5'd2, 5'd1, 3'b000, 4'b1100, 1'b1, 7'b1100011};
        check_imm("B-type BEQ: Nhay lui (-40)", -32'd40);

        // --------------------------------------------------------------------
        // 4. KHUÔN DẠNG J-TYPE (JAL) - Opcode = 7'b1101111
        // Trộn bit: imm[20]=instr[31], imm[19:12]=instr[19:12], imm[11]=instr[20],
        //           imm[10:1]=instr[30:21], imm[0]=0
        // --------------------------------------------------------------------
        $display("\n--- 4. KIỂM THỬ KHUÔN DẠNG J-TYPE (JUMP) ---");
        // Nhay tien +8:
        // imm[20]=0, imm[19:12]=0, imm[11]=0, imm[10:1]=10'b0000000100 (bit 3=1, bit 2..1=00)
        // instr[31]=0, instr[30:21]=10'b0000000100, instr[20]=0, instr[19:12]=8'b0
        instr = {1'b0, 10'b0000000100, 1'b0, 8'b00000000, 5'd1, 7'b1101111};
        check_imm("J-type JAL: Nhay tien (+8)", 32'd8);

        // Nhay tien xa: test bit 11 (instr[20]=1) -> +2048
        instr = {1'b0, 10'b0000000000, 1'b1, 8'b00000000, 5'd1, 7'b1101111};
        check_imm("J-type JAL: Test bit 11 (+2048)", 32'd2048);

        // Nhay tien rat xa: test dai bit imm[19:12] (instr[19:12] = 8'h01 -> bit 12=1 -> +4096)
        instr = {1'b0, 10'b0000000000, 1'b0, 8'h01, 5'd1, 7'b1101111};
        check_imm("J-type JAL: Test bit 12 (+4096)", 32'd4096);

        // Nhay lui: -4
        // -4 = 21'b1_11111111_1_1111111110_0
        // instr[31]=1, instr[30:21]=10'b1111111110, instr[20]=1, instr[19:12]=8'hFF
        instr = {1'b1, 10'b1111111110, 1'b1, 8'hFF, 5'd1, 7'b1101111};
        check_imm("J-type JAL: Nhay lui (-4)", -32'd4);

        // --------------------------------------------------------------------
        // 5. CÁC LỆNH KHÔNG DÙNG IMMEDIATE (R-TYPE HOẶC MÃ LẠ) -> PHẢI VỀ 0
        // --------------------------------------------------------------------
        $display("\n--- 5. KIỂM THỬ LỆNH KHÔNG DÙNG IMMEDIATE ---");
        // R-type (ADD): opcode = 7'b0110011
        instr = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
        check_imm("R-type (ADD): Tra ve 0", 32'd0);

        // Default unknown opcode
        instr = 32'h0000_0000;
        check_imm("Unknown Opcode: Tra ve 0", 32'd0);

        // Tổng kết
        $display("\n==================================================");
        $display("   TỔNG KẾT IMM_GENERATOR_TB: %0d PASSED, %0d FAILED", passed, failed);
        $display("==================================================");

        if (failed == 0)
            $display(">>> KẾT QUẢ: TOÀN BỘ 4 DẠNG IMM VÀ DẤU ĐẠT CHUẨN! <<<");
        else
            $display(">>> KẾT QUẢ: CÓ SAI LỆCH TRÍCH XUẤT IMMEDIATE! <<<");

        $finish;
    end

endmodule


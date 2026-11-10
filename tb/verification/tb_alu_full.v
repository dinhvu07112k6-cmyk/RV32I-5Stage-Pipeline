`timescale 1ns/1ps

module tb_alu_full;

    reg  [3:0]  alu_ctrl;
    reg  [31:0] src_a;
    reg  [31:0] src_b;
    wire [31:0] alu_result;
    wire        zero;

    integer passed = 0;
    integer failed = 0;

    // DUT
    alu dut (
        .alu_ctrl(alu_ctrl),
        .src_a(src_a),
        .src_b(src_b),
        .alu_result(alu_result),
        .zero(zero)
    );

    task check_alu;
        input [8*45:1] name;
        input [31:0]   exp_result;
        input          exp_zero;
        begin
            #2; // Thời gian lan truyền tổ hợp
            if (alu_result === exp_result && zero === exp_zero) begin
                $display("[PASS] %0s | Res=%h (%0d), Zero=%b", 
                         name, alu_result, $signed(alu_result), zero);
                passed = passed + 1;
            end else begin
                $display("[FAIL] %0s | Nhận: Res=%h, Zero=%b | Kỳ vọng: Res=%h, Zero=%b", 
                         name, alu_result, zero, exp_result, exp_zero);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("simulation/tb_alu_full.vcd");
        $dumpvars(0, tb_alu_full);

        // --------------------------------------------------------------------
        // 1. Phép toán ADD (alu_ctrl = 4'b0000)
        // --------------------------------------------------------------------
        $display("\n--- 1. KIỂM THỬ PHÉP ADD ---");
        alu_ctrl = 4'b0000;
        
        src_a = 32'd25; src_b = 32'd15;
        check_alu("ADD: 25 + 15 = 40", 32'd40, 1'b0);

        src_a = 32'd10; src_b = -32'd10;
        check_alu("ADD: 10 + (-10) = 0 (Check Zero)", 32'd0, 1'b1);

        src_a = 32'h7FFF_FFFF; src_b = 32'd1;
        check_alu("ADD: Tran so duong sang am (0x80000000)", 32'h8000_0000, 1'b0);

        src_a = 32'hFFFF_FFFF; src_b = 32'd1;
        check_alu("ADD: Tran 32-bit ve 0 (Check Zero)", 32'd0, 1'b1);

        // --------------------------------------------------------------------
        // 2. Phép toán SUB (alu_ctrl = 4'b0001)
        // --------------------------------------------------------------------
        $display("\n--- 2. KIỂM THỬ PHÉP SUB (VÀ CỜ ZERO CHO BEQ) ---");
        alu_ctrl = 4'b0001;

        src_a = 32'd50; src_b = 32'd20;
        check_alu("SUB: 50 - 20 = 30", 32'd30, 1'b0);

        src_a = 32'h1234_5678; src_b = 32'h1234_5678;
        check_alu("SUB: Hai so bang nhau -> Zero = 1 (BEQ)", 32'd0, 1'b1);

        src_a = 32'd10; src_b = 32'd25;
        check_alu("SUB: So nho tru so lon (10 - 25 = -15)", -32'd15, 1'b0);

        // --------------------------------------------------------------------
        // 3. Phép toán AND (alu_ctrl = 4'b0010)
        // --------------------------------------------------------------------
        $display("\n--- 3. KIỂM THỬ PHÉP AND ---");
        alu_ctrl = 4'b0010;

        src_a = 32'hFF00_AA55; src_b = 32'h0FF0_55AA;
        check_alu("AND: Bitmask logic", 32'h0F00_0000, 1'b0);

        src_a = 32'hAAAA_AAAA; src_b = 32'h5555_5555;
        check_alu("AND: Tat ca bit triet tieu ve 0", 32'd0, 1'b1);

        // --------------------------------------------------------------------
        // 4. Phép toán OR (alu_ctrl = 4'b0011)
        // --------------------------------------------------------------------
        $display("\n--- 4. KIỂM THỬ PHÉP OR ---");
        alu_ctrl = 4'b0011;

        src_a = 32'hAAAA_0000; src_b = 32'h0000_5555;
        check_alu("OR: Ghep bit AAAA5555", 32'hAAAA_5555, 1'b0);

        src_a = 32'd0; src_b = 32'd0;
        check_alu("OR: 0 OR 0 = 0", 32'd0, 1'b1);

        // --------------------------------------------------------------------
        // 5. Phép toán XOR (alu_ctrl = 4'b0100)
        // --------------------------------------------------------------------
        $display("\n--- 5. KIỂM THỬ PHÉP XOR ---");
        alu_ctrl = 4'b0100;

        src_a = 32'hDEAD_BEEF; src_b = 32'hDEAD_BEEF;
        check_alu("XOR: Hai so giong nhau XOR = 0", 32'd0, 1'b1);

        src_a = 32'hFFFF_FFFF; src_b = 32'h0000_FFFF;
        check_alu("XOR: Dao 16 bit cao", 32'hFFFF_0000, 1'b0);

        // --------------------------------------------------------------------
        // 6. Phép toán SLT (alu_ctrl = 4'b0101 - SO SÁNH CÓ DẤU)
        // --------------------------------------------------------------------
        $display("\n--- 6. KIỂM THỬ PHÉP SLT (SIGNED COMPARISON) ---");
        alu_ctrl = 4'b0101;

        src_a = 32'd10; src_b = 32'd20;
        check_alu("SLT: 10 < 20 (Duong < Duong)", 32'd1, 1'b0);

        src_a = 32'd20; src_b = 32'd10;
        check_alu("SLT: 20 < 10 (Duong > Duong)", 32'd0, 1'b1);

        src_a = -32'd5; src_b = 32'd5;
        check_alu("SLT: -5 < 5 (Am < Duong - Quan trong!)", 32'd1, 1'b0);

        src_a = 32'd5; src_b = -32'd5;
        check_alu("SLT: 5 < -5 (Duong > Am)", 32'd0, 1'b1);

        src_a = -32'd15; src_b = -32'd3;
        check_alu("SLT: -15 < -3 (Am < Am)", 32'd1, 1'b0);

        src_a = -32'd3; src_b = -32'd15;
        check_alu("SLT: -3 < -15 (Am > Am)", 32'd0, 1'b1);

        src_a = 32'd100; src_b = 32'd100;
        check_alu("SLT: Hai so bang nhau -> 0", 32'd0, 1'b1);

        // --------------------------------------------------------------------
        // 7. Phép toán SLL (alu_ctrl = 4'b0110 - DỊCH TRÁI LOGIC)
        // --------------------------------------------------------------------
        $display("\n--- 7. KIỂM THỬ PHÉP SLL (SHIFT LEFT LOGICAL) ---");
        alu_ctrl = 4'b0110;

        src_a = 32'h0000_0001; src_b = 32'd4;
        check_alu("SLL: 1 << 4 = 16", 32'h0000_0010, 1'b0);

        src_a = 32'h0000_0001; src_b = 32'd31;
        check_alu("SLL: 1 << 31 = 0x80000000", 32'h8000_0000, 1'b0);

        // Kiểm tra mặt nạ shamt: chỉ lấy 5 bit cuối src_b[4:0] (36 -> 4)
        src_a = 32'h0000_0001; src_b = 32'd36; // 36 = 32 + 4
        check_alu("SLL: Mask src_b[4:0] (36 -> dich 4 bit)", 32'h0000_0010, 1'b0);

        // --------------------------------------------------------------------
        // 8. Phép toán SRL (alu_ctrl = 4'b0111 - DỊCH PHẢI LOGIC)
        // --------------------------------------------------------------------
        $display("\n--- 8. KIỂM THỬ PHÉP SRL (SHIFT RIGHT LOGICAL) ---");
        alu_ctrl = 4'b0111;

        src_a = 32'h8000_0000; src_b = 32'd1;
        check_alu("SRL: 0x80000000 >> 1 = 0x40000000 (chen bit 0)", 32'h4000_0000, 1'b0);

        src_a = 32'h8000_0000; src_b = 32'd31;
        check_alu("SRL: 0x80000000 >> 31 = 1", 32'h0000_0001, 1'b0);

        src_a = 32'hFFFF_FFFF; src_b = 32'd8;
        check_alu("SRL: 0xFFFFFFFF >> 8 = 0x00FFFFFF", 32'h00FF_FFFF, 1'b0);

        // Mask src_b[4:0]
        src_a = 32'h8000_0000; src_b = 32'd33; // 33 = 32 + 1
        check_alu("SRL: Mask src_b[4:0] (33 -> dich 1 bit)", 32'h4000_0000, 1'b0);

        // --------------------------------------------------------------------
        // 9. Mã điều khiển không xác định (Default / Unused codes)
        // --------------------------------------------------------------------
        $display("\n--- 9. KIỂM THỬ MÃ DEFAULT ---");
        alu_ctrl = 4'b1111;
        src_a = 32'h1234_5678; src_b = 32'h9ABC_DEF0;
        check_alu("ALU Default code 4'b1111 -> Tra ve 0", 32'd0, 1'b1);

        // Tổng kết
        $display("\n==================================================");
        $display("   TỔNG KẾT ALU_TB: %0d PASSED, %0d FAILED        ", passed, failed);
        $display("==================================================");

        if (failed == 0)
            $display(">>> KẾT QUẢ: TOÀN BỘ 8 PHÉP TOÁN VÀ CỜ ZERO ĐẠT CHUẨN! <<<");
        else
            $display(">>> KẾT QUẢ: CÓ SAI LỆCH TRONG TÍNH TOÁN ALU! <<<");

        $finish;
    end

endmodule


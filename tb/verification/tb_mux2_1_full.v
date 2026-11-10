`timescale 1ns/1ps

module tb_mux2_1_full;

    reg  [31:0] in0;
    reg  [31:0] in1;
    reg         sel;
    wire [31:0] out;

    integer passed = 0;
    integer failed = 0;

    // DUT
    mux2_1 dut (
        .in0(in0),
        .in1(in1),
        .sel(sel),
        .out(out)
    );

    task check_mux;
        input [8*45:1] name;
        input [31:0]   expected_out;
        begin
            #2; // Thời gian lan truyền
            if (out === expected_out) begin
                $display("[PASS] %0s | sel=%b, out=%h", name, sel, out);
                passed = passed + 1;
            end else begin
                $display("[FAIL] %0s | sel=%b, Nhận: %h, Kỳ vọng: %h", 
                         name, sel, out, expected_out);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("simulation/tb_mux2_1_full.vcd");
        $dumpvars(0, tb_mux2_1_full);

        // --------------------------------------------------------------------
        // 1. KIỂM THỬ KÊNH 0 (sel = 0)
        // --------------------------------------------------------------------
        $display("\n--- 1. KIỂM THỬ KÊNH 0 (sel = 0) ---");
        sel = 1'b0;
        in0 = 32'h1111_2222;
        in1 = 32'hAAAA_BBBB;
        check_mux("Chon kenh 0 co ban", 32'h1111_2222);

        // Thay đổi in0 -> out phải bám theo in0
        in0 = 32'h3333_4444;
        check_mux("Kenh 0: in0 thay doi -> out bam theo", 32'h3333_4444);

        // Thay đổi in1 -> out KHÔNG được phép đổi
        in1 = 32'hFFFF_0000;
        check_mux("Kenh 0: in1 thay doi -> out khong doi (cach ly tot)", 32'h3333_4444);

        // --------------------------------------------------------------------
        // 2. KIỂM THỬ KÊNH 1 (sel = 1)
        // --------------------------------------------------------------------
        $display("\n--- 2. KIỂM THỬ KÊNH 1 (sel = 1) ---");
        sel = 1'b1;
        check_mux("Chuyen sang kenh 1", 32'hFFFF_0000);

        // Thay đổi in1 -> out bám theo in1
        in1 = 32'h5555_6666;
        check_mux("Kenh 1: in1 thay doi -> out bam theo", 32'h5555_6666);

        // Thay đổi in0 -> out KHÔNG được phép đổi
        in0 = 32'h0000_1234;
        check_mux("Kenh 1: in0 thay doi -> out khong doi (cach ly tot)", 32'h5555_6666);

        // --------------------------------------------------------------------
        // 3. CÁC MẪU DỮ LIỆU ĐẶC BIỆT (CORNER CASES)
        // --------------------------------------------------------------------
        $display("\n--- 3. KIỂM THỬ CÁC MẪU DỮ LIỆU ĐẶC BIỆT ---");
        // Toàn 0 và Toàn 1
        in0 = 32'h0000_0000;
        in1 = 32'hFFFF_FFFF;

        sel = 1'b0;
        check_mux("Mau dac biet: sel=0 chon toan 0", 32'h0000_0000);

        sel = 1'b1;
        check_mux("Mau dac biet: sel=1 chon toan 1", 32'hFFFF_FFFF);

        // Đổi chỗ
        in0 = 32'hFFFF_FFFF;
        in1 = 32'h0000_0000;

        sel = 1'b0;
        check_mux("Mau dac biet dao: sel=0 chon toan 1", 32'hFFFF_FFFF);

        sel = 1'b1;
        check_mux("Mau dac biet dao: sel=1 chon toan 0", 32'h0000_0000);

        // --------------------------------------------------------------------
        // 4. CHUYỂN MẠCH LIÊN TỤC (FAST SWITCHING)
        // --------------------------------------------------------------------
        $display("\n--- 4. KIỂM THỬ CHUYỂN MẠCH LIÊN TỤC ---");
        in0 = 32'hCAFE_BABE;
        in1 = 32'hDEAD_BEEF;

        repeat (4) begin
            sel = 0; #1;
            check_mux("Chuyen nhanh sel=0", 32'hCAFE_BABE);
            sel = 1; #1;
            check_mux("Chuyen nhanh sel=1", 32'hDEAD_BEEF);
        end

        // Tổng kết
        $display("\n==================================================");
        $display("   TỔNG KẾT MUX2_1_TB: %0d PASSED, %0d FAILED     ", passed, failed);
        $display("==================================================");

        if (failed == 0)
            $display(">>> KẾT QUẢ: MODULE MUX 2:1 ĐẠT CHUẨN HOÀN TOÀN! <<<");
        else
            $display(">>> KẾT QUẢ: CÓ LỖI CHUYỂN MẠCH MUX 2:1! <<<");

        $finish;
    end

endmodule

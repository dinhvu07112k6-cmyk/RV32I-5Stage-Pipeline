`timescale 1ns/1ps

module tb_register_file_full;

    reg         clk;
    reg         rst;
    reg  [4:0]  rs1;
    reg  [4:0]  rs2;
    reg  [4:0]  rd;
    reg  [31:0] write_data;
    reg         reg_write;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    integer passed = 0;
    integer failed = 0;
    integer i;

    // DUT
    register_file dut (
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Clock 10ns
    always #5 clk = ~clk;

    task check_val;
        input [31:0] actual;
        input [31:0] expected;
        input [8*50:1] test_name;
        begin
            if (actual === expected) begin
                $display("[PASS] %0s | Gia tri: %h", test_name, actual);
                passed = passed + 1;
            end else begin
                $display("[FAIL] %0s | Nhận: %h, Kỳ vọng: %h", test_name, actual, expected);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("simulation/tb_register_file_full.vcd");
        $dumpvars(0, tb_register_file_full);

        clk        = 0;
        rst        = 1;
        reg_write  = 0;
        rs1        = 0;
        rs2        = 0;
        rd         = 0;
        write_data = 0;

        // --------------------------------------------------------------------
        // 1. KIỂM THỬ RESET ĐỒNG BỘ CHO TẤT CẢ 32 THANH GHI
        // --------------------------------------------------------------------
        $display("\n--- 1. KIỂM THỬ RESET TOÀN BỘ THANH GHI ---");
        @(posedge clk);
        #1;
        rst = 0;

        for (i = 0; i < 32; i = i + 1) begin
            rs1 = i[4:0];
            #1;
            if (read_data1 !== 32'd0) begin
                $display("[FAIL] Thanh ghi x%0d sau reset khong bang 0! (val=%h)", i, read_data1);
                failed = failed + 1;
            end
        end
        if (failed == 0) begin
            $display("[PASS] Toan bo 32 thanh ghi da duoc xoa sach ve 0 sau Reset");
            passed = passed + 1;
        end

        // --------------------------------------------------------------------
        // 2. GHI VÀ ĐỌC TUẦN TỰ TOÀN BỘ CÁC THANH GHI (x1 đến x31)
        // --------------------------------------------------------------------
        $display("\n--- 2. GHI VA DOC LAI 31 THANH GHI (x1 -> x31) ---");
        for (i = 1; i < 32; i = i + 1) begin
            @(negedge clk);
            reg_write  = 1;
            rd         = i[4:0];
            write_data = 32'hA000_0000 + i;

            @(posedge clk); // Ghi tai canh len
        end

        @(negedge clk);
        reg_write = 0; // Tat ghi

        // Doc kiem tra lai
        for (i = 1; i < 32; i = i + 1) begin
            rs1 = i[4:0];
            #1;
            check_val(read_data1, 32'hA000_0000 + i, "Kiem tra doc x[i] tren rs1");
        end

        // --------------------------------------------------------------------
        // 3. ĐỌC ĐỒNG THỜI 2 CỔNG ĐỘC LẬP (rs1 va rs2) KHÔNG CẦN CLOCK
        // --------------------------------------------------------------------
        $display("\n--- 3. KIỂM THỬ ĐỌC ĐỒNG THỜI 2 CỔNG ĐỘC LẬP ---");
        rs1 = 5'd7;
        rs2 = 5'd19;
        #1;
        check_val(read_data1, 32'hA000_0007, "Doc cong rs1 = x7");
        check_val(read_data2, 32'hA000_0013, "Doc cong rs2 = x19");

        // --------------------------------------------------------------------
        // 4. KIỂM THỬ TÍNH BẤT BIẾN CỦA THANH GHI x0 (HARDWIRED TO 0)
        // Cố tình ghi các giá trị khác nhau vào x0, kiểm tra x0 luôn = 0
        // --------------------------------------------------------------------
        $display("\n--- 4. KIỂM THỬ TÍNH BẤT BIẾN CỦA THANH GHI x0 ---");
        @(negedge clk);
        reg_write  = 1;
        rd         = 5'd0;
        write_data = 32'hDEAD_BEEF;
        @(posedge clk);

        @(negedge clk);
        write_data = 32'hFFFF_FFFF;
        @(posedge clk);

        @(negedge clk);
        reg_write = 0;
        rs1 = 5'd0;
        rs2 = 5'd0;
        #1;
        check_val(read_data1, 32'd0, "x0 tren cong rs1 luon bang 0");
        check_val(read_data2, 32'd0, "x0 tren cong rs2 luon bang 0");

        // --------------------------------------------------------------------
        // 5. KIỂM THỬ VÔ HIỆU HÓA GHI (reg_write = 0)
        // --------------------------------------------------------------------
        $display("\n--- 5. KIỂM THỬ KHI reg_write = 0 (KHÔNG ĐƯỢC PHÉP GHI) ---");
        @(negedge clk);
        reg_write  = 0;
        rd         = 5'd10;
        write_data = 32'h5555_5555; // Thu ghi de len x10 dang chua 32'hA000_000A
        @(posedge clk);

        @(negedge clk);
        rs1 = 5'd10;
        #1;
        check_val(read_data1, 32'hA000_000A, "x10 khong bi ghi de khi reg_write=0");

        // --------------------------------------------------------------------
        // 6. KIỂM THỬ ƯU TIÊN RESET SO VỚI GHI
        // Khi ca rst=1 va reg_write=1 dong thoi, reset phai thang
        // --------------------------------------------------------------------
        $display("\n--- 6. KIỂM THỬ ƯU TIÊN RESET SO VỚI GHI ---");
        @(negedge clk);
        rst        = 1;
        reg_write  = 1;
        rd         = 5'd15;
        write_data = 32'h1234_5678;
        @(posedge clk);

        @(negedge clk);
        rst       = 0;
        reg_write = 0;
        rs1       = 5'd15;
        #1;
        check_val(read_data1, 32'd0, "Reset uu tien hon ghi (x15 tro ve 0)");

        // --------------------------------------------------------------------
        // 7. GHI ĐÈ LÊN THANH GHI ĐÃ CÓ DỮ LIỆU
        // --------------------------------------------------------------------
        $display("\n--- 7. KIỂM THỬ GHI ĐÈ DỮ LIỆU MỚI ---");
        @(negedge clk);
        reg_write  = 1;
        rd         = 5'd1;
        write_data = 32'hCAFE_BABE;
        @(posedge clk);

        @(negedge clk);
        reg_write = 0;
        rs1 = 5'd1;
        #1;
        check_val(read_data1, 32'hCAFE_BABE, "x1 duoc cap nhat gia tri moi thanh cong");

        // Tổng kết
        $display("\n==================================================");
        $display("   TỔNG KẾT REGISTER_FILE_TB: %0d PASSED, %0d FAILED", passed, failed);
        $display("==================================================");

        if (failed == 0)
            $display(">>> KẾT QUẢ: TOÀN BỘ CHỨC NĂNG REGISTER FILE ĐẠT CHUẨN! <<<");
        else
            $display(">>> KẾT QUẢ: CÓ LỖI XẢY RA TRONG REGISTER FILE! <<<");

        $finish;
    end

endmodule


`timescale 1ns/1ps

module tb_data_memory_full;

    reg         clk;
    reg  [31:0] addr;
    reg  [31:0] write_data;
    reg         mem_read;
    reg         mem_write;
    wire [31:0] read_data;

    localparam integer DEPTH = 256;

    integer passed = 0;
    integer failed = 0;
    integer i;

    // DUT
    data_memory #(.depth(DEPTH)) dut (
        .clk(clk),
        .addr(addr),
        .write_data(write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(read_data)
    );

    // Clock 10ns
    always #5 clk = ~clk;

    task check_data;
        input [31:0] expected;
        input [8*50:1] test_name;
        begin
            #1; // Đợi lan truyền đọc tổ hợp
            if (read_data === expected) begin
                $display("[PASS] %0s | addr=%h -> data=%h", test_name, addr, read_data);
                passed = passed + 1;
            end else begin
                $display("[FAIL] %0s | addr=%h -> Nhận: %h, Kỳ vọng: %h", 
                         test_name, addr, read_data, expected);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("simulation/tb_data_memory_full.vcd");
        $dumpvars(0, tb_data_memory_full);

        clk        = 0;
        addr       = 0;
        write_data = 0;
        mem_read   = 0;
        mem_write  = 0;

        // --------------------------------------------------------------------
        // 1. KIỂM THỬ TRẠNG THÁI KHỞI TẠO (BAN ĐẦU TOÀN 0)
        // --------------------------------------------------------------------
        $display("\n--- 1. KIỂM THỬ TRẠNG THÁI BAN ĐẦU ---");
        mem_read = 1;
        addr     = 32'd0; check_data(32'd0, "Khoi tao addr=0 co gia tri 0");
        addr     = 32'd4; check_data(32'd0, "Khoi tao addr=4 co gia tri 0");
        addr     = 32'd8; check_data(32'd0, "Khoi tao addr=8 co gia tri 0");

        // --------------------------------------------------------------------
        // 2. GHI ĐỒNG BỘ VÀ ĐỌC TỔ HỢP (SYNCHRONOUS WRITE, ASYNC READ)
        // --------------------------------------------------------------------
        $display("\n--- 2. GHI ĐỒNG BỘ TẠI CẠNH LÊN VÀ ĐỌC TỔ HỢP ---");
        @(negedge clk);
        mem_write  = 1;
        mem_read   = 0;
        addr       = 32'd4;
        write_data = 32'hA1B2_C3D4;
        @(posedge clk); // Thuc hien ghi

        @(negedge clk);
        mem_write  = 0;
        mem_read   = 1;
        check_data(32'hA1B2_C3D4, "Doc lai du lieu vua ghi vao addr=4");

        // --------------------------------------------------------------------
        // 3. KIỂM SOÁT TÍN HIỆU ĐỌC (KHI mem_read = 0 THÌ read_data PHẢI = 0)
        // --------------------------------------------------------------------
        $display("\n--- 3. KIỂM SOÁT TÍN HIỆU mem_read ---");
        mem_read = 0; // Tat doc du dia chi addr=4 co du lieu
        check_data(32'd0, "Khi mem_read=0 thi read_data luon = 0");

        mem_read = 1; // Bat lai doc
        check_data(32'hA1B2_C3D4, "Bat lai mem_read=1 thi xuat dung du lieu");

        // --------------------------------------------------------------------
        // 4. KIỂM SOÁT TÍN HIỆU GHI (KHI mem_write = 0 KHÔNG ĐƯỢC GHI ĐÈ)
        // --------------------------------------------------------------------
        $display("\n--- 4. KIỂM SOÁT TÍN HIỆU mem_write = 0 ---");
        @(negedge clk);
        mem_write  = 0; // Khong cho ghi
        mem_read   = 0;
        addr       = 32'd4;
        write_data = 32'hFFFF_FFFF;
        @(posedge clk);

        @(negedge clk);
        mem_read = 1;
        check_data(32'hA1B2_C3D4, "Du lieu khong bi ghi de khi mem_write=0");

        // --------------------------------------------------------------------
        // 5. KIỂM THỬ TRUY CẬP BIÊN BỘ NHỚ (BOUNDARY CONDITIONS)
        // --------------------------------------------------------------------
        $display("\n--- 5. KIỂM THỬ TRUY CẬP BIÊN BỘ NHỚ ---");
        // Ô cuối cùng hợp lệ: chỉ số 255 -> byte addr = 255 * 4 = 1020 (0x3FC)
        @(negedge clk);
        mem_write  = 1;
        mem_read   = 0;
        addr       = 32'd1020;
        write_data = 32'hCAFE_BABE;
        @(posedge clk);

        @(negedge clk);
        mem_write = 0;
        mem_read  = 1;
        check_data(32'hCAFE_BABE, "Ghi/Doc tai o nho cuoi cung hop le (addr=1020)");

        // Địa chỉ ngoài biên gần: byte addr = 1024 -> Phải bỏ qua ghi và đọc ra 0
        @(negedge clk);
        mem_write  = 1;
        mem_read   = 0;
        addr       = 32'd1024;
        write_data = 32'hDEAD_DEAD;
        @(posedge clk);

        @(negedge clk);
        mem_write = 0;
        mem_read  = 1;
        check_data(32'd0, "Doc ngoai bien (addr=1024) -> Tra ve 0");

        // Địa chỉ ngoài biên rất xa:
        addr = 32'h0008_0000;
        check_data(32'd0, "Doc dia chi xa (0x00080000) -> Tra ve 0");

        // --------------------------------------------------------------------
        // 6. KIỂM THỬ ĐỊA CHỈ KHÔNG CĂN LỀ 4-BYTE (MISALIGNED ADDRESSES)
        // --------------------------------------------------------------------
        $display("\n--- 6. KIỂM THỬ ĐỊA CHỈ LỆCH BIÊN (MISALIGNED) ---");
        // Cố tình ghi vào địa chỉ addr=1 (không chia hết cho 4)
        @(negedge clk);
        mem_write  = 1;
        mem_read   = 0;
        addr       = 32'd1;
        write_data = 32'hBAD0_BAD0;
        @(posedge clk);

        // Kiểm tra xem ô hợp lệ lân cận (addr=0) có bị ghi bẩn không
        @(negedge clk);
        mem_write = 0;
        mem_read  = 1;
        addr      = 32'd0;
        check_data(32'd0, "addr=0 khong bi ghi ban boi truy xuat lech bien");

        // Thử đọc từ địa chỉ lệch biên: addr=1, 2, 3
        addr = 32'd1; check_data(32'd0, "Doc lech bien addr=1 -> Tra ve 0");
        addr = 32'd2; check_data(32'd0, "Doc lech bien addr=2 -> Tra ve 0");
        addr = 32'd3; check_data(32'd0, "Doc lech bien addr=3 -> Tra ve 0");

        // --------------------------------------------------------------------
        // 7. GHI VÀ ĐỌC LIÊN TỤC 8 Ô NHỚ KHÁC NHAU
        // --------------------------------------------------------------------
        $display("\n--- 7. GHI VÀ ĐỌC HÀNG LOẠT Ô NHỚ ---");
        mem_read = 0;
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            mem_write  = 1;
            addr       = i * 4;
            write_data = 32'h5500_0000 + i;
            @(posedge clk);
        end

        @(negedge clk);
        mem_write = 0;
        mem_read  = 1;
        for (i = 0; i < 8; i = i + 1) begin
            addr = i * 4;
            #1;
            check_data(32'h5500_0000 + i, "Kiem tra doc lai mang o nho");
        end

        // Tổng kết
        $display("\n==================================================");
        $display("   TỔNG KẾT DATA_MEMORY_TB: %0d PASSED, %0d FAILED", passed, failed);
        $display("==================================================");

        if (failed == 0)
            $display(">>> KẾT QUẢ: MODULE DATA MEMORY ĐẠT CHUẨN HOÀN TOÀN! <<<");
        else
            $display(">>> KẾT QUẢ: CÓ SAI LỆCH TRONG DATA MEMORY! <<<");

        $finish;
    end

endmodule


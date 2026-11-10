`timescale 1ns/1ps

module tb_pc_full;

    reg         clk;
    reg         rst;
    reg  [31:0] pc_next;
    wire [31:0] pc_out;

    integer passed = 0;
    integer failed = 0;

    // Khởi tạo Device Under Test (DUT)
    pc dut (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    // Tạo clock 100MHz (chu kỳ 10ns: 5ns low, 5ns high)
    always #5 clk = ~clk;

    // Task kiểm tra tự động
    task check_pc;
        input [31:0] expected_pc;
        input [8*40:1] test_name;
        begin
            #1; // Đợi ổn định sau cạnh lên clock
            if (pc_out === expected_pc) begin
                $display("[PASS] %0s | PC = %h", test_name, pc_out);
                passed = passed + 1;
            end else begin
                $display("[FAIL] %0s | Nhận được PC = %h, Kỳ vọng = %h", test_name, pc_out, expected_pc);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("simulation/tb_pc_full.vcd");
        $dumpvars(0, tb_pc_full);

        clk     = 0;
        rst     = 1;
        pc_next = 32'hFFFF_FFFF;

        // Test 1: Reset đồng bộ khi khởi động (bất chấp pc_next)
        @(posedge clk);
        check_pc(32'h0000_0000, "TC1: Reset khoi tao");

        // Test 2: Giữ reset trong nhiều chu kỳ
        repeat (3) @(posedge clk);
        check_pc(32'h0000_0000, "TC2: Duy tri Reset");

        // Test 3: Nhả reset, cập nhật tuần tự PC + 4
        @(negedge clk);
        rst     = 0;
        pc_next = 32'd4;
        @(posedge clk);
        check_pc(32'd4, "TC3.1: Cap nhat PC = 4");

        @(negedge clk);
        pc_next = 32'd8;
        @(posedge clk);
        check_pc(32'd8, "TC3.2: Cap nhat PC = 8");

        @(negedge clk);
        pc_next = 32'd12;
        @(posedge clk);
        check_pc(32'd12, "TC3.3: Cap nhat PC = 12");

        // Test 4: Kiểm tra tính ổn định giữa 2 cạnh clock (không cập nhật ở cạnh xuống)
        @(negedge clk);
        pc_next = 32'd100;
        #2;
        if (pc_out === 32'd12) begin
            $display("[PASS] TC4: PC khong bi nhay tai negedge | PC = %0d", pc_out);
            passed = passed + 1;
        end else begin
            $display("[FAIL] TC4: PC bi nhay sai tai negedge | PC = %0d", pc_out);
            failed = failed + 1;
        end

        // Cạnh lên kế tiếp mới nạp 100
        @(posedge clk);
        check_pc(32'd100, "TC4: Cap nhat tai posedge ke tiep");

        // Test 5: Nhảy địa chỉ lớn (Branch / JAL jump target)
        @(negedge clk);
        pc_next = 32'h0004_0000;
        @(posedge clk);
        check_pc(32'h0004_0000, "TC5.1: Nhay dia chi lon (0x00040000)");

        @(negedge clk);
        pc_next = 32'h7FFF_FFFC;
        @(posedge clk);
        check_pc(32'h7FFF_FFFC, "TC5.2: Nhay can tren (0x7FFFFFFC)");

        // Test 6: Kích hoạt reset giữa lúc đang thực thi
        @(negedge clk);
        rst     = 1;
        pc_next = 32'h0000_1234;
        @(posedge clk);
        check_pc(32'h0000_0000, "TC6: Reset uu tien tro ve 0 giua luc chay");

        // Test 7: Nhả reset sau khi bị ngắt
        @(negedge clk);
        rst     = 0;
        pc_next = 32'h0000_0020;
        @(posedge clk);
        check_pc(32'h0000_0020, "TC7: Phuc hoi sau reset ve 0x00000020");

        // Tổng kết
        $display("==================================================");
        $display("   TỔNG KẾT PC_TB: %0d PASSED, %0d FAILED         ", passed, failed);
        $display("==================================================");

        if (failed == 0)
            $display(">>> KẾT QUẢ: TOÀN BỘ BÀI TEST PC HOÀN THÀNH TỐT! <<<");
        else
            $display(">>> KẾT QUẢ: CÓ LỖI XẢY RA TRONG KIỂM THỬ PC! <<<");

        $finish;
    end

endmodule


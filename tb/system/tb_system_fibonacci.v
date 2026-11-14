`timescale 1ns/1ps

// ============================================================================
// Module: tb_system_fibonacci (Kiểm thử hệ thống - Dãy số Fibonacci trên cpu_top)
// Chức năng: Nạp mã máy programs/fibonacci.hex vào CPU và thực thi;
//            Kiểm tra 8 số Fibonacci được tính toán và lưu vào Data Memory (RAM)
// ============================================================================

module tb_system_fibonacci;

    reg clk = 0;
    reg rst = 1;
    wire [31:0] pc_out;
    wire [31:0] instr;

    integer cycles = 0;
    integer passed = 0;
    integer failed = 0;

    // Khởi tạo CPU Top V1
    cpu_top dut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instr(instr)
    );

    always #5 clk = ~clk;

    task check_val;
        input [31:0] actual;
        input [31:0] expected;
        input [8*60:1] desc;
        begin
            if (actual === expected) begin
                $display("[PASS] %0s = %0d (0x%h)", desc, actual, actual);
                passed = passed + 1;
            end else begin
                $display("[FAIL] %0s | Nhan: %0d (0x%h) | Ky vong: %0d (0x%h)", 
                         desc, actual, actual, expected, expected);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("simulation/tb_system_fibonacci.vcd");
        $dumpvars(0, tb_system_fibonacci);

        // Nạp chương trình vào Instruction Memory
        $readmemh("programs/fibonacci.hex", dut.u_imem.memory);

        $display("==================================================");
        $display("   SYSTEM TEST: CHUONG TRINH DAY SO FIBONACCI     ");
        $display("   File: programs/fibonacci.hex                   ");
        $display("==================================================");

        // Giữ reset 1 chu kỳ
        @(posedge clk);
        #1; rst = 1;
        @(posedge clk);
        #1; rst = 0;

        // Chạy cho đến khi chương trình dừng tại halt (PC = 0x4C) hoặc quá 100 chu kỳ
        while (pc_out !== 32'h0000004C && cycles < 100) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        // Thêm 2 chu kỳ để ổn định
        @(posedge clk);
        @(posedge clk);
        #1;

        $display("\n>>> CPU DA DUNG TAI PC = %h SAU %0d CHU KY CLOCK <<<\n", pc_out, cycles);

        $display("--- KIEM TRA MANG FIBONACCI TRONG RAM ---");
        check_val(dut.u_dmem.memory[0], 32'd0,  "RAM[0] (byte 0) ");
        check_val(dut.u_dmem.memory[1], 32'd1,  "RAM[1] (byte 4) ");
        check_val(dut.u_dmem.memory[2], 32'd1,  "RAM[2] (byte 8) ");
        check_val(dut.u_dmem.memory[3], 32'd2,  "RAM[3] (byte 12)");
        check_val(dut.u_dmem.memory[4], 32'd3,  "RAM[4] (byte 16)");
        check_val(dut.u_dmem.memory[5], 32'd5,  "RAM[5] (byte 20)");
        check_val(dut.u_dmem.memory[6], 32'd8,  "RAM[6] (byte 24)");
        check_val(dut.u_dmem.memory[7], 32'd13, "RAM[7] (byte 28)");

        $display("\n--- KIEM TRA DOC LAI BANG LENH LW ---");
        check_val(dut.u_rf.registers[8], 32'd13, "Thanh ghi x8 (doc tu RAM[28] qua LW)");

        $display("\n==================================================");
        $display("   TONG KET FIBONACCI: %0d PASSED, %0d FAILED", passed, failed);
        $display("==================================================");

        if (failed == 0)
            $display(">>> KET QUA: SYSTEM TEST FIBONACCI HOAN THANH XUAT SAC! <<<\n");
        else
            $display(">>> KET QUA: SYSTEM TEST FIBONACCI THAT BAI! <<<\n");

        $finish;
    end

    initial begin
        #5000;
        $display("\n[TIMEOUT] He thong chay qua thoi gian quy dinh!");
        $finish;
    end

endmodule


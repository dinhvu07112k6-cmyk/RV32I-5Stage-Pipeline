`timescale 1ns/1ps

// ============================================================================
// Module: tb_system_sum (Kiểm thử hệ thống - Thuật toán Tính tổng 1 đến N trên cpu_top)
// Chức năng: Nạp mã máy programs/sum_1_to_n.hex vào CPU và thực thi;
//            Kiểm tra vòng lặp liên tục, lệnh JAL/BEQ và lưu kết quả vào RAM[0]
// ============================================================================

module tb_system_sum;

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
        $dumpfile("simulation/tb_system_sum.vcd");
        $dumpvars(0, tb_system_sum);

        // Nạp chương trình vào Instruction Memory
        $readmemh("programs/sum_1_to_n.hex", dut.u_imem.memory);

        $display("==================================================");
        $display("   SYSTEM TEST: TINH TONG S = 1 + 2 + ... + 10    ");
        $display("   File: programs/sum_1_to_n.hex                  ");
        $display("==================================================");

        // Giữ reset 1 chu kỳ
        @(posedge clk);
        #1; rst = 1;
        @(posedge clk);
        #1; rst = 0;

        // Chạy cho đến khi chương trình dừng tại halt (PC = 0x24) hoặc quá 100 chu kỳ
        while (pc_out !== 32'h00000024 && cycles < 100) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        // Thêm 2 chu kỳ để hoàn tất
        @(posedge clk);
        @(posedge clk);
        #1;

        $display("\n>>> CPU DA DUNG TAI PC = %h SAU %0d CHU KY CLOCK <<<\n", pc_out, cycles);

        $display("--- KIEM TRA KET QUA TINH TOAN VA BO NHO ---");
        check_val(dut.u_rf.registers[3], 32'd55, "Thanh ghi x3 (Tong sum) ");
        check_val(dut.u_rf.registers[1], 32'd10, "Thanh ghi x1 (Bien dem i) ");
        check_val(dut.u_dmem.memory[0],  32'd55, "O nho RAM[0] (Luu bang SW)");

        $display("\n==================================================");
        $display("   TONG KET SYSTEM_SUM: %0d PASSED, %0d FAILED", passed, failed);
        $display("==================================================");

        if (failed == 0)
            $display(">>> KET QUA: SYSTEM TEST TINH TONG HOAN THANH XUAT SAC! <<<\n");
        else
            $display(">>> KET QUA: SYSTEM TEST TINH TONG THAT BAI! <<<\n");

        $finish;
    end

    initial begin
        #5000;
        $display("\n[TIMEOUT] He thong chay qua thoi gian quy dinh!");
        $finish;
    end

endmodule


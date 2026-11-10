`timescale 1ns/1ps

// Kiểm thử đọc lệnh, giá trị mặc định và địa chỉ không hợp lệ.
// Lệnh mẫu được gán trực tiếp trong testbench.
module tb_instruction_memory;

    // 1. Dùng chung địa chỉ cho bộ nhớ mặc định và bộ nhớ chứa lệnh mẫu.
    reg [31:0] addr;
    wire [31:0] instr;
    wire [31:0] default_instr;
    integer i;
    integer checks;

    instruction_memory #(
        .depth(4)
    ) dut (
        .addr(addr),
        .instr(instr)
    );

    instruction_memory default_dut (
        .addr(addr),
        .instr(default_instr)
    );

    // 2. Đổi địa chỉ và tự so sánh kết quả, không cần clock.
    task check_instruction;
        input [31:0] test_addr;
        input [31:0] expected;
        begin
            addr = test_addr;
            #1;
            if (instr !== expected)
                $fatal(1, "FAIL: addr=%h expected=%h actual=%h",
                       addr, expected, instr);
            checks = checks + 1;
        end
    endtask

    // 3. Chạy các trường hợp kiểm thử.
    initial begin
        $dumpfile("simulation/instruction_memory.vcd");
        $dumpvars(0, tb_instruction_memory);
        addr = 0;
        checks = 0;

        // Mọi ô của bộ nhớ mặc định đều chứa NOP.
        for (i = 0; i < 256; i = i + 1) begin
            addr = i * 4;
            #1;
            if (default_instr !== 32'h00000013)
                $fatal(1, "FAIL: default NOP at addr=%h", addr);
            checks = checks + 1;
        end

        // Gán lệnh mẫu sau khi module đã khởi tạo bộ nhớ.
        dut.memory[0] = 32'h00500093; // ADDI x1, x0, 5
        dut.memory[1] = 32'h00308113; // ADDI x2, x1, 3
        dut.memory[2] = 32'h002081b3; // ADD x3, x1, x2
        dut.memory[3] = 32'h00302023; // SW x3, 0(x0)

        // Đọc tuần tự, gồm cả ô đầu và ô cuối của bộ nhớ.
        check_instruction(0,  32'h00500093); // ADDI x1, x0, 5
        check_instruction(4,  32'h00308113); // ADDI x2, x1, 3
        check_instruction(8,  32'h002081b3); // ADD x3, x1, x2
        check_instruction(12, 32'h00302023); // SW x3, 0(x0)

        // Đọc lại địa chỉ cũ để kiểm tra truy cập không tuần tự.
        check_instruction(4, 32'h00308113);
        check_instruction(0, 32'h00500093);

        // Địa chỉ lệch hàng hoặc vượt dung lượng trả về NOP.
        check_instruction(1,            32'h00000013);
        check_instruction(2,            32'h00000013);
        check_instruction(3,            32'h00000013);
        check_instruction(16,           32'h00000013);
        check_instruction(32'h80000000, 32'h00000013);
        check_instruction(32'hfffffffc, 32'h00000013);

        $display("ALL TESTS PASSED: %0d checks", checks);
        $finish;
    end

endmodule

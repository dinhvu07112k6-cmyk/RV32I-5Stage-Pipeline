
`timescale 1ns/1ps

module tb_register_file;

    // 1. Khai báo tín hiệu kiểm thử
    reg clk, rst, reg_write;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] write_data;
    wire [31:0] read_data1, read_data2;

    // 2. Kết nối module cần kiểm thử
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

    // 3. Tạo clock chu kỳ 10 ns
    always #5 clk = ~clk;

    // 4. Chạy các trường hợp kiểm thử
    initial begin
        $dumpfile("simulation/register_file.vcd");
        $dumpvars(0, tb_register_file);

        clk = 0;
        rst = 1;
        reg_write = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        write_data = 0;

        // Test 1: Reset
        @(negedge clk);
        rst = 0;
        rs1 = 1;
        rs2 = 2;
        #1;
        if (read_data1 !== 0 || read_data2 !== 0)
            $fatal(1, "FAIL: Reset");
        $display("PASS: Reset");

        // Test 2: Ghi x1 = 100
        rd = 1;
        write_data = 100;
        reg_write = 1;
        @(negedge clk);
        reg_write = 0;
        rs1 = 1;
        #1;
        if (read_data1 !== 100)
            $fatal(1, "FAIL: Write x1");
        $display("PASS: Write x1");

        // Test 3: Không cho phép ghi x0
        rd = 0;
        write_data = 999;
        reg_write = 1;
        @(negedge clk);
        reg_write = 0;
        rs1 = 0;
        #1;
        if (read_data1 !== 0)
            $fatal(1, "FAIL: x0");
        $display("PASS: x0 protected");

        // Test 4: reg_write = 0
        rd = 1;
        write_data = 500;
        reg_write = 0;
        @(negedge clk);
        rs1 = 1;
        #1;
        if (read_data1 !== 100)
            $fatal(1, "FAIL: Write disabled");
        $display("PASS: Write disabled");

        // Test 5: Ghi đè x1 = 300
        rd = 1;
        write_data = 300;
        reg_write = 1;
        @(negedge clk);
        reg_write = 0;
        rs1 = 1;
        #1;
        if (read_data1 !== 300)
            $fatal(1, "FAIL: Overwrite");
        $display("PASS: Overwrite");

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule

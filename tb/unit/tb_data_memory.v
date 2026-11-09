`timescale 1ns/1ps

// Kiểm thử đọc/ghi, tín hiệu cho phép và địa chỉ không hợp lệ.
// Dữ liệu mẫu được tạo trực tiếp trong testbench.
module tb_data_memory;

    // 1. Khai báo tín hiệu và kết nối module cần kiểm thử.
    reg clk, mem_read, mem_write;
    reg [31:0] addr, write_data;
    wire [31:0] read_data;
    integer i;
    integer checks;

    data_memory dut (
        .clk(clk),
        .addr(addr),
        .write_data(write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(read_data)
    );

    // 2. Clock chu kỳ 10 ns và các thao tác kiểm thử.
    always #5 clk = ~clk;

    task check_data;
        input [31:0] expected;
        begin
            #1;
            if (read_data !== expected)
                $fatal(1, "FAIL: addr=%h expected=%h actual=%h",
                       addr, expected, read_data);
            checks = checks + 1;
        end
    endtask

    task read_word;
        input [31:0] test_addr;
        input [31:0] expected;
        begin
            addr = test_addr;
            mem_read = 1;
            check_data(expected);
        end
    endtask

    task write_word;
        input [31:0] test_addr;
        input [31:0] data;
        begin
            @(negedge clk);
            addr = test_addr;
            write_data = data;
            mem_write = 1;
            @(negedge clk);
            mem_write = 0;
        end
    endtask

    // 3. Chạy các trường hợp kiểm thử.
    initial begin
        $dumpfile("simulation/data_memory.vcd");
        $dumpvars(0, tb_data_memory);
        clk = 0;
        mem_read = 0;
        mem_write = 0;
        addr = 0;
        write_data = 0;
        checks = 0;

        // Mọi ô nhớ ban đầu bằng 0.
        for (i = 0; i < 256; i = i + 1)
            read_word(i * 4, 32'b0);

        // Ghi và đọc ô đầu, ô kế tiếp và ô cuối.
        write_word(0,    32'h12345678);
        write_word(4,    32'h89abcdef);
        write_word(1020, 32'hffffffff);
        read_word(0,    32'h12345678);
        read_word(4,    32'h89abcdef);
        read_word(1020, 32'hffffffff);
        read_word(8,    32'b0);

        // Tắt đọc thì đầu ra bằng 0, kể cả khi đang ghi.
        mem_read = 0;
        check_data(0);
        write_word(8, 32'h80000001);
        check_data(0);
        read_word(8, 32'h80000001);

        // Tắt ghi thì dữ liệu cũ được giữ lại qua cạnh lên.
        @(negedge clk);
        addr = 0;
        write_data = 32'hdeadbeef;
        @(posedge clk);
        check_data(32'h12345678);

        // Bật đọc và ghi: chỉ thấy dữ liệu mới sau cạnh lên.
        @(negedge clk);
        mem_write = 1;
        check_data(32'h12345678);
        @(posedge clk);
        check_data(32'hdeadbeef);
        @(negedge clk);
        mem_write = 0;
        read_word(0, 32'hdeadbeef);

        // Chặn địa chỉ lệch hàng và địa chỉ vượt dung lượng.
        write_word(1,            32'h11111111);
        write_word(2,            32'h22222222);
        write_word(3,            32'h33333333);
        write_word(1024,         32'h44444444);
        write_word(32'h80000000, 32'h55555555);
        write_word(32'hfffffffc, 32'h66666666);
        read_word(1,            0);
        read_word(2,            0);
        read_word(3,            0);
        read_word(1024,         0);
        read_word(32'h80000000, 0);
        read_word(32'hfffffffc, 0);

        // Ghi sai địa chỉ không làm thay đổi các ô hợp lệ.
        for (i = 0; i < 256; i = i + 1) begin
            case (i)
                0:       read_word(i * 4, 32'hdeadbeef);
                1:       read_word(i * 4, 32'h89abcdef);
                2:       read_word(i * 4, 32'h80000001);
                255:     read_word(i * 4, 32'hffffffff);
                default: read_word(i * 4, 32'b0);
            endcase
        end

        $display("ALL TESTS PASSED: %0d checks", checks);
        $finish;
    end

endmodule

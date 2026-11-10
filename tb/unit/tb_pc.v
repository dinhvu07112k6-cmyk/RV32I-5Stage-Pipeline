`timescale 1ns/1ps

module tb_pc;

    reg clk, rst;
    reg [31:0] pc_next;
    wire [31:0] pc_out;

    pc uut (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    // Clock chu ky 10ns
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        pc_next = 0;

        // Kiem tra reset
        @(posedge clk);
        #1;
        if (pc_out !== 0)
            $display("FAIL: Reset");
        else
            $display("PASS: Reset");

        // Kiem tra cap nhat PC
        @(negedge clk);
        rst = 0;
        pc_next = 32'd4;

        @(posedge clk);
        #1;
        if (pc_out !== 4)
            $display("FAIL: PC = 4");
        else
            $display("PASS: PC = 4");

        @(negedge clk);
        pc_next = 32'd8;

        @(posedge clk);
        #1;
        if (pc_out !== 8)
            $display("FAIL: PC = 8");
        else
            $display("PASS: PC = 8");

        $finish;
    end

endmodule

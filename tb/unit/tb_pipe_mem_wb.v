`timescale 1ns/1ps

module tb_pipe_mem_wb;
    reg clk = 0;
    reg rst = 1;
    reg valid_M = 1;
    reg reg_write_M = 1;
    reg [31:0] alu_result_M = 32'h12345678;
    reg [31:0] mem_data_M = 32'h89abcdef;
    reg [31:0] pc_plus4_M = 32'h00000040;
    reg [4:0] rd_M = 5'd17;
    reg [1:0] result_src_M = 2'b01;

    wire valid_W, reg_write_W;
    wire [31:0] alu_result_W, mem_data_W, pc_plus4_W;
    wire [4:0] rd_W;
    wire [1:0] result_src_W;

    pipe_mem_wb dut (
        .clk(clk), .rst(rst),
        .valid_M(valid_M), .reg_write_M(reg_write_M),
        .alu_result_M(alu_result_M), .mem_data_M(mem_data_M),
        .pc_plus4_M(pc_plus4_M), .rd_M(rd_M), .result_src_M(result_src_M),
        .valid_W(valid_W), .reg_write_W(reg_write_W),
        .alu_result_W(alu_result_W), .mem_data_W(mem_data_W),
        .pc_plus4_W(pc_plus4_W), .rd_W(rd_W), .result_src_W(result_src_W)
    );

    wire [104:0] outputs_W = {valid_W, reg_write_W, alu_result_W,
                              mem_data_W, pc_plus4_W, rd_W, result_src_W};
    wire [104:0] inputs_M = {valid_M, reg_write_M, alu_result_M,
                             mem_data_M, pc_plus4_M, rd_M, result_src_M};

    always #5 clk = ~clk;

    task check_outputs;
        input [104:0] expected;
        begin
            #1;
            if (outputs_W !== expected)
                $fatal(1, "MEM/WB at %0t: got %h, expected %h",
                       $time, outputs_W, expected);
        end
    endtask

    initial begin
        @(posedge clk);
        check_outputs(105'b0);

        @(negedge clk);
        rst = 0;
        check_outputs(105'b0);
        @(posedge clk);
        check_outputs(inputs_M);

        // An invalid slot still transfers its payload. WB gates writes with valid_W.
        @(negedge clk);
        valid_M = 0;
        alu_result_M = 32'hffffffff;
        mem_data_M = 32'h11223344;
        pc_plus4_M = 32'h00000084;
        rd_M = 5'd3;
        result_src_M = 2'b10;
        check_outputs({2'b11, 32'h12345678, 32'h89abcdef,
                       32'h00000040, 5'd17, 2'b01});
        @(posedge clk);
        check_outputs(inputs_M);

        @(negedge clk);
        rst = 1;
        check_outputs(inputs_M);
        @(posedge clk);
        check_outputs(105'b0);

        $display("PASS: pipe_mem_wb");
        $finish;
    end
endmodule

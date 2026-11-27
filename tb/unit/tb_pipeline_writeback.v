`timescale 1ns/1ps

module tb_pipeline_writeback;
    localparam [31:0] ALU_RESULT = 32'h11223344;
    localparam [31:0] LOAD_DATA  = 32'h89abcdef;
    localparam [31:0] LINK_ADDR  = 32'h00000024;

    reg rst, valid_W, reg_write_W;
    reg [4:0] rd_W;
    reg [1:0] result_src_W;
    wire [31:0] write_data_W;
    wire wb_write_en;

    pipeline_writeback dut (
        .rst(rst), .valid_W(valid_W), .reg_write_W(reg_write_W),
        .rd_W(rd_W), .result_src_W(result_src_W),
        .alu_result_W(ALU_RESULT), .mem_data_W(LOAD_DATA), .pc_plus4_W(LINK_ADDR),
        .write_data_W(write_data_W), .wb_write_en(wb_write_en)
    );

    task check_writeback;
        input [31:0] expected_data;
        input expected_enable;
        begin
            #1;
            if ({wb_write_en, write_data_W} !== {expected_enable, expected_data})
                $fatal(1, "WB at %0t: got en=%b data=%h, expected en=%b data=%h",
                       $time, wb_write_en, write_data_W, expected_enable, expected_data);
        end
    endtask

    initial begin
        rst = 0;
        valid_W = 1;
        reg_write_W = 1;
        rd_W = 5'd31;
        result_src_W = 2'b00;
        check_writeback(ALU_RESULT, 1'b1);
        result_src_W = 2'b01;
        check_writeback(LOAD_DATA, 1'b1);
        result_src_W = 2'b10;
        check_writeback(LINK_ADDR, 1'b1);
        result_src_W = 2'b11;
        check_writeback(32'b0, 1'b0);

        result_src_W = 2'b00;
        rst = 1;
        check_writeback(ALU_RESULT, 1'b0);
        rst = 0;
        valid_W = 0;
        check_writeback(ALU_RESULT, 1'b0);
        valid_W = 1;
        reg_write_W = 0;
        check_writeback(ALU_RESULT, 1'b0);
        reg_write_W = 1;
        rd_W = 5'd0;
        check_writeback(ALU_RESULT, 1'b0);
        rd_W = 5'd1;
        check_writeback(ALU_RESULT, 1'b1);

        $display("PASS: pipeline_writeback");
        $finish;
    end
endmodule

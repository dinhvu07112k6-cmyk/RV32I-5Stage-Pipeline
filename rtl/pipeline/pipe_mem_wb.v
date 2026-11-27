module pipe_mem_wb (
    input  wire        clk,
    input  wire        rst,
    input  wire        valid_M,
    input  wire        reg_write_M,
    input  wire [31:0] alu_result_M,
    input  wire [31:0] mem_data_M,
    input  wire [31:0] pc_plus4_M,
    input  wire [4:0]  rd_M,
    input  wire [1:0]  result_src_M,
    output reg         valid_W,
    output reg         reg_write_W,
    output reg  [31:0] alu_result_W,
    output reg  [31:0] mem_data_W,
    output reg  [31:0] pc_plus4_W,
    output reg  [4:0]  rd_W,
    output reg  [1:0]  result_src_W
);

    always @(posedge clk) begin
        if (rst) begin
            valid_W      <= 1'b0;
            reg_write_W  <= 1'b0;
            alu_result_W <= 32'b0;
            mem_data_W   <= 32'b0;
            pc_plus4_W   <= 32'b0;
            rd_W         <= 5'b0;
            result_src_W <= 2'b0;
        end else begin
            valid_W      <= valid_M;
            reg_write_W  <= reg_write_M;
            alu_result_W <= alu_result_M;
            mem_data_W   <= mem_data_M;
            pc_plus4_W   <= pc_plus4_M;
            rd_W         <= rd_M;
            result_src_W <= result_src_M;
        end
    end

endmodule

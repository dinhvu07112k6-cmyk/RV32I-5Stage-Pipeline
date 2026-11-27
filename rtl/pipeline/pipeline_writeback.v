module pipeline_writeback (
    input  wire        rst,
    input  wire        valid_W,
    input  wire        reg_write_W,
    input  wire [4:0]  rd_W,
    input  wire [1:0]  result_src_W,
    input  wire [31:0] alu_result_W,
    input  wire [31:0] mem_data_W,
    input  wire [31:0] pc_plus4_W,
    output reg  [31:0] write_data_W,
    output wire        wb_write_en
);

    always @(*) begin
        case (result_src_W)
            2'b00: write_data_W = alu_result_W;
            2'b01: write_data_W = mem_data_W;
            2'b10: write_data_W = pc_plus4_W;
            default: write_data_W = 32'b0;
        endcase
    end

    assign wb_write_en = !rst && valid_W && reg_write_W &&
                         (rd_W != 5'd0) && (result_src_W != 2'b11);

endmodule

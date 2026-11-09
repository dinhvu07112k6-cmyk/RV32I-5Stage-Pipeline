module pc (
    input wire clk,
    input wire rst,
    input wire [31:0] pc_next,
    output reg [31:0] pc_out
);

    // Reset dong bo, tich cuc muc cao
    // PC cap nhat tai canh len clock
    always @(posedge clk) begin
        if (rst)
            pc_out <= 32'd0;
        else
            pc_out <= pc_next;
    end

endmodule

// Chức năng: lưu trữ 32 thanh ghi 32 bit (x0-x31) cho CPU.
// - Đọc đồng thời 2 thanh ghi, không cần chờ clock.
// - Ghi 1 thanh ghi tại cạnh lên của clock khi reg_write = 1.
// - Khi rst = 1, xóa tất cả thanh ghi tại cạnh lên; reset ưu tiên hơn ghi.
// - Thanh ghi x0 luôn đọc ra 0 và không cho phép ghi.
module register_file (
    input  wire        clk,         // Xung clock
    input  wire        rst,         // Reset đồng bộ, tích cực mức 1
    input  wire [4:0]  rs1,         // Địa chỉ thanh ghi đọc 1
    input  wire [4:0]  rs2,         // Địa chỉ thanh ghi đọc 2
    input  wire [4:0]  rd,          // Địa chỉ thanh ghi ghi
    input  wire [31:0] write_data,  // Dữ liệu ghi
    input  wire        reg_write,   // Cho phép ghi khi bằng 1
    output wire [31:0] read_data1,  // Dữ liệu của thanh ghi rs1
    output wire [31:0] read_data2   // Dữ liệu của thanh ghi rs2
);

    // 1. Lưu trữ 32 thanh ghi, mỗi thanh ghi 32 bit.
    reg [31:0] registers [0:31];
    integer i;

    // 2. Đọc không cần clock; x0 luôn trả về 0.
    assign read_data1 = (rs1 == 5'd0) ? 32'b0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'b0 : registers[rs2];

    // 3. Reset hoặc ghi tại cạnh lên; ưu tiên reset, chặn ghi x0.
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end
        else if (reg_write && rd != 5'd0) begin
            registers[rd] <= write_data;
        end
    end

endmodule

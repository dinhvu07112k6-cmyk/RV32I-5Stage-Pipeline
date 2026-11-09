// Chức năng: lưu dữ liệu 32 bit cho các lệnh LW và SW, không dùng reset.
// - Mặc định có 256 ô nhớ, khởi tạo bằng 0; mỗi ô chiếm 4 byte.
// - Đọc tổ hợp khi mem_read = 1; ghi tại cạnh lên khi mem_write = 1.
// - Địa chỉ ngoài bộ nhớ hoặc không chia hết cho 4: đọc ra 0, bỏ qua ghi.
// - Khi mem_read = 0, read_data bằng 0.
module data_memory #(
    parameter integer depth = 256
) (
    input  wire        clk,         // Xung clock
    input  wire [31:0] addr,        // Địa chỉ byte từ ALU
    input  wire [31:0] write_data,  // Dữ liệu cần ghi
    input  wire        mem_read,    // Cho phép đọc
    input  wire        mem_write,   // Cho phép ghi
    output wire [31:0] read_data    // Dữ liệu đưa đến MEM/WB
);

    // 1. Khai báo và khởi tạo bộ nhớ.
    reg [31:0] memory [0:depth-1];
    integer i;

    initial begin
        for (i = 0; i < depth; i = i + 1)
            memory[i] = 32'b0;
    end

    // 2. Kiểm tra địa chỉ; addr[31:2] là chỉ số ô nhớ.
    wire valid_addr;
    assign valid_addr = (addr[1:0] == 2'b00) && (addr[31:2] < depth);

    // 3. Đọc không cần clock; tắt đọc thì trả về 0.
    assign read_data = (mem_read && valid_addr) ? memory[addr[31:2]] : 32'b0;

    // 4. Ghi tại cạnh lên; các ô khác giữ nguyên dữ liệu.
    always @(posedge clk) begin
        if (mem_write && valid_addr)
            memory[addr[31:2]] <= write_data;
    end

endmodule

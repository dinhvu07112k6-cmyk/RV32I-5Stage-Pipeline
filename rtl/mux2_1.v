// ============================================================================
// Module: MUX 2-to-1 32-bit
// Phụ trách: Trần Quốc Hùng
// Mô tả: Bộ chọn 1 trong 2 luồng dữ liệu 32-bit (dùng cho ALUSrc, MemtoReg)
// ============================================================================

module mux2_1 (
    input  [31:0] in0,   // Ngõ vào 0 (khi sel = 0)
    input  [31:0] in1,   // Ngõ vào 1 (khi sel = 1)
    input         sel,   // Tín hiệu điều khiển lựa chọn
    output [31:0] out    // Kết quả đầu ra
);

    assign out = sel ? in1 : in0;

endmodule
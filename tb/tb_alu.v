module tb_alu;
    reg  [3:0]  alu_ctrl;
    reg  [31:0] src_a, src_b;
    wire [31:0] alu_result;
    wire        zero;

    // Gắn kết module ALU
    alu uut (
        .alu_ctrl(alu_ctrl),
        .src_a(src_a),
        .src_b(src_b),
        .alu_result(alu_result),
        .zero(zero)
    );

    initial begin
        // Trích xuất dữ liệu dạng sóng để xem trên GTKWave
        $dumpfile("alu_wave.vcd");
        $dumpvars(0, tb_alu);

        // Trường hợp 1: Phép ADD (10 + 20 = 30)
        src_a = 32'd10; src_b = 32'd20; alu_ctrl = 4'b0000; #10;
        
        // Trường hợp 2: Phép SUB (15 - 15 = 0, cờ zero phải lên 1)
        src_a = 32'd15; src_b = 32'd15; alu_ctrl = 4'b0001; #10;
        
        $finish;
    end
endmodule
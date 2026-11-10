module tb_mux2_1;
    reg  [31:0] in0;
    reg  [31:0] in1;
    reg         sel;
    wire [31:0] out;

    // Gắn kết module mux2_1
    mux2_1 uut (
        .in0(in0),
        .in1(in1),
        .sel(sel),
        .out(out)
    );

    initial begin
        // Tạo file dữ liệu sóng cho GTKWave
        $dumpfile("mux_wave.vcd");
        $dumpvars(0, tb_mux2_1);

        // Khởi tạo hai luồng dữ liệu đầu vào
        in0 = 32'd100; // Nhánh 0 có giá trị 100
        in1 = 32'd250; // Nhánh 1 có giá trị 250
        
        // Trường hợp 1: Chọn nhánh 0 (Kỳ vọng out = 100)
        sel = 1'b0; 
        #10;

        // Trường hợp 2: Chọn nhánh 1 (Kỳ vọng out = 250)
        sel = 1'b1; 
        #10;

        $finish;
    end
endmodule

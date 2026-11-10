module tb_imm_generator;
    reg  [31:0] instr;
    wire [31:0] imm_ext;

    // Gắn kết module imm_generator
    imm_generator uut (
        .instr(instr),
        .imm_ext(imm_ext)
    );

    initial begin
        // Tạo file dữ liệu sóng cho GTKWave
        $dumpfile("imm_wave.vcd");
        $dumpvars(0, tb_imm_generator);

        // Trường hợp 1: Lệnh I-Type (ADDI) với số dương (Immediate = 20)
        // Cấu trúc: imm[11:0]=20, rs1, funct3, rd, opcode=0010011
        instr = 32'b000000010100_00010_000_00001_0010011; 
        #10;

        // Trường hợp 2: Lệnh I-Type (ADDI) với số âm (Immediate = -4)
        // Số -4 trong bù 2 (12-bit) là 111111111100
        instr = 32'b111111111100_00010_000_00001_0010011; 
        #10;

        // Trường hợp 3: Lệnh S-Type (SW) với Immediate = 16
        // Cấu trúc bị tách đôi: imm[11:5]=0, rs2, rs1, funct3, imm[4:0]=16, opcode=0100011
        instr = 32'b0000000_00011_00010_010_10000_0100011; 
        #10;

        $finish;
    end
endmodule

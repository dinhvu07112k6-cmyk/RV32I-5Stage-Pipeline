// CPU V1: single-cycle datapath using the existing module interfaces.
module cpu_top(input wire clk, input wire rst,
               output wire [31:0] pc_out, output wire [31:0] instr);
    wire [31:0] pc_next, pc_plus4, pc_target, imm_ext;
    wire [31:0] read_data1, read_data2, src_b, alu_result, mem_data;
    wire [31:0] alu_or_mem, write_data;
    wire reg_write, alu_src, mem_read, mem_write, branch, jump, zero;
    wire [3:0] alu_ctrl;
    wire [1:0] result_src;
    assign pc_plus4 = pc_out + 32'd4;
    assign pc_target = pc_out + imm_ext;
    pc u_pc(.clk(clk), .rst(rst), .pc_next(pc_next), .pc_out(pc_out));
    instruction_memory u_imem(.addr(pc_out), .instr(instr));
    control_unit u_control(.opcode(instr[6:0]), .funct3(instr[14:12]),
        .funct7(instr[31:25]), .reg_write(reg_write), .alu_src(alu_src),
        .alu_ctrl(alu_ctrl), .mem_read(mem_read), .mem_write(mem_write),
        .result_src(result_src), .branch(branch), .jump(jump));
    register_file u_rf(.clk(clk), .rst(rst), .rs1(instr[19:15]),
        .rs2(instr[24:20]), .rd(instr[11:7]), .write_data(write_data),
        .reg_write(reg_write), .read_data1(read_data1), .read_data2(read_data2));
    imm_generator u_imm(.instr(instr), .imm_ext(imm_ext));
    mux2_1 u_alu_mux(.in0(read_data2), .in1(imm_ext), .sel(alu_src), .out(src_b));
    alu u_alu(.alu_ctrl(alu_ctrl), .src_a(read_data1), .src_b(src_b),
        .alu_result(alu_result), .zero(zero));
    // Data memory has no reset: suppress stores while CPU reset is asserted.
    data_memory u_dmem(.clk(clk), .addr(alu_result), .write_data(read_data2),
        .mem_read(mem_read), .mem_write(mem_write && !rst), .read_data(mem_data));
    mux2_1 u_mem_mux(.in0(alu_result), .in1(mem_data),
        .sel(result_src[0]), .out(alu_or_mem));
    mux2_1 u_link_mux(.in0(alu_or_mem), .in1(pc_plus4),
        .sel(result_src[1]), .out(write_data));
    mux2_1 u_pc_mux(.in0(pc_plus4), .in1(pc_target),
        .sel(jump || (branch && zero)), .out(pc_next));
endmodule

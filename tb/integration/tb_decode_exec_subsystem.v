`timescale 1ns/1ps

// ===========================================================================
// Testbench: tb_decode_exec_subsystem.v
// Purpose: Verify integration of Control Unit, Register File, Immediate Generator,
//          MUX (ALU src) and ALU (Decode & Execute stage).
// TC1‑TC8 correspond to the table in the LaTeX report (Section 2.2).
// ===========================================================================

module tb_decode_exec_subsystem;

    // ---------------------------------------------------------------------
    // 1. Signals
    // ---------------------------------------------------------------------
    reg         clk;
    reg         rst;
    reg  [31:0] instr;
    reg         wb_en;   // forced write‑back from testbench
    reg  [4:0]  wb_rd;   // destination register for forced write‑back
    reg  [31:0] wb_data; // data to write back when wb_en = 1

    // Control‑unit outputs
    wire        reg_write;
    wire        alu_src;
    wire [3:0]  alu_ctrl;
    wire        mem_read;
    wire        mem_write;
    wire [1:0]  result_src;
    wire        branch;
    wire        jump;

    // Datapath signals
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] imm_ext;
    wire [31:0] src_b;
    wire [31:0] alu_result;
    wire        zero;
    wire        branch_taken;

    integer passed = 0;
    integer failed = 0;

    // ---------------------------------------------------------------------
    // 2. Branch condition (branch && zero)
    // ---------------------------------------------------------------------
    assign branch_taken = branch & zero;

    // ---------------------------------------------------------------------
    // 3. Control Unit (driven directly by instr)
    // ---------------------------------------------------------------------
    control_unit u_cu (
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7(instr[31:25]),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_ctrl(alu_ctrl),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .result_src(result_src),
        .branch(branch),
        .jump(jump)
    );

    // ---------------------------------------------------------------------
    // 4. Register File – write enable can come from testbench (wb_en) or CU
    // ---------------------------------------------------------------------
    wire write_enable_rf = wb_en | reg_write;
    wire [4:0] rd_rf     = wb_en ? wb_rd : instr[11:7];
    wire [31:0] wdata_rf = wb_en ? wb_data : alu_result;

    register_file u_rf (
        .clk(clk),
        .rst(rst),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(rd_rf),
        .write_data(wdata_rf),
        .reg_write(write_enable_rf),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ---------------------------------------------------------------------
    // 5. Immediate Generator
    // ---------------------------------------------------------------------
    imm_generator u_imm (
        .instr(instr),
        .imm_ext(imm_ext)
    );

    // ---------------------------------------------------------------------
    // 6. MUX for ALU operand B
    // ---------------------------------------------------------------------
    mux2_1 u_mux_alu (
        .in0(read_data2),
        .in1(imm_ext),
        .sel(alu_src),
        .out(src_b)
    );

    // ---------------------------------------------------------------------
    // 7. ALU
    // ---------------------------------------------------------------------
    alu u_alu (
        .alu_ctrl(alu_ctrl),
        .src_a(read_data1),
        .src_b(src_b),
        .alu_result(alu_result),
        .zero(zero)
    );

    // ---------------------------------------------------------------------
    // 8. Clock generator (10ns period)
    // ---------------------------------------------------------------------
    always #5 clk = ~clk;

    // ---------------------------------------------------------------------
    // 9. Task: check_exec – verify ALU result, Zero flag and BranchTaken
    // ---------------------------------------------------------------------
    task check_exec;
        input [31:0] exp_alu;
        input        exp_zero;
        input        exp_br_taken;
        input [8*50:1] step_name;
        begin
            #2; // allow combinational propagation
            if (alu_result === exp_alu && zero === exp_zero && branch_taken === exp_br_taken) begin
                $display("[PASS] %0s | ALU=%0d (%h), Zero=%b, BrTaken=%b",
                         step_name, $signed(alu_result), alu_result, zero, branch_taken);
                passed = passed + 1;
            end else begin
                $display("[FAIL] %0s | Got ALU=%h Zero=%b BrTaken=%b | Exp ALU=%h Zero=%b BrTaken=%b",
                         step_name, alu_result, zero, branch_taken, exp_alu, exp_zero, exp_br_taken);
                failed = failed + 1;
            end
        end
    endtask

    // ---------------------------------------------------------------------
    // 10. Stimulus – sequence of test cases matching the LaTeX table
    // ---------------------------------------------------------------------
    initial begin
        $dumpfile("simulation/tb_decode_exec_subsystem.vcd");
        $dumpvars(0, tb_decode_exec_subsystem);

        clk       = 0;
        rst       = 1;
        instr     = 0;
        wb_en     = 0;
        wb_rd     = 0;
        wb_data   = 0;

        $display("==================================================");
        $display("   INTEGRATION TEST: DECODE & EXECUTE SUBSYSTEM");
        $display("==================================================");

        // ---------------------------------------------------------------
        // TC1 – R‑type ADD (x1 + x2 = 30 + 12 = 42)
        // ---------------------------------------------------------------
        @(posedge clk);
        #1; rst = 0;
        // Load registers with initial values via forced write‑back
        wb_en   = 1; wb_rd = 5'd1; wb_data = 32'd30; // x1 = 30
        @(posedge clk); wb_en = 1; wb_rd = 5'd2; wb_data = 32'd12; // x2 = 12
        wb_en = 0; // release forced write‑back
        // ADD instruction: opcode=0110011, funct3=000, funct7=0000000, rd=3, rs1=1, rs2=2
        instr = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
        check_exec(32'd42, 1'b0, 1'b0, "TC1: R‑type ADD (x1 + x2 = 30 + 12 = 42)");

        // ---------------------------------------------------------------
        // TC2 – I‑type ADDI (x3 + (-15) = 42 - 15 = 27)
        // ---------------------------------------------------------------
        // x3 currently holds result of previous ADD (42)
        // imm = -15 -> 12'hFF1
        instr = {12'hFF1, 5'd3, 3'b000, 5'd4, 7'b0010011}; // addi x4, x3, -15
        check_exec(32'd27, 1'b0, 1'b0, "TC2: I‑type ADDI (x3 + (-15) = 42 - 15 = 27)");

        // ---------------------------------------------------------------
        // TC3 – R‑type SUB (30 - 12 = 18)
        // ---------------------------------------------------------------
        instr = {7'b0100000, 5'd2, 5'd1, 3'b000, 5'd5, 7'b0110011}; // sub x5, x1, x2
        check_exec(32'd18, 1'b0, 1'b0, "TC3: R‑type SUB (30 - 12 = 18)");

        // ---------------------------------------------------------------
        // TC4 – R‑type AND (30 & 12 = 12)
        // ---------------------------------------------------------------
        instr = {7'b0000000, 5'd2, 5'd1, 3'b111, 5'd6, 7'b0110011}; // and x6, x1, x2 (funct3=111 for ANDI? actually AND uses 111)
        check_exec(32'd12, 1'b0, 1'b0, "TC4: R‑type AND (30 & 12 = 12)");

        // ---------------------------------------------------------------
        // TC5 – I‑type SLTI (30 < -5) → 0, Zero flag set
        // ---------------------------------------------------------------
        // imm = -5 -> 12'hFFB
        instr = {12'hFFB, 5'd1, 3'b010, 5'd7, 7'b0010011}; // slti x7, x1, -5
        check_exec(32'd0, 1'b1, 1'b0, "TC5: I‑type SLTI (30 < -5) → 0, Zero=1");

        // ---------------------------------------------------------------
        // TC6 – BEQ not taken (x1 != x2)
        // ---------------------------------------------------------------
        // rs1=x1 (30), rs2=x2 (12), offset=8 (0x8)
        instr = {1'b0, 6'b000000, 5'd2, 5'd1, 3'b000, 4'b0100, 1'b0, 7'b1100011};
        check_exec(32'd18, 1'b0, 1'b0, "TC6: BEQ not taken – Zero=0, BranchTaken=0");

        // ---------------------------------------------------------------
        // TC7 – BEQ taken (x1 == x1)
        // ---------------------------------------------------------------
        instr = {1'b0, 6'b000000, 5'd1, 5'd1, 3'b000, 4'b0100, 1'b0, 7'b1100011};
        check_exec(32'd0, 1'b1, 1'b1, "TC7: BEQ taken – Zero=1, BranchTaken=1");

        // ---------------------------------------------------------------
        // TC8 – Attempt to write to x0 (should remain 0)
        // ---------------------------------------------------------------
        instr = {12'd10, 5'd1, 3'b000, 5'd0, 7'b0010011}; // addi x0, x1, 10
        @(posedge clk);
        #1; // wait a cycle for write‑back
        // Read x0 via a dummy ADD instruction (adds x0 + x0 → result 0)
        instr = {7'b0000000, 5'd0, 5'd0, 3'b000, 5'd8, 7'b0110011}; // add x8, x0, x0
        check_exec(32'd0, 1'b1, 1'b0, "TC8: Write to x0 ignored – x0 stays 0");

        // ---------------------------------------------------------------
        // Summary
        // ---------------------------------------------------------------
        $display("\n==================================================");
        $display("   DECODE & EXECUTE RESULT: %0d PASSED, %0d FAILED", passed, failed);
        $display("==================================================");
        if (failed == 0)
            $display(">>> RESULT: DECODE & EXECUTE PASSED <<<");
        else
            $display(">>> RESULT: DECODE & EXECUTE FAILED <<<");
        $finish;
    end

endmodule

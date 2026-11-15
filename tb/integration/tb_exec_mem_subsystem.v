`timescale 1ns/1ps

// ===========================================================================
// Testbench: tb_exec_mem_subsystem.v
// Purpose: Verify integration of ALU (address calculation), Data Memory and
//          Write‑back MUX (Execute & Memory Access stage).
// TC1‑TC4 correspond to the table in the LaTeX report (Section 2.3).
// ===========================================================================

module tb_exec_mem_subsystem;

    // ---------------------------------------------------------------------
    // 1. Signals
    // ---------------------------------------------------------------------
    reg         clk;
    reg  [6:0]  opcode;
    reg  [2:0]  funct3;
    reg  [6:0]  funct7;
    reg  [31:0] reg_data1;   // Base address (rs1)
    reg  [31:0] imm_val;     // Immediate (offset)
    reg  [31:0] reg_data2;   // Data to store (rs2)

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
    wire [31:0] alu_result;
    wire        zero;
    wire [31:0] mem_read_data;
    wire [31:0] wb_result;

    integer passed = 0;
    integer failed = 0;

    // ---------------------------------------------------------------------
    // 2. Control Unit (driven directly by opcode/funct3/funct7)
    // ---------------------------------------------------------------------
    control_unit u_cu (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
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
    // 3. ALU – computes Effective Address (Base + Offset)
    // ---------------------------------------------------------------------
    alu u_alu (
        .alu_ctrl(alu_ctrl),
        .src_a(reg_data1),
        .src_b(imm_val),
        .alu_result(alu_result),
        .zero(zero)
    );

    // ---------------------------------------------------------------------
    // 4. Data Memory
    // ---------------------------------------------------------------------
    data_memory #(.depth(256)) u_dmem (
        .clk(clk),
        .addr(alu_result),
        .write_data(reg_data2),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(mem_read_data)
    );

    // ---------------------------------------------------------------------
    // 5. Write‑back MUX (result_src[0] selects ALU or Memory data)
    // ---------------------------------------------------------------------
    mux2_1 u_mux_wb (
        .in0(alu_result),
        .in1(mem_read_data),
        .sel(result_src[0]),
        .out(wb_result)
    );

    // ---------------------------------------------------------------------
    // 6. Clock generator (10ns period)
    // ---------------------------------------------------------------------
    always #5 clk = ~clk;

    // ---------------------------------------------------------------------
    // 7. Task: check_mem_op – verify Effective Address and WB result
    // ---------------------------------------------------------------------
    task check_mem_op;
        input [31:0] exp_addr;
        input [31:0] exp_wb_data;
        input [8*60:1] step_name;
        begin
            #1; // allow combinational delay
            if (alu_result === exp_addr && wb_result === exp_wb_data) begin
                $display("[PASS] %0s | EA=%h, WB_Result=%h", step_name, alu_result, wb_result);
                passed = passed + 1;
            end else begin
                $display("[FAIL] %0s | Got EA=%h WB=%h | Exp EA=%h Exp WB=%h",
                         step_name, alu_result, wb_result, exp_addr, exp_wb_data);
                failed = failed + 1;
            end
        end
    endtask

    // ---------------------------------------------------------------------
    // 8. Stimulus – sequence of test cases matching the LaTeX table
    // ---------------------------------------------------------------------
    initial begin
        $dumpfile("simulation/tb_exec_mem_subsystem.vcd");
        $dumpvars(0, tb_exec_mem_subsystem);

        clk       = 0;
        opcode    = 0;
        funct3    = 0;
        funct7    = 0;
        reg_data1 = 0;
        imm_val   = 0;
        reg_data2 = 0;

        $display("==================================================");
        $display("   INTEGRATION TEST: EXECUTE & MEMORY SUBSYSTEM");
        $display("==================================================");

        // ---------------------------------------------------------------
        // TC1 – Store Word (SW) – compute EA = 0x40 + 0x10 = 0x50
        // ---------------------------------------------------------------
        @(posedge clk);
        opcode    = 7'b0100011; // SW
        funct3    = 3'b010;      // width = word
        reg_data1 = 32'h0000_0040; // Base = 0x40
        imm_val   = 32'd16;        // Offset = 0x10
        reg_data2 = 32'hCAFE_BABE; // Data to store
        @(posedge clk);
        #1;
        check_mem_op(32'h0000_0050, 32'h0000_0050, "TC1: SW – EA=0x50, WB reflects EA (store) ");

        // ---------------------------------------------------------------
        // TC2 – Load Word (LW) – same EA, WB should return memory data
        // ---------------------------------------------------------------
        @(negedge clk);
        opcode    = 7'b0000011; // LW
        funct3    = 3'b010;      // word
        reg_data1 = 32'h0000_0040; // Base unchanged
        imm_val   = 32'd16;        // Offset unchanged
        @(posedge clk);
        #2;
        check_mem_op(32'h0000_0050, 32'hCAFE_BABE, "TC2: LW – EA=0x50, WB reads 0xCAFEBABE");

        // ---------------------------------------------------------------
        // TC3 – R‑type ADD (no memory access) – ensure mem signals are zero
        // ---------------------------------------------------------------
        @(negedge clk);
        opcode    = 7'b0110011; // R‑type ADD
        funct3    = 3'b000;
        funct7    = 7'b0000000;
        reg_data1 = 32'd100; // a
        imm_val   = 32'd50;  // b (used as second operand via ALU src)
        // Since alu_src will be 0 for R‑type, we force src_b via read_data2
        // For simplicity we let imm_val be ignored; set alu_src=0 automatically.
        @(posedge clk);
        #2;
        if (mem_read == 0 && mem_write == 0) begin
            $display("[PASS] TC3.1: R‑type ALU – mem_read=0, mem_write=0");
            passed = passed + 1;
        end else begin
            $display("[FAIL] TC3.1: R‑type ALU – mem_read=%b mem_write=%b", mem_read, mem_write);
            failed = failed + 1;
        end
        // WB result should be direct ALU output (150)
        check_mem_op(32'd150, 32'd150, "TC3.2: R‑type WB takes ALU result 150");

        // ---------------------------------------------------------------
        // TC4 – Unaligned address (EA not word‑aligned) – must be ignored
        // ---------------------------------------------------------------
        @(negedge clk);
        opcode    = 7'b0100011; // SW again
        funct3    = 3'b010;
        reg_data1 = 32'h0000_0040; // Base = 0x40
        imm_val   = 32'd3;        // Offset makes EA = 0x43 (unaligned)
        reg_data2 = 32'hBAD0_0001;
        @(posedge clk);
        #1;
        // After the mis‑aligned store, read back the aligned word at 0x40
        @(negedge clk);
        opcode    = 7'b0000011; // LW
        funct3    = 3'b010;
        reg_data1 = 32'h0000_0040;
        imm_val   = 32'd0;
        @(posedge clk);
        #2;
        check_mem_op(32'h0000_0040, 32'd0, "TC4: Unaligned EA=0x43 – RAM unchanged, WB=0");

        // ---------------------------------------------------------------
        // Summary
        // ---------------------------------------------------------------
        $display("\n==================================================");
        $display("   EXECUTE & MEMORY RESULT: %0d PASSED, %0d FAILED", passed, failed);
        $display("==================================================");
        if (failed == 0)
            $display(">>> RESULT: EXECUTE & MEMORY PASSED <<<");
        else
            $display(">>> RESULT: EXECUTE & MEMORY FAILED <<<");
        $finish;
    end

endmodule

`timescale 1ns/1ps

// ===========================================================================
// Testbench: tb_fetch_subsystem.v
// Purpose: Verify integration of PC and Instruction Memory (Fetch Stage).
// TC1 – TC6 correspond to the table in the LaTeX report (Section 2.1).
// ===========================================================================

module tb_fetch_subsystem;

    // ---------------------------------------------------------------------
    // 1. Signals
    // ---------------------------------------------------------------------
    reg         clk;
    reg         rst;
    reg         pc_src;           // 0: PC+4 (sequential), 1: PC target (branch/jump)
    reg  [31:0] pc_target;        // Target address for branch/jump
    
    wire [31:0] pc_out;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_next;
    wire [31:0] instr;
    
    integer passed = 0;
    integer failed = 0;
    
    // ---------------------------------------------------------------------
    // 2. Glue logic for PC
    // ---------------------------------------------------------------------
    assign pc_plus_4 = pc_out + 32'd4;
    assign pc_next   = pc_src ? pc_target : pc_plus_4;
    
    pc u_pc (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );
    
    // ---------------------------------------------------------------------
    // 3. Instruction Memory (depth 256 words)
    // ---------------------------------------------------------------------
    instruction_memory #(.depth(256)) u_imem (
        .addr(pc_out),
        .instr(instr)
    );
    
    // ---------------------------------------------------------------------
    // 4. Clock generation (10ns period)
    // ---------------------------------------------------------------------
    always #5 clk = ~clk;
    
    // ---------------------------------------------------------------------
    // 5. Task: check_fetch – compare PC and fetched instruction
    // ---------------------------------------------------------------------
    task check_fetch;
        input [31:0] exp_pc;
        input [31:0] exp_instr;
        input [8*50:1] step_name;
        begin
            #1; // allow signals to settle after clock edge
            if (pc_out === exp_pc && instr === exp_instr) begin
                $display("[PASS] %0s | PC = %h, Instr = %h", step_name, pc_out, instr);
                passed = passed + 1;
            end else begin
                $display("[FAIL] %0s | Got PC=%h Instr=%h | Expected PC=%h Instr=%h",
                         step_name, pc_out, instr, exp_pc, exp_instr);
                failed = failed + 1;
            end
        end
    endtask
    
    // ---------------------------------------------------------------------
    // 6. Stimulus
    // ---------------------------------------------------------------------
    initial begin
        $dumpfile("simulation/tb_fetch_subsystem.vcd");
        $dumpvars(0, tb_fetch_subsystem);

        clk       = 0;
        rst       = 1;
        pc_src    = 0;
        pc_target = 0;

        // Load a few sample instructions directly into IMEM (same as original file)
        u_imem.memory[0] = 32'h00500093; // addi x1, x0, 5
        u_imem.memory[1] = 32'h00A00113; // addi x2, x0, 10
        u_imem.memory[2] = 32'h002081B3; // add  x3, x1, x2
        u_imem.memory[3] = 32'h40110233; // sub  x4, x2, x1
        u_imem.memory[8] = 32'h003102B3; // add  x5, x2, x3 (target after branch)

        $display("==================================================");
        $display("   INTEGRATION TEST: FETCH SUBSYSTEM");
        $display("==================================================");

        // -----------------------------------------------------------------
        // TC1 – Reset system
        // -----------------------------------------------------------------
        @(posedge clk);
        check_fetch(32'h0000_0000, 32'h00500093, "TC1: Reset – fetch at 0x00");

        // -----------------------------------------------------------------
        // TC2 – Sequential PC+4 (address 0x04)
        // -----------------------------------------------------------------
        @(negedge clk);
        rst = 0; // release reset
        @(posedge clk);
        check_fetch(32'h0000_0004, 32'h00A00113, "TC2: PC+4 – fetch at 0x04");

        // -----------------------------------------------------------------
        // TC3 – PC+4 (address 0x08)
        // -----------------------------------------------------------------
        @(posedge clk);
        check_fetch(32'h0000_0008, 32'h002081B3, "TC3: PC+4 – fetch at 0x08");

        // -----------------------------------------------------------------
        // TC4 – PC+4 (address 0x0C)
        // -----------------------------------------------------------------
        @(posedge clk);
        check_fetch(32'h0000_000C, 32'h40110233, "TC4: PC+4 – fetch at 0x0C");

        // -----------------------------------------------------------------
        // TC5 – Branch/Jump redirect to 0x20
        // -----------------------------------------------------------------
        @(negedge clk);
        pc_src    = 1;                // enable branch/jump
        pc_target = 32'h0000_0020;    // target address
        @(posedge clk);
        check_fetch(32'h0000_0020, 32'h003102B3, "TC5: Jump – fetch at 0x20");

        // -----------------------------------------------------------------
        // TC6 – Return to sequential flow (PC+4) after jump
        // -----------------------------------------------------------------
        @(negedge clk);
        pc_src = 0; // disable jump
        @(posedge clk);
        check_fetch(32'h0000_0024, 32'h0000_0013, "TC6: Back to sequential – NOP at 0x24");

        // -----------------------------------------------------------------
        // Summary
        // -----------------------------------------------------------------
        $display("\n==================================================");
        $display("   FETCH SUBSYSTEM RESULT: %0d PASSED, %0d FAILED", passed, failed);
        $display("==================================================");
        if (failed == 0)
            $display(">>> RESULT: FETCH SUBSYSTEM PASSED <<<");
        else
            $display(">>> RESULT: FETCH SUBSYSTEM FAILED <<<");
        $finish;
    end

endmodule

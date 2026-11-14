`timescale 1ns/1ps
module tb_cpu_top;
    reg clk=0, rst=1;
    wire [31:0] pc_out, instr;
    integer passed=0, i;
    cpu_top dut(.clk(clk), .rst(rst), .pc_out(pc_out), .instr(instr));
    always #5 clk=~clk;
    task check;
        input [31:0] actual, expected;
        input [255:0] label;
        begin
            if(actual !== expected) begin
                $display("FAIL %s actual=%h expected=%h",label,actual,expected);
                $fatal(1,"CPU integration failed");
            end
            passed=passed+1;
        end
    endtask
    task step;
        input [31:0] expected_pc;
        begin @(posedge clk); #1; check(pc_out,expected_pc,"PC"); end
    endtask
    task regcheck;
        input integer r;
        input [31:0] value;
        begin check(dut.u_rf.registers[r],value,"register"); end
    endtask
    initial begin
        $dumpfile("simulation/cpu_top_v1.vcd");
        $dumpvars(0,tb_cpu_top);
        #1;
        $readmemh("programs/cpu_v1.hex",dut.u_imem.memory,0,31);
        step(0);
        @(negedge clk); rst=0;
        step(4); regcheck(1,10);
        step(8); regcheck(2,32'hfffffffd);
        step(12); regcheck(3,7);
        step(16); regcheck(4,13);
        step(20); regcheck(5,8);
        step(24); regcheck(6,32'hffffffff);
        step(28); regcheck(7,32'hfffffff7);
        step(32); regcheck(8,1);
        step(36); regcheck(9,20);
        step(40); regcheck(10,10);
        step(44); regcheck(11,13);
        step(48); regcheck(12,32'hfffffffd);
        step(52); regcheck(13,1);
        step(56); check(dut.u_dmem.memory[1],7,"SW data");
        step(60); regcheck(14,7);
        step(64); // BEQ not taken
        step(72); // BEQ taken, skip x15 write
        regcheck(15,0);
        step(80); regcheck(16,76); // JAL link, skip x17
        regcheck(17,0);
        step(84); regcheck(0,0); // attempted write x0
        step(88); regcheck(18,2);
        step(92); regcheck(18,1);
        step(96); // branch not taken
        step(88); // JAL backwards, rd=x0
        step(92); regcheck(18,0);
        step(100); // BEQ forward taken
        step(104); regcheck(19,16);
        step(108); check(dut.u_dmem.memory[3],32'hfffffffd,"negative SW offset");
        step(112); regcheck(20,32'hfffffffd);
        step(116); regcheck(21,2);
        step(120); regcheck(21,1);
        step(124); // backwards BEQ not taken
        step(116); // backwards JAL
        step(120); regcheck(21,0);
        step(116); // backwards BEQ taken
        // Reset during a pending store: no asynchronous PC/RF change,
        // then synchronous clearing, memory retention and suppressed store.
        @(negedge clk);
        dut.u_imem.memory[29]=32'h00102023; // sw x1,0(x0)
        #1; rst=1;
        #1; check(pc_out,116,"synchronous reset PC");
        regcheck(1,10);
        step(0);
        for(i=0;i<32;i=i+1) regcheck(i,0);
        check(dut.u_dmem.memory[0],0,"reset suppresses store");
        check(dut.u_dmem.memory[1],7,"reset preserves memory");
        @(negedge clk); rst=0;
        step(4); regcheck(1,10);
        $display("CPU V1 PASS=%0d FAIL=0",passed);
        $finish;
    end
    initial begin #2000; $fatal(1,"timeout"); end
endmodule





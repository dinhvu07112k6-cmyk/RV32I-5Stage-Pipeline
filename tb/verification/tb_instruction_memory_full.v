`timescale 1ns/1ps

module tb_instruction_memory_full;

    reg  [31:0] addr;
    wire [31:0] instr;

    localparam [31:0] NOP = 32'h0000_0013; // addi x0, x0, 0
    localparam integer DEPTH = 256;

    integer passed = 0;
    integer failed = 0;
    integer i;

    // DUT với depth mặc định 256
    instruction_memory #(.depth(DEPTH)) dut (
        .addr(addr),
        .instr(instr)
    );

    task check_instr;
        input [31:0] expected;
        input [8*50:1] test_name;
        begin
            #1; // Đợi lan truyền tổ hợp
            if (instr === expected) begin
                $display("[PASS] %0s | addr=%h -> instr=%h", test_name, addr, instr);
                passed = passed + 1;
            end else begin
                $display("[FAIL] %0s | addr=%h -> Nhận: %h, Kỳ vọng: %h", 
                         test_name, addr, instr, expected);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("simulation/tb_instruction_memory_full.vcd");
        $dumpvars(0, tb_instruction_memory_full);

        addr = 0;

        $display("==================================================");
        $display("   BẮT ĐẦU KIỂM THỬ CHUYÊN SÂU: INSTRUCTION MEM   ");
        $display("==================================================");

        // --------------------------------------------------------------------
        // 1. KIỂM THỬ KHỞI TẠO MẶC ĐỊNH (TẤT CẢ Ô NHỚ LÀ NOP)
        // --------------------------------------------------------------------
        $display("\n--- 1. KIỂM THỬ KHỞI TẠO MẶC ĐỊNH (NOP) ---");
        addr = 32'd0;
        check_instr(NOP, "Khoi tao tai dia chi 0 la NOP");

        addr = 32'd4;
        check_instr(NOP, "Khoi tao tai dia chi 4 la NOP");

        addr = 32'd100;
        check_instr(NOP, "Khoi tao tai dia chi 100 la NOP");

        // --------------------------------------------------------------------
        // 2. NẠP MÃ LỆNH VÀ ĐỌC TUẦN TỰ (ALIGNED ADDRESSES: chia hết cho 4)
        // --------------------------------------------------------------------
        $display("\n--- 2. NẠP MÃ LỆNH VÀ ĐỌC TUẦN TỰ ---");
        dut.memory[0] = 32'h00500093; // addi x1, x0, 5
        dut.memory[1] = 32'h00A00113; // addi x2, x0, 10
        dut.memory[2] = 32'h002081B3; // add  x3, x1, x2
        dut.memory[3] = 32'h40110233; // sub  x4, x2, x1

        addr = 32'd0;  check_instr(32'h00500093, "Doc lenh 0 (addr=0)");
        addr = 32'd4;  check_instr(32'h00A00113, "Doc lenh 1 (addr=4)");
        addr = 32'd8;  check_instr(32'h002081B3, "Doc lenh 2 (addr=8)");
        addr = 32'd12; check_instr(32'h40110233, "Doc lenh 3 (addr=12)");

        // --------------------------------------------------------------------
        // 3. KIỂM THỬ ĐỊA CHỈ BIÊN (BOUNDARY CONDITIONS)
        // --------------------------------------------------------------------
        $display("\n--- 3. KIỂM THỬ ĐỊA CHỈ BIÊN (BOUNDARY) ---");
        // Ô nhớ cuối cùng hợp lệ: chỉ số 255 -> địa chỉ byte = 255 * 4 = 1020 (0x3FC)
        dut.memory[255] = 32'h1234_5678;
        addr = 32'd1020;
        check_instr(32'h1234_5678, "O nho cuoi cung hop le (addr = 1020)");

        // Địa chỉ ngay sát biên ngoài: chỉ số 256 -> địa chỉ byte = 1024 -> Phải trả về NOP
        addr = 32'd1024;
        check_instr(NOP, "Ngoai bien gan (addr = 1024) -> Tra ve NOP");

        // Địa chỉ ngoài xa:
        addr = 32'h0004_0000;
        check_instr(NOP, "Ngoai bien xa (addr = 0x00040000) -> Tra ve NOP");

        addr = 32'hFFFF_FFF0;
        check_instr(NOP, "Dia chi cuc lon (addr = 0xFFFFFFF0) -> Tra ve NOP");

        // --------------------------------------------------------------------
        // 4. KIỂM THỬ ĐỊA CHỈ KHÔNG CĂN LỀ 4-BYTE (MISALIGNED ADDRESSES)
        // Bất kỳ địa chỉ nào có addr[1:0] != 2'b00 đều PHẢI trả về NOP
        // --------------------------------------------------------------------
        $display("\n--- 4. KIỂM THỬ ĐỊA CHỈ LỆCH BIÊN (MISALIGNED) ---");
        // dut.memory[0] chứa 0x00500093, nhưng truy xuất lệch:
        addr = 32'd1; check_instr(NOP, "Lech byte 1 (addr = 1) -> Tra ve NOP");
        addr = 32'd2; check_instr(NOP, "Lech byte 2 (addr = 2) -> Tra ve NOP");
        addr = 32'd3; check_instr(NOP, "Lech byte 3 (addr = 3) -> Tra ve NOP");

        // dut.memory[1] ở addr=4, nhưng truy xuất addr=5, 6, 7:
        addr = 32'd5; check_instr(NOP, "Lech byte addr = 5 -> Tra ve NOP");
        addr = 32'd6; check_instr(NOP, "Lech byte addr = 6 -> Tra ve NOP");
        addr = 32'd7; check_instr(NOP, "Lech byte addr = 7 -> Tra ve NOP");

        // Tổng kết
        $display("\n==================================================");
        $display("   TỔNG KẾT INSTRUCTION_MEMORY_TB: %0d PASSED, %0d FAILED", passed, failed);
        $display("==================================================");

        if (failed == 0)
            $display(">>> KẾT QUẢ: MODULE INSTRUCTION MEMORY ĐẠT CHUẨN! <<<");
        else
            $display(">>> KẾT QUẢ: CÓ LỖI XẢY RA TRONG BỘ NHỚ LỆNH! <<<");

        $finish;
    end

endmodule


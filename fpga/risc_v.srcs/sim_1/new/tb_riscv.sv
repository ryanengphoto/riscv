`timescale 1ns / 1ps
`include "common_tasks.svh"

module tb_riscv(
    );

    // tb pass/fail signals
    static int checked, errors;

    // riscv cpu interface signals
    logic clk;
    logic rst;
    logic [31:0] imem_addr;
    logic [31:0] imem_data;
    logic dmem_read;
    logic dmem_write;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic [31:0] dmem_rdata;

    // Instruction memory (simple model) - expanded for Zbb tests
    logic [31:0] instruction_mem [0:63];
    initial begin
        for (int i = 0; i < 64; i++) begin
            instruction_mem[i] = 32'h00000013; // ADDI x0, x0, 0 (NOP)
        end
    end

    // Instruction memory interface
    always_comb begin
        if (imem_addr[31:2] < 64) begin
            imem_data = instruction_mem[imem_addr[31:2]];
        end else begin
            imem_data = 32'h00000013; // NOP
        end
    end

    // Data memory (simple model)
    logic [31:0] data_mem [0:1023];
    initial begin
        for (int i = 0; i < 1024; i++) begin
            data_mem[i] = 32'h0;
        end
    end

    always_ff @(posedge clk) begin
        if (dmem_write && (dmem_addr[31:2] < 1024)) begin
            data_mem[dmem_addr[31:2]] <= dmem_wdata;
        end
    end

    always_comb begin
        if (dmem_read && (dmem_addr[31:2] < 1024)) begin
            dmem_rdata = data_mem[dmem_addr[31:2]];
        end else begin
            dmem_rdata = 32'h0;
        end
    end

    // riscv cpu module
    riscv_cpu u_riscv_cpu (
        .clk(clk),
        .rst(rst),
        .imem_addr(imem_addr),
        .imem_data(imem_data),
        .dmem_read(dmem_read),
        .dmem_write(dmem_write),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_rdata(dmem_rdata)
    );

    initial begin
        // Dump VCD waveform file
        $dumpfile("tb_riscv.vcd");
        $dumpvars(0, tb_riscv);  // Dump all signals in testbench hierarchy
        
        // Test reset
        clk = 1'b0;
        rst = 1'b1;
        #10;
        rst = 1'b0;

        test_basic_arithmetic();
        
        // Reset for next test
        rst = 1'b1;
        #20;
        rst = 1'b0;
        
        test_load_use_hazard();
        
        // Reset for Zbb tests
        rst = 1'b1;
        #20;
        rst = 1'b0;
        
        test_zbb_operations();
        
        // Reset for branch forwarding tests
        rst = 1'b1;
        #20;
        rst = 1'b0;
        
        test_branch_forwarding();

        $display("Checked: %d | Errors: %d", checked, errors);
        if (errors) begin
            display_fail();
        end
        else begin
            display_pass();
        end
        $finish;
    end

    always #5 clk = ~clk;

    task automatic test_basic_arithmetic();
        // Variable declarations
        logic [11:0] imm_value;
        logic [4:0]  rs1_addr;
        logic [4:0]  rs2_addr;
        logic [2:0]  funct3;
        logic [6:0]  funct7;
        logic [4:0]  rd_addr;
        logic [6:0]  opcode;
        
        // Variable declarations for SW
        logic [11:0] sw_imm;
        logic [4:0]  sw_rs2;
        logic [4:0]  sw_rs1;
        logic [2:0]  sw_funct3;
        logic [6:0]  sw_opcode;
        
        int mem_idx;
        
        $display("Testing Basic Arithmetic Operations...");
        
        // =====================
        // Test 1: ADDI - Load immediate values
        // =====================
        // ADDI x1, x0, 5  : Load 5 into x1
        imm_value = 12'd5;
        rs1_addr  = 5'b00000;     // x0
        funct3    = 3'b000;       // ADDI
        rd_addr   = 5'b00001;     // x1
        opcode    = 7'b0010011;   // I-type ALU opcode
        instruction_mem[0] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // ADDI x2, x0, 3  : Load 3 into x2
        imm_value = 12'd3;
        rd_addr   = 5'b00010;     // x2
        instruction_mem[1] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // ADDI x3, x0, 7  : Load 7 into x3
        imm_value = 12'd7;
        rd_addr   = 5'b00011;     // x3
        instruction_mem[2] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // =====================
        // Test 2: ADD - x4 = x1 + x2 (5 + 3 = 8)
        // =====================
        funct7    = 7'b0000000;
        rs2_addr  = 5'b00010;     // x2
        rs1_addr  = 5'b00001;     // x1
        funct3    = 3'b000;       // ADD
        rd_addr   = 5'b00100;     // x4
        opcode    = 7'b0110011;   // R-type opcode
        instruction_mem[3] = {funct7, rs2_addr, rs1_addr, funct3, rd_addr, opcode};
        
        // =====================
        // Test 3: SUB - x5 = x3 - x2 (7 - 3 = 4)
        // =====================
        funct7    = 7'b0100000;   // SUB (funct7[5] = 1)
        rs2_addr  = 5'b00010;     // x2
        rs1_addr  = 5'b00011;     // x3
        funct3    = 3'b000;       // SUB
        rd_addr   = 5'b00101;     // x5
        instruction_mem[4] = {funct7, rs2_addr, rs1_addr, funct3, rd_addr, opcode};
        
        // =====================
        // Test 4: AND - x6 = x1 & x2 (5 & 3 = 1)
        // =====================
        funct7    = 7'b0000000;
        rs2_addr  = 5'b00010;     // x2
        rs1_addr  = 5'b00001;     // x1
        funct3    = 3'b111;       // AND
        rd_addr   = 5'b00110;     // x6
        instruction_mem[5] = {funct7, rs2_addr, rs1_addr, funct3, rd_addr, opcode};
        
        // =====================
        // Test 5: OR - x7 = x1 | x2 (5 | 3 = 7)
        // =====================
        funct7    = 7'b0000000;
        rs2_addr  = 5'b00010;     // x2
        rs1_addr  = 5'b00001;     // x1
        funct3    = 3'b110;       // OR
        rd_addr   = 5'b00111;     // x7
        instruction_mem[6] = {funct7, rs2_addr, rs1_addr, funct3, rd_addr, opcode};
        
        // =====================
        // Test 6: XOR - x8 = x1 ^ x2 (5 ^ 3 = 6)
        // =====================
        funct7    = 7'b0000000;
        rs2_addr  = 5'b00010;     // x2
        rs1_addr  = 5'b00001;     // x1
        funct3    = 3'b100;       // XOR
        rd_addr   = 5'b01000;     // x8
        instruction_mem[7] = {funct7, rs2_addr, rs1_addr, funct3, rd_addr, opcode};
        
        // =====================
        // Store results to memory for verification
        // =====================
        sw_funct3  = 3'b010;      // SW
        sw_opcode  = 7'b0100011;  // S-type opcode
        sw_rs1     = 5'b00000;    // x0 (base address)
        
        // SW x4, 0(x0)  : Store ADD result (8)
        sw_imm     = 12'd0;
        sw_rs2     = 5'b00100;    // x4
        instruction_mem[8] = {sw_imm[11:5], sw_rs2, sw_rs1, sw_funct3, sw_imm[4:0], sw_opcode};
        
        // SW x5, 4(x0)  : Store SUB result (4)
        sw_imm     = 12'd4;
        sw_rs2     = 5'b00101;    // x5
        instruction_mem[9] = {sw_imm[11:5], sw_rs2, sw_rs1, sw_funct3, sw_imm[4:0], sw_opcode};
        
        // SW x6, 8(x0)  : Store AND result (1)
        sw_imm     = 12'd8;
        sw_rs2     = 5'b00110;    // x6
        instruction_mem[10] = {sw_imm[11:5], sw_rs2, sw_rs1, sw_funct3, sw_imm[4:0], sw_opcode};
        
        // SW x7, 12(x0) : Store OR result (7)
        sw_imm     = 12'd12;
        sw_rs2     = 5'b00111;    // x7
        instruction_mem[11] = {sw_imm[11:5], sw_rs2, sw_rs1, sw_funct3, sw_imm[4:0], sw_opcode};
        
        // SW x8, 16(x0) : Store XOR result (6)
        sw_imm     = 12'd16;
        sw_rs2     = 5'b01000;    // x8
        instruction_mem[12] = {sw_imm[11:5], sw_rs2, sw_rs1, sw_funct3, sw_imm[4:0], sw_opcode};
        
        // Wait for pipeline to execute
        #400;
        
        // =====================
        // Verify results
        // =====================
        $display("Verifying arithmetic operations...");
        
        // Check ADD: 5 + 3 = 8
        mem_idx = 0;
        if (data_mem[mem_idx] == 32'd8) begin
            $display("PASS: ADD 5 + 3 = 8");
            checked++;
        end else begin
            $display("FAIL: ADD expected 8, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check SUB: 7 - 3 = 4
        mem_idx = 1;
        if (data_mem[mem_idx] == 32'd4) begin
            $display("PASS: SUB 7 - 3 = 4");
            checked++;
        end else begin
            $display("FAIL: SUB expected 4, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check AND: 5 & 3 = 1
        mem_idx = 2;
        if (data_mem[mem_idx] == 32'd1) begin
            $display("PASS: AND 5 & 3 = 1");
            checked++;
        end else begin
            $display("FAIL: AND expected 1, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check OR: 5 | 3 = 7
        mem_idx = 3;
        if (data_mem[mem_idx] == 32'd7) begin
            $display("PASS: OR 5 | 3 = 7");
            checked++;
        end else begin
            $display("FAIL: OR expected 7, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check XOR: 5 ^ 3 = 6
        mem_idx = 4;
        if (data_mem[mem_idx] == 32'd6) begin
            $display("PASS: XOR 5 ^ 3 = 6");
            checked++;
        end else begin
            $display("FAIL: XOR expected 6, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
    endtask
    
    task automatic test_load_use_hazard();
        // Test load-use hazard detection and stall mechanism
        // This tests: LW followed immediately by instruction that uses the loaded value
        
        // Variable declarations
        logic [11:0] imm_value;
        logic [4:0]  rs1_addr;
        logic [4:0]  rs2_addr;
        logic [2:0]  funct3;
        logic [6:0]  funct7;
        logic [4:0]  rd_addr;
        logic [6:0]  opcode;
        logic [11:0] sw_imm;
        logic [4:0]  sw_rs2;
        logic [4:0]  sw_rs1;
        logic [6:0]  sw_opcode;
        int mem_idx;
        
        $display("\nTesting Load-Use Hazard Detection...");
        
        // Clear instruction memory
        for (int i = 0; i < 16; i++) begin
            instruction_mem[i] = 32'h00000013; // NOP
        end
        
        // Pre-initialize data memory with test value
        data_mem[100] = 32'd42;  // Store 42 at address 400 (100 * 4)
        data_mem[101] = 32'd10;  // Store 10 at address 404 (101 * 4)
        
        // =====================
        // Test sequence:
        // 1. LW x1, 400(x0)    - Load 42 into x1
        // 2. ADD x2, x1, x0    - Use x1 immediately (LOAD-USE HAZARD - needs stall!)
        // 3. SW x2, 500(x0)    - Store result to verify
        // =====================
        
        // Instruction 0: ADDI x10, x0, 400 (prepare address)
        imm_value = 12'd400;
        rs1_addr  = 5'b00000;     // x0
        funct3    = 3'b000;       // ADDI
        rd_addr   = 5'b01010;     // x10
        opcode    = 7'b0010011;   // I-type ALU
        instruction_mem[0] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // Instruction 1: LW x1, 0(x10) - Load 42 into x1
        imm_value = 12'd0;
        rs1_addr  = 5'b01010;     // x10 (base address = 400)
        funct3    = 3'b010;       // LW
        rd_addr   = 5'b00001;     // x1
        opcode    = 7'b0000011;   // Load opcode
        instruction_mem[1] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // Instruction 2: ADD x2, x1, x0 - Use x1 immediately (LOAD-USE HAZARD!)
        funct7    = 7'b0000000;
        rs2_addr  = 5'b00000;     // x0
        rs1_addr  = 5'b00001;     // x1 (just loaded - hazard!)
        funct3    = 3'b000;       // ADD
        rd_addr   = 5'b00010;     // x2
        opcode    = 7'b0110011;   // R-type
        instruction_mem[2] = {funct7, rs2_addr, rs1_addr, funct3, rd_addr, opcode};
        
        // Instruction 3: SW x2, 500(x0) - Store result to memory for verification
        sw_imm     = 12'd500;
        sw_rs2     = 5'b00010;    // x2 (result)
        sw_rs1     = 5'b00000;    // x0 (base)
        funct3     = 3'b010;      // SW
        sw_opcode  = 7'b0100011;  // S-type
        instruction_mem[3] = {sw_imm[11:5], sw_rs2, sw_rs1, funct3, sw_imm[4:0], sw_opcode};
        
        // =====================
        // Second hazard test: Back-to-back load then use in rs2
        // 4. LW x3, 4(x10)     - Load 10 into x3
        // 5. ADD x4, x0, x3    - Use x3 immediately in rs2 (LOAD-USE HAZARD!)
        // 6. SW x4, 504(x0)    - Store result
        // =====================
        
        // Instruction 4: LW x3, 4(x10) - Load 10 into x3
        imm_value = 12'd4;
        rs1_addr  = 5'b01010;     // x10 (base address = 400)
        funct3    = 3'b010;       // LW
        rd_addr   = 5'b00011;     // x3
        opcode    = 7'b0000011;   // Load opcode
        instruction_mem[4] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // Instruction 5: ADD x4, x0, x3 - Use x3 immediately in rs2 (HAZARD!)
        funct7    = 7'b0000000;
        rs2_addr  = 5'b00011;     // x3 (just loaded - hazard!)
        rs1_addr  = 5'b00000;     // x0
        funct3    = 3'b000;       // ADD
        rd_addr   = 5'b00100;     // x4
        opcode    = 7'b0110011;   // R-type
        instruction_mem[5] = {funct7, rs2_addr, rs1_addr, funct3, rd_addr, opcode};
        
        // Instruction 6: SW x4, 504(x0) - Store result
        sw_imm     = 12'd504;
        sw_rs2     = 5'b00100;    // x4 (result)
        sw_rs1     = 5'b00000;    // x0 (base)
        funct3     = 3'b010;      // SW
        sw_opcode  = 7'b0100011;  // S-type
        instruction_mem[6] = {sw_imm[11:5], sw_rs2, sw_rs1, funct3, sw_imm[4:0], sw_opcode};
        
        // =====================
        // Third test: Load with 1-cycle gap (should work with forwarding, no stall needed)
        // 7. LW x5, 0(x10)     - Load 42 into x5
        // 8. NOP               - 1 cycle gap
        // 9. ADD x6, x5, x0    - Use x5 (should forward from MEM/WB, no stall)
        // 10. SW x6, 508(x0)   - Store result
        // =====================
        
        // Instruction 7: LW x5, 0(x10) - Load 42 into x5
        imm_value = 12'd0;
        rs1_addr  = 5'b01010;     // x10 (base address = 400)
        funct3    = 3'b010;       // LW
        rd_addr   = 5'b00101;     // x5
        opcode    = 7'b0000011;   // Load opcode
        instruction_mem[7] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // Instruction 8: NOP (1 cycle gap)
        instruction_mem[8] = 32'h00000013; // ADDI x0, x0, 0
        
        // Instruction 9: ADD x6, x5, x0 - Use x5 (forwarding from MEM/WB)
        funct7    = 7'b0000000;
        rs2_addr  = 5'b00000;     // x0
        rs1_addr  = 5'b00101;     // x5 (loaded 2 cycles ago - no hazard, can forward)
        funct3    = 3'b000;       // ADD
        rd_addr   = 5'b00110;     // x6
        opcode    = 7'b0110011;   // R-type
        instruction_mem[9] = {funct7, rs2_addr, rs1_addr, funct3, rd_addr, opcode};
        
        // Instruction 10: SW x6, 508(x0) - Store result
        sw_imm     = 12'd508;
        sw_rs2     = 5'b00110;    // x6 (result)
        sw_rs1     = 5'b00000;    // x0 (base)
        funct3     = 3'b010;      // SW
        sw_opcode  = 7'b0100011;  // S-type
        instruction_mem[10] = {sw_imm[11:5], sw_rs2, sw_rs1, funct3, sw_imm[4:0], sw_opcode};
        
        // Wait for pipeline to execute all instructions
        #500;
        
        // =====================
        // Verify results
        // =====================
        $display("Verifying load-use hazard handling...");
        
        // Check Test 1: Load 42, use immediately -> should be 42
        mem_idx = 125;  // Address 500/4 = 125
        if (data_mem[mem_idx] == 32'd42) begin
            $display("PASS: Load-Use Hazard Test 1 (rs1) - LW x1=42, ADD x2=x1+0 = 42");
            checked++;
        end else begin
            $display("FAIL: Load-Use Hazard Test 1 - expected 42, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check Test 2: Load 10, use immediately in rs2 -> should be 10
        mem_idx = 126;  // Address 504/4 = 126
        if (data_mem[mem_idx] == 32'd10) begin
            $display("PASS: Load-Use Hazard Test 2 (rs2) - LW x3=10, ADD x4=0+x3 = 10");
            checked++;
        end else begin
            $display("FAIL: Load-Use Hazard Test 2 - expected 10, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check Test 3: Load with gap (forwarding only) -> should be 42
        mem_idx = 127;  // Address 508/4 = 127
        if (data_mem[mem_idx] == 32'd42) begin
            $display("PASS: Forwarding Test - LW x5=42, NOP, ADD x6=x5+0 = 42");
            checked++;
        end else begin
            $display("FAIL: Forwarding Test - expected 42, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
    endtask
    
    task automatic test_zbb_operations();
        // Test Zbb bitmanip extension operations
        // All instructions in one continuous sequence
        
        int mem_idx;
        
        $display("\nTesting Zbb Bitmanip Operations...");
        
        // Clear data memory for Zbb results
        for (int i = 0; i < 20; i++) begin
            data_mem[i] = 32'h0;
        end
        
        // Clear instruction memory
        for (int i = 0; i < 64; i++) begin
            instruction_mem[i] = 32'h00000013; // NOP
        end
        
        // =====================
        // All instructions in one sequence
        // Using simple positive immediates to avoid sign-extension issues
        // x1 = 0x55 (0101_0101), x2 = 0x33 (0011_0011)
        // ANDN = 0x55 & ~0x33 = 0x55 & 0xFFFFFFCC = 0x44
        // ORN  = 0x55 | ~0x33 = 0x55 | 0xFFFFFFCC = 0xFFFFFFDD
        // XNOR = ~(0x55 ^ 0x33) = ~0x66 = 0xFFFFFF99
        // =====================
        
        // === SETUP ===
        // Inst 0: ADDI x1, x0, 0x55 -> x1 = 0x55
        instruction_mem[0] = 32'h05500093;  // ADDI x1, x0, 85
        
        // Inst 1: ADDI x2, x0, 0x33 -> x2 = 0x33
        instruction_mem[1] = 32'h03300113;  // ADDI x2, x0, 51
        
        // Inst 2: LUI x3, 0x80000 -> x3 = 0x80000000
        instruction_mem[2] = 32'h800001B7;  // LUI x3, 0x80000
        
        // Inst 3: ORI x3, x3, 1 -> x3 = 0x80000001
        instruction_mem[3] = 32'h0011E193;  // ORI x3, x3, 1
        
        // Inst 4: ADDI x4, x0, 5 -> x4 = 5
        instruction_mem[4] = 32'h00500213;  // ADDI x4, x0, 5
        
        // Inst 5: ADDI x6, x0, -5 -> x6 = 0xFFFFFFFB (-5)
        instruction_mem[5] = 32'hFFB00313;  // ADDI x6, x0, -5
        
        // === ZBB OPERATIONS ===
        // Inst 6: ANDN x7, x1, x2  (0x55 & ~0x33 = 0x44)
        instruction_mem[6] = 32'h4020F3B3;  // ANDN x7, x1, x2
        
        // Inst 7: ORN x8, x1, x2 (0x55 | ~0x33 = 0xFFFFFFDD)
        instruction_mem[7] = 32'h4020E433;  // ORN x8, x1, x2
        
        // Inst 8: XNOR x9, x1, x2 (~(0x55 ^ 0x33) = 0xFFFFFF99)
        instruction_mem[8] = 32'h4020C4B3; // XNOR x9, x1, x2
        
        // Inst 9: MIN x10, x4, x6 (min(5, -5) = -5)
        instruction_mem[9] = 32'h0A624533; // MIN x10, x4, x6
        
        // Inst 10: MAX x11, x4, x6 (max(5, -5) = 5)
        instruction_mem[10] = 32'h0A6265B3; // MAX x11, x4, x6
        
        // Inst 11: MINU x12, x4, x6 (minu(5, -5) = 5 unsigned)
        instruction_mem[11] = 32'h0A625633; // MINU x12, x4, x6
        
        // Inst 12: CLZ x13, x3 (clz(0x80000001) = 0)
        instruction_mem[12] = 32'h60019693; // CLZ x13, x3
        
        // Inst 13: CTZ x14, x3 (ctz(0x80000001) = 0)
        instruction_mem[13] = 32'h60119713; // CTZ x14, x3
        
        // === STORE RESULTS ===
        // Inst 14: SW x7, 0(x0) - ANDN
        instruction_mem[14] = 32'h00702023;  // SW x7, 0(x0)
        
        // Inst 15: SW x8, 4(x0) - ORN
        instruction_mem[15] = 32'h00802223;  // SW x8, 4(x0)
        
        // Inst 16: SW x9, 8(x0) - XNOR
        instruction_mem[16] = 32'h00902423;  // SW x9, 8(x0)
        
        // Inst 17: SW x10, 12(x0) - MIN
        instruction_mem[17] = 32'h00A02623; // SW x10, 12(x0)
        
        // Inst 18: SW x11, 16(x0) - MAX
        instruction_mem[18] = 32'h00B02823; // SW x11, 16(x0)
        
        // Inst 19: SW x12, 20(x0) - MINU
        instruction_mem[19] = 32'h00C02A23; // SW x12, 20(x0)
        
        // Inst 20: SW x13, 24(x0) - CLZ
        instruction_mem[20] = 32'h00D02C23; // SW x13, 24(x0)
        
        // Inst 21: SW x14, 28(x0) - CTZ
        instruction_mem[21] = 32'h00E02E23; // SW x14, 28(x0)
        
        // Wait for all instructions to execute
        // 24 instructions through 5-stage pipeline ~= 30 cycles, add margin
        #500;
        
        // =====================
        // Verify results
        // =====================
        $display("Verifying Zbb operations...");
        
        // Check ANDN: 0x55 & ~0x33 = 0x55 & 0xFFFFFFCC = 0x44
        mem_idx = 0;
        if (data_mem[mem_idx] == 32'h00000044) begin
            $display("PASS: ANDN 0x55 & ~0x33 = 0x44");
            checked++;
        end else begin
            $display("FAIL: ANDN expected 0x44, got 0x%08X", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check ORN: 0x55 | ~0x33 = 0x55 | 0xFFFFFFCC = 0xFFFFFFDD
        mem_idx = 1;
        if (data_mem[mem_idx] == 32'hFFFFFFDD) begin
            $display("PASS: ORN 0x55 | ~0x33 = 0xFFFFFFDD");
            checked++;
        end else begin
            $display("FAIL: ORN expected 0xFFFFFFDD, got 0x%08X", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check XNOR: ~(0x55 ^ 0x33) = ~0x66 = 0xFFFFFF99
        mem_idx = 2;
        if (data_mem[mem_idx] == 32'hFFFFFF99) begin
            $display("PASS: XNOR ~(0x55 ^ 0x33) = 0xFFFFFF99");
            checked++;
        end else begin
            $display("FAIL: XNOR expected 0xFFFFFF99, got 0x%08X", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check MIN: min(5, -5) = -5 (signed) = 0xFFFFFFFB
        mem_idx = 3;
        if (data_mem[mem_idx] == 32'hFFFFFFFB) begin
            $display("PASS: MIN min(5, -5) = -5 (0xFFFFFFFB)");
            checked++;
        end else begin
            $display("FAIL: MIN expected 0xFFFFFFFB, got 0x%08X", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check MAX: max(5, -5) = 5 (signed)
        mem_idx = 4;
        if (data_mem[mem_idx] == 32'd5) begin
            $display("PASS: MAX max(5, -5) = 5");
            checked++;
        end else begin
            $display("FAIL: MAX expected 5, got %d (0x%08X)", data_mem[mem_idx], data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check MINU: minu(5, 0xFFFFFFFB) = 5 (unsigned, 5 < huge number)
        mem_idx = 5;
        if (data_mem[mem_idx] == 32'd5) begin
            $display("PASS: MINU minu(5, 0xFFFFFFFB) = 5");
            checked++;
        end else begin
            $display("FAIL: MINU expected 5, got %d (0x%08X)", data_mem[mem_idx], data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check CLZ: clz(0x80000001) = 0 (MSB is set)
        mem_idx = 6;
        if (data_mem[mem_idx] == 32'd0) begin
            $display("PASS: CLZ clz(0x80000001) = 0");
            checked++;
        end else begin
            $display("FAIL: CLZ expected 0, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Check CTZ: ctz(0x80000001) = 0 (LSB is set)
        mem_idx = 7;
        if (data_mem[mem_idx] == 32'd0) begin
            $display("PASS: CTZ ctz(0x80000001) = 0");
            checked++;
        end else begin
            $display("FAIL: CTZ expected 0, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
    endtask

    // =====================================================
    // Branch Forwarding Tests
    // Tests ID-stage branch forwarding from EX/MEM and MEM/WB
    // =====================================================
    task automatic test_branch_forwarding();
        // Variable declarations
        logic [11:0] imm_value;
        logic [4:0]  rs1_addr;
        logic [4:0]  rs2_addr;
        logic [2:0]  funct3;
        logic [6:0]  funct7;
        logic [4:0]  rd_addr;
        logic [6:0]  opcode;
        logic [12:0] branch_imm;
        logic [11:0] sw_imm;
        logic [4:0]  sw_rs2;
        logic [4:0]  sw_rs1;
        logic [2:0]  sw_funct3;
        logic [6:0]  sw_opcode;
        int mem_idx;
        int i;
        
        $display("\nTesting Branch Forwarding...");
        
        // Clear instruction memory
        for (i = 0; i < 64; i++) begin
            instruction_mem[i] = 32'h00000013; // NOP
        end
        
        // Clear data memory
        for (i = 0; i < 32; i++) begin
            data_mem[i] = 32'h0;
        end
        
        // =====================================================
        // Test 1: Branch NOT taken with forwarding from EX/MEM
        // Structure:
        // 0: ADDI x1, x0, 5     ; x1 = 5
        // 1: NOP                ; x1 result in EX/MEM  
        // 2: BEQ x1, x0, +12    ; Branch to instr 5 if x1==x0 (NOT taken)
        // 3: ADDI x10, x0, 1    ; x10 = 1 (NOT taken path)
        // 4: JAL x0, +8         ; Skip to instr 6 (SW)
        // 5: ADDI x10, x0, 99   ; x10 = 99 (TAKEN path - should NOT execute)
        // 6: SW x10, 0(x0)
        // =====================================================
        
        // ADDI x1, x0, 5
        imm_value = 12'd5;
        rs1_addr  = 5'b00000;
        funct3    = 3'b000;
        rd_addr   = 5'b00001;
        opcode    = 7'b0010011;
        instruction_mem[0] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // NOP (ADDI x0, x0, 0)
        instruction_mem[1] = 32'h00000013;
        
        // BEQ x1, x0, +12 (jump to instruction 5 if taken)
        // B-type: imm[12|10:5] rs2 rs1 funct3 imm[4:1|11] opcode
        // imm = 12: imm[12]=0, imm[11]=0, imm[10:5]=0, imm[4:1]=6
        rs1_addr = 5'b00001;  // x1
        rs2_addr = 5'b00000;  // x0
        funct3   = 3'b000;    // BEQ
        opcode   = 7'b1100011;
        instruction_mem[2] = {1'b0, 6'b000000, rs2_addr, rs1_addr, funct3, 4'b0110, 1'b0, opcode};
        
        // ADDI x10, x0, 1 (NOT taken path - should execute)
        imm_value = 12'd1;
        rs1_addr  = 5'b00000;
        funct3    = 3'b000;
        rd_addr   = 5'b01010;  // x10
        opcode    = 7'b0010011;
        instruction_mem[3] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // JAL x0, +8 (skip instruction 5, go to instruction 6)
        // J-type: imm[20|10:1|11|19:12] rd opcode
        // imm = 8: imm[20]=0, imm[10:1]=4, imm[11]=0, imm[19:12]=0
        instruction_mem[4] = {1'b0, 10'b0000000100, 1'b0, 8'b00000000, 5'b00000, 7'b1101111};
        
        // ADDI x10, x0, 99 (TAKEN path - should NOT execute)
        imm_value = 12'd99;
        instruction_mem[5] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // Store x10 to memory[0] for verification
        sw_funct3 = 3'b010;
        sw_opcode = 7'b0100011;
        sw_rs1    = 5'b00000;  // x0
        sw_imm    = 12'd0;
        sw_rs2    = 5'b01010;  // x10
        instruction_mem[6] = {sw_imm[11:5], sw_rs2, sw_rs1, sw_funct3, sw_imm[4:0], sw_opcode};
        
        // =====================================================
        // Test 2: Branch TAKEN with forwarding
        // 7: ADDI x2, x0, 0     ; x2 = 0
        // 8: NOP
        // 9: BEQ x2, x0, +12    ; Branch TAKEN to instr 12
        // 10: ADDI x11, x0, 77  ; Should be skipped
        // 11: JAL x0, +8        ; (would skip to 13, but shouldn't reach here)
        // 12: ADDI x11, x0, 2   ; x11 = 2 (TAKEN path - should execute)
        // 13: SW x11, 4(x0)
        // =====================================================
        
        // ADDI x2, x0, 0
        imm_value = 12'd0;
        rs1_addr  = 5'b00000;
        funct3    = 3'b000;
        rd_addr   = 5'b00010;  // x2
        opcode    = 7'b0010011;
        instruction_mem[7] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // NOP
        instruction_mem[8] = 32'h00000013;
        
        // BEQ x2, x0, +12 (jump to instruction 12 if taken)
        rs1_addr = 5'b00010;  // x2
        rs2_addr = 5'b00000;  // x0
        funct3   = 3'b000;    // BEQ
        opcode   = 7'b1100011;
        instruction_mem[9] = {1'b0, 6'b000000, rs2_addr, rs1_addr, funct3, 4'b0110, 1'b0, opcode};
        
        // ADDI x11, x0, 77 (should be skipped)
        imm_value = 12'd77;
        rs1_addr  = 5'b00000;
        funct3    = 3'b000;
        rd_addr   = 5'b01011;  // x11
        opcode    = 7'b0010011;
        instruction_mem[10] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // JAL x0, +8 (skip to SW)
        instruction_mem[11] = {1'b0, 10'b0000000100, 1'b0, 8'b00000000, 5'b00000, 7'b1101111};
        
        // ADDI x11, x0, 2 (branch target - should execute)
        imm_value = 12'd2;
        instruction_mem[12] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // Store x11 to memory[4]
        sw_imm = 12'd4;
        sw_rs2 = 5'b01011;  // x11
        instruction_mem[13] = {sw_imm[11:5], sw_rs2, sw_rs1, sw_funct3, sw_imm[4:0], sw_opcode};
        
        // =====================================================
        // Test 3: Branch immediately after ALU (stall required)
        // 14: ADDI x3, x0, 10    ; x3 = 10
        // 15: BNE x3, x0, +12    ; Branch TAKEN - needs stall then forward
        // 16: ADDI x12, x0, 88   ; Should be skipped
        // 17: JAL x0, +8
        // 18: ADDI x12, x0, 3    ; x12 = 3 (branch target - should execute)
        // 19: SW x12, 8(x0)
        // =====================================================
        
        // ADDI x3, x0, 10
        imm_value = 12'd10;
        rd_addr   = 5'b00011;  // x3
        instruction_mem[14] = {imm_value, 5'b00000, 3'b000, rd_addr, 7'b0010011};
        
        // BNE x3, x0, +12 (needs stall - x3 from previous instruction)
        rs1_addr = 5'b00011;  // x3
        rs2_addr = 5'b00000;  // x0
        funct3   = 3'b001;    // BNE
        opcode   = 7'b1100011;
        instruction_mem[15] = {1'b0, 6'b000000, rs2_addr, rs1_addr, funct3, 4'b0110, 1'b0, opcode};
        
        // ADDI x12, x0, 88 (should be skipped)
        imm_value = 12'd88;
        rd_addr   = 5'b01100;  // x12
        instruction_mem[16] = {imm_value, 5'b00000, 3'b000, rd_addr, 7'b0010011};
        
        // JAL x0, +8
        instruction_mem[17] = {1'b0, 10'b0000000100, 1'b0, 8'b00000000, 5'b00000, 7'b1101111};
        
        // ADDI x12, x0, 3 (branch target)
        imm_value = 12'd3;
        instruction_mem[18] = {imm_value, 5'b00000, 3'b000, rd_addr, 7'b0010011};
        
        // Store x12 to memory[8]
        sw_imm = 12'd8;
        sw_rs2 = 5'b01100;  // x12
        instruction_mem[19] = {sw_imm[11:5], sw_rs2, sw_rs1, sw_funct3, sw_imm[4:0], sw_opcode};
        
        // =====================================================
        // Test 4: Branch after LOAD (needs stall for memory data)
        // 20: ADDI x4, x0, 20    ; x4 = 20 (value to store)
        // 21: SW x4, 100(x0)     ; Store 20 to memory[25]
        // 22: LW x5, 100(x0)     ; Load x5 = 20
        // 23: BEQ x5, x4, +12    ; Branch TAKEN, needs stall for load
        // 24: ADDI x13, x0, 66   ; Should be skipped
        // 25: JAL x0, +8
        // 26: ADDI x13, x0, 4    ; x13 = 4 (branch target)
        // 27: SW x13, 12(x0)
        // =====================================================
        
        // ADDI x4, x0, 20
        imm_value = 12'd20;
        rd_addr   = 5'b00100;  // x4
        instruction_mem[20] = {imm_value, 5'b00000, 3'b000, rd_addr, 7'b0010011};
        
        // SW x4, 100(x0)
        sw_imm = 12'd100;
        sw_rs2 = 5'b00100;  // x4
        instruction_mem[21] = {sw_imm[11:5], sw_rs2, sw_rs1, sw_funct3, sw_imm[4:0], sw_opcode};
        
        // LW x5, 100(x0)
        imm_value = 12'd100;
        rs1_addr  = 5'b00000;
        funct3    = 3'b010;  // LW
        rd_addr   = 5'b00101;  // x5
        opcode    = 7'b0000011;  // LOAD opcode
        instruction_mem[22] = {imm_value, rs1_addr, funct3, rd_addr, opcode};
        
        // BEQ x5, x4, +12 (needs stall - x5 from load)
        rs1_addr = 5'b00101;  // x5
        rs2_addr = 5'b00100;  // x4
        funct3   = 3'b000;    // BEQ
        opcode   = 7'b1100011;
        instruction_mem[23] = {1'b0, 6'b000000, rs2_addr, rs1_addr, funct3, 4'b0110, 1'b0, opcode};
        
        // ADDI x13, x0, 66 (should be skipped)
        imm_value = 12'd66;
        rd_addr   = 5'b01101;  // x13
        instruction_mem[24] = {imm_value, 5'b00000, 3'b000, rd_addr, 7'b0010011};
        
        // JAL x0, +8
        instruction_mem[25] = {1'b0, 10'b0000000100, 1'b0, 8'b00000000, 5'b00000, 7'b1101111};
        
        // ADDI x13, x0, 4 (branch target)
        imm_value = 12'd4;
        instruction_mem[26] = {imm_value, 5'b00000, 3'b000, rd_addr, 7'b0010011};
        
        // Store x13 to memory[12]
        sw_imm = 12'd12;
        sw_rs2 = 5'b01101;  // x13
        sw_funct3 = 3'b010;
        sw_opcode = 7'b0100011;
        instruction_mem[27] = {sw_imm[11:5], sw_rs2, sw_rs1, sw_funct3, sw_imm[4:0], sw_opcode};
        
        // Wait for pipeline to execute all instructions
        #600;
        
        // =====================================================
        // Verify results
        // =====================================================
        $display("Verifying branch forwarding...");
        
        // Test 1: BEQ not taken, x10 should be 1 (not 99)
        mem_idx = 0;
        if (data_mem[mem_idx] == 32'd1) begin
            $display("PASS: Branch NOT taken with EX/MEM forwarding (x10 = 1)");
            checked++;
        end else begin
            $display("FAIL: Branch forwarding test 1: expected 1, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Test 2: BEQ taken, x11 should be 2 (not 77)
        mem_idx = 1;
        if (data_mem[mem_idx] == 32'd2) begin
            $display("PASS: Branch TAKEN with EX/MEM forwarding (x11 = 2)");
            checked++;
        end else begin
            $display("FAIL: Branch forwarding test 2: expected 2, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Test 3: BNE taken with stall, x12 should be 3 (not 88)
        mem_idx = 2;
        if (data_mem[mem_idx] == 32'd3) begin
            $display("PASS: Branch with ID/EX stall (x12 = 3)");
            checked++;
        end else begin
            $display("FAIL: Branch forwarding test 3: expected 3, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
        // Test 4: BEQ after load, x13 should be 4 (not 66)
        mem_idx = 3;
        if (data_mem[mem_idx] == 32'd4) begin
            $display("PASS: Branch after LOAD with stall (x13 = 4)");
            checked++;
        end else begin
            $display("FAIL: Branch forwarding test 4: expected 4, got %d", data_mem[mem_idx]);
            checked++;
            errors++;
        end
        
    endtask

endmodule

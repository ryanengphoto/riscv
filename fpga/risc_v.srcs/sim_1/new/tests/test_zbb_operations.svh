// =============================================================================
// Test: Zbb Bitmanip Extension Operations
// Tests ANDN, ORN, XNOR, MIN, MAX, MINU, CLZ, CTZ instructions
// =============================================================================

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


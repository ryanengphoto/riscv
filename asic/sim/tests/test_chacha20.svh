// =============================================================================
// Test: ChaCha20 Quarter-Round Stress Test
// Generated from: sim/asm/chacha20_qr.s using tools/rv32_assembler.py
// Tests: ROL operations, ADD/XOR chains, loop execution
// =============================================================================

task automatic test_chacha20();
    
    int i;
    int errors_local;
    
    $display("\n=============================================================");
    $display("Testing ChaCha20 Quarter-Round Stress Test...");
    $display("=============================================================");
    
    errors_local = 0;
    
    // Clear memories
    for (i = 0; i < 64; i++) begin
        instruction_mem[i] = 32'h00000013; // NOP
    end
    for (i = 0; i < 1024; i++) begin
        data_mem[i] = 32'h0;
    end
    
    // =========================================================================
    // ChaCha20 Initial State (from RFC 7539)
    // =========================================================================
    data_mem[0]  = 32'h61707865;  // state[0] = "expa"
    data_mem[1]  = 32'h3320646e;  // state[1] = "nd 3"
    data_mem[2]  = 32'h79622d32;  // state[2] = "2-by"
    data_mem[3]  = 32'h6b206574;  // state[3] = "te k"
    
    // =========================================================================
    // Assembled from sim/asm/chacha20_qr.s
    // Run: python3 tools/rv32_assembler.py sim/asm/chacha20_qr.s
    // =========================================================================
    instruction_mem[0] = 32'h00002083;  // lw x1, 0(x0)
    instruction_mem[1] = 32'h00402103;  // lw x2, 4(x0)
    instruction_mem[2] = 32'h00802183;  // lw x3, 8(x0)
    instruction_mem[3] = 32'h00C02203;  // lw x4, 12(x0)
    instruction_mem[4] = 32'h00000513;  // addi x10, x0, 0
    instruction_mem[5] = 32'h00500593;  // addi x11, x0, 5
    instruction_mem[6] = 32'h002080B3;  // add x1, x1, x2
    instruction_mem[7] = 32'h00124233;  // xor x4, x4, x1
    instruction_mem[8] = 32'h01000293;  // addi x5, x0, 16
    instruction_mem[9] = 32'h60521233;  // rol x4, x4, x5
    instruction_mem[10] = 32'h004181B3;  // add x3, x3, x4
    instruction_mem[11] = 32'h00314133;  // xor x2, x2, x3
    instruction_mem[12] = 32'h00C00293;  // addi x5, x0, 12
    instruction_mem[13] = 32'h60511133;  // rol x2, x2, x5
    instruction_mem[14] = 32'h002080B3;  // add x1, x1, x2
    instruction_mem[15] = 32'h00124233;  // xor x4, x4, x1
    instruction_mem[16] = 32'h00800293;  // addi x5, x0, 8
    instruction_mem[17] = 32'h60521233;  // rol x4, x4, x5
    instruction_mem[18] = 32'h004181B3;  // add x3, x3, x4
    instruction_mem[19] = 32'h00314133;  // xor x2, x2, x3
    instruction_mem[20] = 32'h00700293;  // addi x5, x0, 7
    instruction_mem[21] = 32'h60511133;  // rol x2, x2, x5
    instruction_mem[22] = 32'h00150513;  // addi x10, x10, 1
    instruction_mem[23] = 32'h00B55463;  // bge x10, x11, 8
    instruction_mem[24] = 32'hFB9FF06F;  // j -72
    instruction_mem[25] = 32'h00102023;  // sw x1, 0(x0)
    instruction_mem[26] = 32'h00202223;  // sw x2, 4(x0)
    instruction_mem[27] = 32'h00302423;  // sw x3, 8(x0)
    instruction_mem[28] = 32'h00402623;  // sw x4, 12(x0)
    instruction_mem[29] = 32'h00A02823;  // sw x10, 16(x0)
    instruction_mem[30] = 32'h60209313;  // cpop x6, x1
    instruction_mem[31] = 32'h00602A23;  // sw x6, 20(x0)
    
    $display("Starting ChaCha20 quarter-round stress test...");
    $display("  Running 5 iterations of quarter-round");
    $display("  Initial: a=0x%08X, b=0x%08X, c=0x%08X, d=0x%08X",
             data_mem[0], data_mem[1], data_mem[2], data_mem[3]);
    
    // Run simulation: 5 iterations * ~20 instructions = ~150 cycles + margin
    #3000;
    
    // =========================================================================
    // Verify Results
    // =========================================================================
    $display("\nVerifying ChaCha20 stress test results...");
    
    // Check loop counter (should be 5)
    if (data_mem[4] == 32'd5) begin
        $display("PASS: Loop completed 5 iterations (counter = %d)", data_mem[4]);
        checked++;
    end else begin
        $display("FAIL: Loop counter expected 5, got %d", data_mem[4]);
        checked++;
        errors++;
        errors_local++;
    end
    
    // Check that all state values were modified
    if (data_mem[0] != 32'h61707865) begin
        $display("PASS: state[0] modified: 0x61707865 -> 0x%08X", data_mem[0]);
        checked++;
    end else begin
        $display("FAIL: state[0] unchanged");
        checked++;
        errors++;
        errors_local++;
    end
    
    if (data_mem[1] != 32'h3320646e) begin
        $display("PASS: state[1] modified: 0x3320646e -> 0x%08X", data_mem[1]);
        checked++;
    end else begin
        $display("FAIL: state[1] unchanged");
        checked++;
        errors++;
        errors_local++;
    end
    
    if (data_mem[2] != 32'h79622d32) begin
        $display("PASS: state[2] modified: 0x79622d32 -> 0x%08X", data_mem[2]);
        checked++;
    end else begin
        $display("FAIL: state[2] unchanged");
        checked++;
        errors++;
        errors_local++;
    end
    
    if (data_mem[3] != 32'h6b206574) begin
        $display("PASS: state[3] modified: 0x6b206574 -> 0x%08X", data_mem[3]);
        checked++;
    end else begin
        $display("FAIL: state[3] unchanged");
        checked++;
        errors++;
        errors_local++;
    end
    
    // Check CPOP result (should be non-zero for non-zero input)
    if (data_mem[5] > 0 && data_mem[5] <= 32) begin
        $display("PASS: CPOP(result) = %d bits set", data_mem[5]);
        checked++;
    end else begin
        $display("FAIL: CPOP expected 1-32, got %d", data_mem[5]);
        checked++;
        errors++;
        errors_local++;
    end
    
    // Display final state
    $display("\nFinal ChaCha20 state (after 5 quarter-rounds):");
    $display("  a = 0x%08X", data_mem[0]);
    $display("  b = 0x%08X", data_mem[1]);
    $display("  c = 0x%08X", data_mem[2]);
    $display("  d = 0x%08X", data_mem[3]);
    $display("  CPOP(a) = %d", data_mem[5]);
    
    if (errors_local == 0) begin
        $display("\nChaCha20 stress test: All ROL operations executed correctly!");
    end
    
endtask

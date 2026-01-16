// =============================================================================
// Test: Branch Forwarding
// Tests ID-stage branch forwarding from EX/MEM and MEM/WB
// =============================================================================

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


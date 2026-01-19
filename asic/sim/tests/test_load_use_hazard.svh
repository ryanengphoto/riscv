// =============================================================================
// Test: Load-Use Hazard Detection
// Tests pipeline stall mechanism for load-use hazards
// =============================================================================

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


// =============================================================================
// Test: JAL/JALR Return Address
// Verifies that JAL writes PC+4 to the link register
// =============================================================================

task automatic test_jal_return_address();
    logic [11:0] imm_value;
    logic [4:0]  rd_addr;
    logic [11:0] sw_imm;
    logic [4:0]  sw_rs2;
    logic [4:0]  sw_rs1;
    logic [2:0]  sw_funct3;
    logic [6:0]  sw_opcode;
    int mem_idx;
    int i;
    
    $display("\nTesting JAL Return Address...");
    
    // Clear instruction memory
    for (i = 0; i < 64; i++) begin
        instruction_mem[i] = 32'h00000013; // NOP
    end
    
    // Clear data memory
    for (i = 0; i < 32; i++) begin
        data_mem[i] = 32'h0;
    end
    
    // =====================================================
    // Test: JAL should write PC+4 to rd
    // 0: JAL x1, +8    ; x1 = PC+4 = 4, jump to instruction 2
    // 1: ADDI x2, x0, 99  ; Should be skipped
    // 2: SW x1, 0(x0)  ; Store return address (should be 4)
    // =====================================================
    
    // JAL x1, +8 (at PC=0, so x1 should get 0+4=4)
    // J-type: imm[20|10:1|11|19:12] rd opcode
    // imm = 8: imm[20]=0, imm[10:1]=00000_00100, imm[11]=0, imm[19:12]=00000000
    rd_addr = 5'b00001;  // x1
    instruction_mem[0] = {1'b0, 10'b0000000100, 1'b0, 8'b00000000, rd_addr, 7'b1101111};
    
    // ADDI x2, x0, 99 (should be skipped)
    instruction_mem[1] = {12'd99, 5'b00000, 3'b000, 5'b00010, 7'b0010011};
    
    // SW x1, 0(x0) - store the return address
    sw_funct3 = 3'b010;
    sw_opcode = 7'b0100011;
    sw_rs1    = 5'b00000;  // x0
    sw_imm    = 12'd0;
    sw_rs2    = 5'b00001;  // x1
    instruction_mem[2] = {sw_imm[11:5], sw_rs2, sw_rs1, sw_funct3, sw_imm[4:0], sw_opcode};
    
    // =====================================================
    // Test 2: JAL with different rd to verify it's not hardcoded
    // 3: JAL x5, +8    ; x5 = PC+4 = 12+4 = 16
    // 4: ADDI x6, x0, 88  ; Should be skipped
    // 5: SW x5, 4(x0)  ; Store return address (should be 16)
    // =====================================================
    
    // JAL x5, +8 (at PC=12, so x5 should get 12+4=16)
    rd_addr = 5'b00101;  // x5
    instruction_mem[3] = {1'b0, 10'b0000000100, 1'b0, 8'b00000000, rd_addr, 7'b1101111};
    
    // ADDI x6, x0, 88 (should be skipped)
    instruction_mem[4] = {12'd88, 5'b00000, 3'b000, 5'b00110, 7'b0010011};
    
    // SW x5, 4(x0) - store the return address
    sw_imm = 12'd4;
    sw_rs2 = 5'b00101;  // x5
    instruction_mem[5] = {sw_imm[11:5], sw_rs2, sw_rs1, sw_funct3, sw_imm[4:0], sw_opcode};
    
    // Wait for pipeline to execute
    #300;
    
    // =====================================================
    // Verify results
    // =====================================================
    $display("Verifying JAL return address...");
    
    // Test 1: JAL at PC=0 should write 4 to x1
    mem_idx = 0;
    if (data_mem[mem_idx] == 32'd4) begin
        $display("PASS: JAL x1, +8 at PC=0: x1 = %d (expected 4)", data_mem[mem_idx]);
        checked++;
    end else begin
        $display("FAIL: JAL return address test 1: expected 4, got %d", data_mem[mem_idx]);
        checked++;
        errors++;
    end
    
    // Test 2: JAL at PC=12 should write 16 to x5
    mem_idx = 1;
    if (data_mem[mem_idx] == 32'd16) begin
        $display("PASS: JAL x5, +8 at PC=12: x5 = %d (expected 16)", data_mem[mem_idx]);
        checked++;
    end else begin
        $display("FAIL: JAL return address test 2: expected 16, got %d", data_mem[mem_idx]);
        checked++;
        errors++;
    end
    
endtask


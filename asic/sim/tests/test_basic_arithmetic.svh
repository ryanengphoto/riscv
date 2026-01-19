// =============================================================================
// Test: Basic Arithmetic Operations
// Tests ADDI, ADD, SUB, AND, OR, XOR instructions
// =============================================================================

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


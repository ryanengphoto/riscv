/*
Author: Ryan Eng

RISC-V 5-Stage Pipeline CPU
Stages: IF (Instruction Fetch), ID (Decode), EX (Execute), MEM (Memory), WB (Writeback)
*/

`timescale 1ns / 1ps

module riscv_cpu(
    input  logic        clk,
    input  logic        rst,
    // Instruction memory interface
    output logic [31:0] imem_addr,
    input  logic [31:0] imem_data,
    // Data memory interface
    output logic        dmem_read,
    output logic        dmem_write,
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wdata,
    input  logic [31:0] dmem_rdata
);

    // =====================
    // Pipeline Registers
    // =====================
    
    // IF/ID Pipeline Register
    logic [31:0] if_id_pc;
    logic [31:0] if_id_pc_plus_4;
    logic [31:0] if_id_instruction;

    // ID/EX Pipeline Register
    logic [31:0] id_ex_pc;
    logic [31:0] id_ex_pc_plus_4;
    logic [31:0] id_ex_rs1_data;
    logic [31:0] id_ex_rs2_data;
    logic [31:0] id_ex_immediate;
    logic [4:0]  id_ex_rd;
    logic [4:0]  id_ex_rs1;
    logic [4:0]  id_ex_rs2;
    logic [4:0]  id_ex_alu_sel;
    logic        id_ex_alu_src;
    logic        id_ex_alu_pc_src;
    logic        id_ex_reg_write;
    logic        id_ex_mem_read;
    logic        id_ex_mem_write;
    logic        id_ex_mem_to_reg;
    logic        id_ex_branch;
    logic        id_ex_jump;
    logic [2:0]  id_ex_funct3;

    // EX/MEM Pipeline Register
    logic [31:0] ex_mem_pc_plus_4;
    logic [31:0] ex_mem_alu_result;
    logic [31:0] ex_mem_rs2_data;
    logic [4:0]  ex_mem_rd;
    logic        ex_mem_reg_write;
    logic        ex_mem_mem_read;
    logic        ex_mem_mem_write;
    logic        ex_mem_mem_to_reg;
    logic        ex_mem_jump;
    logic [2:0]  ex_mem_funct3;

    // MEM/WB Pipeline Register
    logic [31:0] mem_wb_pc_plus_4;
    logic [31:0] mem_wb_alu_result;
    logic [31:0] mem_wb_mem_data;
    logic [4:0]  mem_wb_rd;
    logic        mem_wb_reg_write;
    logic        mem_wb_mem_to_reg;
    logic        mem_wb_jump;

    // =====================
    // Stage 1: Instruction Fetch (IF)
    // =====================
    logic [31:0] pc;
    logic [31:0] pc_next;
    logic [31:0] pc_plus_4;
    logic        pc_src;  // PC source: 0=PC+4, 1=branch/jump target
    logic        stall;  // stall signal from hazard detection unit

    assign pc_plus_4 = pc + 32'd4;
    assign imem_addr = pc;
    
    // PC update
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'h00000000; // Start at address 0
        end 
        else if (!stall) begin
            pc <= pc_next;
        end
    end

    // =====================
    // IF/ID Pipeline Register
    // =====================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Asynchronous reset
            if_id_pc           <= 32'b0;
            if_id_pc_plus_4    <= 32'b0;
            if_id_instruction  <= 32'b0;
        end else if (pc_src) begin
            // Synchronous flush on branch/jump taken
            if_id_pc           <= 32'b0;
            if_id_pc_plus_4    <= 32'b0;
            if_id_instruction  <= 32'b0;
        end else if (!stall) begin
            // Normal operation (freeze IF/ID during stall)
            if_id_pc           <= pc;
            if_id_pc_plus_4    <= pc_plus_4;
            if_id_instruction  <= imem_data;
        end
        // When stall is active, IF/ID holds its current value
    end

    // =====================
    // Stage 2: Instruction Decode (ID)
    // =====================
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] immediate;
    logic [4:0]  alu_sel;
    logic        alu_src;
    logic        alu_pc_src;
    logic        reg_write;
    logic        mem_read;
    logic        mem_write;
    logic        mem_to_reg;
    logic        branch;
    logic        jump;
    logic [2:0]  imm_sel;
    logic [4:0]  rd;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [2:0]  funct3;

    assign rd     = if_id_instruction[11:7];
    assign rs1    = if_id_instruction[19:15];
    assign rs2    = if_id_instruction[24:20];
    assign funct3 = if_id_instruction[14:12];

    // Control Unit
    control_unit u_control (
        .instruction(if_id_instruction),
        .alu_sel(alu_sel),
        .alu_src(alu_src),
        .alu_pc_src(alu_pc_src),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .imm_sel(imm_sel)
    );

    // Immediate Generator
    immediate_generator u_imm_gen (
        .instruction(if_id_instruction),
        .imm_sel(imm_sel),
        .immediate(immediate)
    );

    // Register File (4 read ports: 2 for ID stage, 2 for EX stage)
    logic [31:0] ex_rs1_data_current;
    logic [31:0] ex_rs2_data_current;
    register_file u_reg_file (
        .clk(clk),
        .rst(rst),
        .we(mem_wb_reg_write),
        .raddr1(rs1),              // ID stage read address 1
        .raddr2(rs2),              // ID stage read address 2
        .raddr3(id_ex_rs1),        // EX stage read address 1
        .raddr4(id_ex_rs2),        // EX stage read address 2
        .waddr(mem_wb_rd),
        .wdata(wb_data),
        .rdata1(rs1_data),         // ID stage read data 1
        .rdata2(rs2_data),         // ID stage read data 2
        .rdata3(ex_rs1_data_current), // EX stage read data 1
        .rdata4(ex_rs2_data_current)  // EX stage read data 2
    );

    // =====================
    // ID Stage Forwarding (for branch comparator)
    // =====================
    logic [31:0] id_rs1_forwarded;
    logic [31:0] id_rs2_forwarded;
    logic [1:0]  id_forward_rs1;
    logic [1:0]  id_forward_rs2;
    
    // Forward declaration for wb_data (calculated in forwarding unit section)
    logic [31:0] wb_data;

    // ID-stage forwarding detection for rs1
    // Priority: ID/EX (ALU result from prev instr) > EX/MEM > MEM/WB > Register File
    always_comb begin
        if ((rs1 != 5'b0) && (rs1 == id_ex_rd) && id_ex_reg_write && !id_ex_mem_read) begin
            // Forward from ID/EX (previous instruction's result will be in EX/MEM next cycle)
            // But we can't use it yet - this is a hazard that requires stall
            id_forward_rs1 = 2'b00; // Will be handled by stall logic
        end else if ((rs1 != 5'b0) && (rs1 == ex_mem_rd) && ex_mem_reg_write) begin
            id_forward_rs1 = 2'b10; // Forward from EX/MEM
        end else if ((rs1 != 5'b0) && (rs1 == mem_wb_rd) && mem_wb_reg_write) begin
            id_forward_rs1 = 2'b01; // Forward from MEM/WB
        end else begin
            id_forward_rs1 = 2'b00; // Use register file
        end
    end

    // ID-stage forwarding detection for rs2
    always_comb begin
        if ((rs2 != 5'b0) && (rs2 == id_ex_rd) && id_ex_reg_write && !id_ex_mem_read) begin
            id_forward_rs2 = 2'b00; // Will be handled by stall logic
        end else if ((rs2 != 5'b0) && (rs2 == ex_mem_rd) && ex_mem_reg_write) begin
            id_forward_rs2 = 2'b10; // Forward from EX/MEM
        end else if ((rs2 != 5'b0) && (rs2 == mem_wb_rd) && mem_wb_reg_write) begin
            id_forward_rs2 = 2'b01; // Forward from MEM/WB
        end else begin
            id_forward_rs2 = 2'b00; // Use register file
        end
    end

    // ID-stage forwarding muxes
    always_comb begin
        case (id_forward_rs1)
            2'b10:   id_rs1_forwarded = ex_mem_alu_result;  // Forward from EX/MEM
            2'b01:   id_rs1_forwarded = wb_data;            // Forward from MEM/WB
            default: id_rs1_forwarded = rs1_data;           // Use register file
        endcase
        
        case (id_forward_rs2)
            2'b10:   id_rs2_forwarded = ex_mem_alu_result;  // Forward from EX/MEM
            2'b01:   id_rs2_forwarded = wb_data;            // Forward from MEM/WB
            default: id_rs2_forwarded = rs2_data;           // Use register file
        endcase
    end

    // =====================
    // ID Stage Branch Comparator
    // =====================
    logic id_branch_taken;
    logic [31:0] id_branch_target;
    logic [31:0] id_jump_target;
    logic        id_pc_src;
    
    // Branch comparator (operates in ID stage for early branch resolution)
    branch_comparator u_branch_comp (
        .rs1_data(id_rs1_forwarded),
        .rs2_data(id_rs2_forwarded),
        .funct3(funct3),
        .is_branch(branch),
        .branch_taken(id_branch_taken)
    );
    
    // Branch/Jump target calculation (in ID stage)
    assign id_branch_target = if_id_pc + immediate;
    
    // For JAL, target is PC + immediate (can be calculated in ID)
    // For JALR, target is rs1 + immediate (needs forwarded rs1, calculated here)
    // Note: JALR detection - it's a jump with opcode 1100111
    logic is_jalr;
    assign is_jalr = (if_id_instruction[6:0] == 7'b1100111);
    assign id_jump_target = is_jalr ? (id_rs1_forwarded + immediate) : id_branch_target;
    
    // PC source selection (now in ID stage)
    assign id_pc_src = (branch && id_branch_taken) || jump;

    // =====================
    // ID/EX Pipeline Register
    // =====================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Asynchronous reset
            id_ex_pc           <= 32'b0;
            id_ex_pc_plus_4    <= 32'b0;
            id_ex_rs1_data     <= 32'b0;
            id_ex_rs2_data     <= 32'b0;
            id_ex_immediate    <= 32'b0;
            id_ex_rd           <= 5'b0;
            id_ex_rs1          <= 5'b0;
            id_ex_rs2          <= 5'b0;
            id_ex_alu_sel      <= 5'b0;
            id_ex_alu_src      <= 1'b0;
            id_ex_alu_pc_src   <= 1'b0;
            id_ex_reg_write    <= 1'b0;
            id_ex_mem_read     <= 1'b0;
            id_ex_mem_write    <= 1'b0;
            id_ex_mem_to_reg   <= 1'b0;
            id_ex_branch       <= 1'b0;
            id_ex_jump         <= 1'b0;
            id_ex_funct3       <= 3'b0;
        end else if (pc_src || stall) begin
            // Synchronous flush on branch/jump taken, or insert bubble on stall
            id_ex_pc           <= 32'b0;
            id_ex_pc_plus_4    <= 32'b0;
            id_ex_rs1_data     <= 32'b0;
            id_ex_rs2_data     <= 32'b0;
            id_ex_immediate    <= 32'b0;
            id_ex_rd           <= 5'b0;
            id_ex_rs1          <= 5'b0;
            id_ex_rs2          <= 5'b0;
            id_ex_alu_sel      <= 5'b0;
            id_ex_alu_src      <= 1'b0;
            id_ex_alu_pc_src   <= 1'b0;
            id_ex_reg_write    <= 1'b0;
            id_ex_mem_read     <= 1'b0;
            id_ex_mem_write    <= 1'b0;
            id_ex_mem_to_reg   <= 1'b0;
            id_ex_branch       <= 1'b0;
            id_ex_jump         <= 1'b0;
            id_ex_funct3       <= 3'b0;
        end else begin
            // Normal operation
            id_ex_pc           <= if_id_pc;
            id_ex_pc_plus_4    <= if_id_pc_plus_4;
            id_ex_rs1_data     <= rs1_data;
            id_ex_rs2_data     <= rs2_data;
            id_ex_immediate    <= immediate;
            id_ex_rd           <= rd;
            id_ex_rs1          <= rs1;
            id_ex_rs2          <= rs2;
            id_ex_alu_sel      <= alu_sel;
            id_ex_alu_src      <= alu_src;
            id_ex_alu_pc_src   <= alu_pc_src;
            id_ex_reg_write    <= reg_write;
            id_ex_mem_read     <= mem_read;
            id_ex_mem_write    <= mem_write;
            id_ex_mem_to_reg   <= mem_to_reg;
            id_ex_branch       <= branch;
            id_ex_jump         <= jump;
            id_ex_funct3       <= funct3;
        end
    end

    // =====================
    // Forwarding Unit (Data Hazard Handling for EX Stage)
    // =====================
    logic [31:0] rs1_data_forwarded;
    logic [31:0] rs2_data_forwarded;
    logic [1:0]  forward_rs1;
    logic [1:0]  forward_rs2;

    // =====================
    // Hazard Detection Unit
    // =====================
    logic stall_load_use;      // Standard load-use hazard (1 cycle stall)
    logic stall_branch;        // Branch hazard when operand not ready in ID stage
    
    // Load-use hazard: instruction in EX is a load, and current instruction needs its result
    assign stall_load_use = id_ex_mem_read && 
                            (id_ex_rd != 5'b0) &&
                            ((id_ex_rd == rs1) || (id_ex_rd == rs2));
    
    // Branch/Jump hazard: branch/jump in ID needs data from instruction in EX (not yet available)
    // This includes:
    // 1. Previous instruction (in ID/EX) writes to a register that branch needs
    // 2. Load in ID/EX - need 2 cycles (handled by stall_load_use being active for 2 cycles)
    // 3. Load in EX/MEM - need 1 cycle (data comes from memory this cycle)
    logic branch_needs_rs1, branch_needs_rs2;
    assign branch_needs_rs1 = (branch || is_jalr) && (rs1 != 5'b0);
    assign branch_needs_rs2 = branch && (rs2 != 5'b0);
    
    // Stall if branch/jump needs result from instruction in ID/EX (not yet computed)
    logic stall_branch_id_ex;
    assign stall_branch_id_ex = ((branch_needs_rs1 && (rs1 == id_ex_rd) && id_ex_reg_write) ||
                                  (branch_needs_rs2 && (rs2 == id_ex_rd) && id_ex_reg_write));
    
    // Stall if branch needs result from load in EX/MEM (data being read from memory this cycle)
    logic stall_branch_ex_mem_load;
    assign stall_branch_ex_mem_load = ex_mem_mem_read &&
                                       ((branch_needs_rs1 && (rs1 == ex_mem_rd)) ||
                                        (branch_needs_rs2 && (rs2 == ex_mem_rd)));
    
    assign stall_branch = stall_branch_id_ex || stall_branch_ex_mem_load;
    
    // Combined stall signal
    assign stall = stall_load_use || stall_branch;

    // Calculate wb_data for forwarding (same as in WB stage)
    // Note: wb_data is declared earlier in ID stage forwarding section
    assign wb_data = mem_wb_jump ? mem_wb_pc_plus_4 :
                     (mem_wb_mem_to_reg ? mem_wb_mem_data : mem_wb_alu_result);

    // Forwarding detection for rs1
    always_comb begin
        // Priority: EX/MEM > MEM/WB > Register File
        if ((id_ex_rs1 != 5'b0) && (id_ex_rs1 == ex_mem_rd) && ex_mem_reg_write) begin
            forward_rs1 = 2'b10; // Forward from EX/MEM
        end else if ((id_ex_rs1 != 5'b0) && (id_ex_rs1 == mem_wb_rd) && mem_wb_reg_write) begin
            forward_rs1 = 2'b01; // Forward from MEM/WB
        end else begin
            forward_rs1 = 2'b00; // Use register file
        end
    end

    // Forwarding detection for rs2
    always_comb begin
        // Priority: EX/MEM > MEM/WB > Register File
        if ((id_ex_rs2 != 5'b0) && (id_ex_rs2 == ex_mem_rd) && ex_mem_reg_write) begin
            forward_rs2 = 2'b10; // Forward from EX/MEM
        end else if ((id_ex_rs2 != 5'b0) && (id_ex_rs2 == mem_wb_rd) && mem_wb_reg_write) begin
            forward_rs2 = 2'b01; // Forward from MEM/WB
        end else begin
            forward_rs2 = 2'b00; // Use register file
        end
    end

    // Forwarding muxes
    always_comb begin
        case (forward_rs1)
            2'b10: rs1_data_forwarded = ex_mem_alu_result;  // Forward from EX/MEM
            2'b01: rs1_data_forwarded = wb_data;             // Forward from MEM/WB
            default: rs1_data_forwarded = ex_rs1_data_current; // Use current register file value
        endcase
        
        case (forward_rs2)
            2'b10: rs2_data_forwarded = ex_mem_alu_result;  // Forward from EX/MEM
            2'b01: rs2_data_forwarded = wb_data;             // Forward from MEM/WB
            default: rs2_data_forwarded = ex_rs2_data_current; // Use current register file value
        endcase
    end

    // =====================
    // Stage 3: Execute (EX)
    // =====================
    logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;
    logic [31:0] alu_result;

    // ALU operand selection (with forwarding)
    assign alu_operand_a = id_ex_alu_pc_src ? id_ex_pc : rs1_data_forwarded;
    assign alu_operand_b = id_ex_alu_src ? id_ex_immediate : rs2_data_forwarded;

    // ALU (no longer used for branch comparison - that's in ID stage now)
    alu_core u_alu (
        .alu_sel(id_ex_alu_sel),
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .result(alu_result)
    );

    // Branch/Jump is now resolved in ID stage (see branch_comparator above)
    // PC source selection uses ID stage signals
    assign pc_src = id_pc_src;
    assign pc_next = pc_src ? id_jump_target : pc_plus_4;

    // =====================
    // EX/MEM Pipeline Register
    // =====================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ex_mem_pc_plus_4   <= 32'b0;
            ex_mem_alu_result  <= 32'b0;
            ex_mem_rs2_data    <= 32'b0;
            ex_mem_rd          <= 5'b0;
            ex_mem_reg_write   <= 1'b0;
            ex_mem_mem_read    <= 1'b0;
            ex_mem_mem_write   <= 1'b0;
            ex_mem_mem_to_reg  <= 1'b0;
            ex_mem_jump        <= 1'b0;
            ex_mem_funct3      <= 3'b0;
        end else begin
            ex_mem_pc_plus_4   <= id_ex_pc_plus_4;
            ex_mem_alu_result  <= alu_result;
            ex_mem_rs2_data    <= rs2_data_forwarded;  // Use forwarded value for stores
            ex_mem_rd          <= id_ex_rd;
            ex_mem_reg_write   <= id_ex_reg_write;
            ex_mem_mem_read    <= id_ex_mem_read;
            ex_mem_mem_write   <= id_ex_mem_write;
            ex_mem_mem_to_reg  <= id_ex_mem_to_reg;
            ex_mem_jump        <= id_ex_jump;
            ex_mem_funct3      <= id_ex_funct3;
        end
    end

    // =====================
    // Stage 4: Memory (MEM)
    // =====================
    assign dmem_read   = ex_mem_mem_read;
    assign dmem_write  = ex_mem_mem_write;
    assign dmem_addr   = ex_mem_alu_result;
    assign dmem_wdata  = ex_mem_rs2_data;

    // =====================
    // MEM/WB Pipeline Register
    // =====================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_wb_pc_plus_4    <= 32'b0;
            mem_wb_alu_result   <= 32'b0;
            mem_wb_mem_data     <= 32'b0;
            mem_wb_rd           <= 5'b0;
            mem_wb_reg_write    <= 1'b0;
            mem_wb_mem_to_reg   <= 1'b0;
            mem_wb_jump         <= 1'b0;
        end else begin
            mem_wb_pc_plus_4    <= ex_mem_pc_plus_4;
            mem_wb_alu_result   <= ex_mem_alu_result;
            mem_wb_mem_data     <= dmem_rdata;
            mem_wb_rd           <= ex_mem_rd;
            mem_wb_reg_write    <= ex_mem_reg_write;
            mem_wb_mem_to_reg   <= ex_mem_mem_to_reg;
            mem_wb_jump         <= ex_mem_jump;
        end
    end

    // =====================
    // Stage 5: Writeback (WB)
    // =====================
    // Writeback mux: JAL/JALR -> PC+4, Load -> memory data, else -> ALU result
    // (wb_data is already calculated in forwarding unit above)

endmodule


/*
Author: Ryan Eng

RISC-V Control Unit
Decodes RISC-V instructions and generates control signals
Supports: R-type, I-type, S-type, B-type, U-type, J-type
*/

`timescale 1ns / 1ps

module control_unit(
    input  logic [31:0] instruction,
    output logic [3:0]  alu_sel,         // ALU operation select
    output logic        alu_src,         // ALU source (0=reg, 1=immediate)
    output logic        alu_pc_src,      // ALU operand A source (0=rs1, 1=PC)
    output logic        reg_write,       // register write enable
    output logic        mem_read,        // memory read enable
    output logic        mem_write,       // memory write enable
    output logic        mem_to_reg,      // memory to register (0=ALU, 1=memory)
    output logic        branch,          // branch instruction
    output logic        jump,            // jump instruction
    output logic [2:0]  imm_sel          // immediate type select
);

    // Instruction fields
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    // =====================
    // Control signal generation
    // =====================
    always_comb begin
        // Default values
        alu_sel    = 4'b0;
        alu_src    = 1'b0;
        alu_pc_src = 1'b0;
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        imm_sel    = 3'b0;

        case (opcode)
            // R-type instructions (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
            7'b0110011: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                mem_to_reg = 1'b0;
                imm_sel   = 3'b000; // not used
                
                case (funct3)
                    3'b000: alu_sel = (funct7[5]) ? 4'b0110 : 4'b0010; // SUB : ADD
                    3'b001: alu_sel = 4'b0100; // SLL
                    3'b010: alu_sel = 4'b1000; // SLT
                    3'b011: alu_sel = 4'b1001; // SLTU
                    3'b100: alu_sel = 4'b0011; // XOR
                    3'b101: alu_sel = (funct7[5]) ? 4'b0111 : 4'b0101; // SRA : SRL
                    3'b110: alu_sel = 4'b0001; // OR
                    3'b111: alu_sel = 4'b0000; // AND
                endcase
            end

            // I-type ALU instructions (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;  // use immediate
                mem_to_reg = 1'b0;
                imm_sel   = 3'b000; // I-type immediate
                
                case (funct3)
                    3'b000: alu_sel = 4'b0010; // ADDI
                    3'b010: alu_sel = 4'b1000; // SLTI
                    3'b011: alu_sel = 4'b1001; // SLTIU
                    3'b100: alu_sel = 4'b0011; // XORI
                    3'b110: alu_sel = 4'b0001; // ORI
                    3'b111: alu_sel = 4'b0000; // ANDI
                    3'b001: alu_sel = 4'b0100; // SLLI
                    3'b101: alu_sel = (funct7[5]) ? 4'b0111 : 4'b0101; // SRAI : SRLI
                endcase
            end

            // Load instructions (LB, LH, LW, LBU, LHU)
            7'b0000011: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;  // use immediate for address calculation
                mem_read  = 1'b1;
                mem_to_reg = 1'b1; // load from memory
                alu_sel   = 4'b0010; // ADD for address calculation
                imm_sel   = 3'b000; // I-type immediate
            end

            // Store instructions (SB, SH, SW)
            7'b0100011: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;  // use immediate for address calculation
                alu_sel   = 4'b0010; // ADD for address calculation
                imm_sel   = 3'b001; // S-type immediate
            end

            // Branch instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            7'b1100011: begin
                branch    = 1'b1;
                alu_src   = 1'b0;  // compare registers
                imm_sel   = 3'b010; // B-type immediate
                
                case (funct3)
                    3'b000: alu_sel = 4'b0110; // BEQ (use SUB, check zero)
                    3'b001: alu_sel = 4'b0110; // BNE (use SUB, check not zero)
                    3'b100: alu_sel = 4'b1000; // BLT (signed)
                    3'b101: alu_sel = 4'b1000; // BGE (signed, inverted)
                    3'b110: alu_sel = 4'b1001; // BLTU (unsigned)
                    3'b111: alu_sel = 4'b1001; // BGEU (unsigned, inverted)
                endcase
            end

            // JAL (Jump and Link)
            7'b1101111: begin
                jump      = 1'b1;
                reg_write = 1'b1;  // write PC+4 to rd
                imm_sel   = 3'b011; // J-type immediate
                alu_sel   = 4'b0010; // ADD for PC calculation
            end

            // JALR (Jump and Link Register)
            7'b1100111: begin
                jump      = 1'b1;
                reg_write = 1'b1;  // write PC+4 to rd
                alu_src   = 1'b1;  // use immediate
                imm_sel   = 3'b000; // I-type immediate
                alu_sel   = 4'b0010; // ADD
            end

            // LUI (Load Upper Immediate)
            7'b0110111: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_sel   = 3'b100; // U-type immediate
                alu_sel   = 4'b0010; // ADD (just pass immediate)
            end

            // AUIPC (Add Upper Immediate to PC)
            7'b0010111: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_pc_src = 1'b1;  // Use PC as operand A
                imm_sel   = 3'b100; // U-type immediate
                alu_sel   = 4'b0010; // ADD
            end

            default: begin
                // NOP or unknown instruction
                alu_sel    = 4'b1111;
                alu_src    = 1'b0;
                alu_pc_src = 1'b0;
                reg_write  = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                branch     = 1'b0;
                jump       = 1'b0;
                imm_sel    = 3'b000;
            end
        endcase
    end

endmodule


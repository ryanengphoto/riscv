/*
Author: Ryan Eng

RISC-V Control Unit
Decodes RISC-V instructions and generates control signals
Supports: R-type, I-type, S-type, B-type, U-type, J-type
*/

`timescale 1ns / 1ps
`include "alu_defs.svh"

/*
Commands to add for Zbb:
andn - AND with inverted operand
orn - OR with inverted operand
xnor - XOR with inverted operand
clz - Count Leading Zeros
ctz - Count Trailing Zeros
cpop - Count set bits
max - Maximum
maxu - Maximum Unsigned
min - Minimum
minu - Minimum Unsigned
sext.b - Sign extend byte
sext.h - Sign extend halfword
zext.h - Zero extend halfword
rol - Rotate Left register
ror - Rotate Right register
rori - Rotate Right immediate
orc.b - bitwise or combine
rev8 - reverse byte
*/

module control_unit(
    input  logic [31:0] instruction,
    output logic [4:0]  alu_sel,         // ALU operation select
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
        alu_sel    = 5'b0;
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
            // R-type instructions (RV32I + Zbb)
            7'b0110011: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                mem_to_reg = 1'b0;
                imm_sel   = 3'b000; // not used
                
                case (funct7)
                    // Standard RV32I R-type
                    7'b0000000: begin
                        case (funct3)
                            3'b000: alu_sel = ALU_ADD;  // ADD
                            3'b001: alu_sel = ALU_SLL;  // SLL
                            3'b010: alu_sel = ALU_SLT;  // SLT
                            3'b011: alu_sel = ALU_SLTU; // SLTU
                            3'b100: alu_sel = ALU_XOR;  // XOR
                            3'b101: alu_sel = ALU_SRL;  // SRL
                            3'b110: alu_sel = ALU_OR;   // OR
                            3'b111: alu_sel = ALU_AND;  // AND
                        endcase
                    end
                    
                    // SUB, SRA + Zbb (ANDN, ORN, XNOR)
                    7'b0100000: begin
                        case (funct3)
                            3'b000: alu_sel = ALU_SUB;  // SUB
                            3'b100: alu_sel = ALU_XNOR; // XNOR (Zbb)
                            3'b101: alu_sel = ALU_SRA;  // SRA
                            3'b110: alu_sel = ALU_ORN;  // ORN (Zbb)
                            3'b111: alu_sel = ALU_ANDN; // ANDN (Zbb)
                            default: alu_sel = ALU_NOP;
                        endcase
                    end
                    
                    // Zbb: MIN/MAX family
                    7'b0000101: begin
                        case (funct3)
                            3'b100: alu_sel = ALU_MIN;  // MIN
                            3'b101: alu_sel = ALU_MINU; // MINU
                            3'b110: alu_sel = ALU_MAX;  // MAX
                            3'b111: alu_sel = ALU_MAXU; // MAXU
                            default: alu_sel = ALU_NOP;
                        endcase
                    end
                    
                    // Zbb: ROL, ROR (register)
                    7'b0110000: begin
                        case (funct3)
                            3'b001: alu_sel = ALU_ROL;  // ROL
                            3'b101: alu_sel = ALU_ROR;  // ROR
                            default: alu_sel = ALU_NOP;
                        endcase
                    end
                    
                    // Zbb: ZEXT.H (encoded as PACK with rs2=x0)
                    7'b0000100: begin
                        if (funct3 == 3'b100)
                            alu_sel = ALU_ZEXTH; // ZEXT.H
                        else
                            alu_sel = ALU_NOP;
                    end
                    
                    default: alu_sel = ALU_NOP;
                endcase
            end

            // I-type ALU instructions (RV32I + Zbb)
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;  // use immediate
                mem_to_reg = 1'b0;
                imm_sel   = 3'b000; // I-type immediate
                
                case (funct3)
                    3'b000: alu_sel = ALU_ADD;  // ADDI
                    3'b010: alu_sel = ALU_SLT;  // SLTI
                    3'b011: alu_sel = ALU_SLTU; // SLTIU
                    3'b100: alu_sel = ALU_XOR;  // XORI
                    3'b110: alu_sel = ALU_OR;   // ORI
                    3'b111: alu_sel = ALU_AND;  // ANDI
                    
                    // Shift and Zbb unary operations
                    3'b001: begin
                        case (funct7)
                            7'b0000000: alu_sel = ALU_SLL;  // SLLI
                            // Zbb unary ops (use rs2 field to distinguish)
                            7'b0110000: begin
                                case (instruction[24:20])  // rs2 field
                                    5'b00000: alu_sel = ALU_CLZ;   // CLZ
                                    5'b00001: alu_sel = ALU_CTZ;   // CTZ
                                    5'b00010: alu_sel = ALU_CPOP;  // CPOP
                                    5'b00100: alu_sel = ALU_SEXTB; // SEXT.B
                                    5'b00101: alu_sel = ALU_SEXTH; // SEXT.H
                                    default:  alu_sel = ALU_NOP;
                                endcase
                            end
                            default: alu_sel = ALU_NOP;
                        endcase
                    end
                    
                    3'b101: begin
                        case (funct7)
                            7'b0000000: alu_sel = ALU_SRL;  // SRLI
                            7'b0100000: alu_sel = ALU_SRA;  // SRAI
                            7'b0110000: alu_sel = ALU_ROR;  // RORI (Zbb)
                            7'b0010100: alu_sel = ALU_ORCB; // ORC.B (Zbb)
                            7'b0110100: alu_sel = ALU_REV8; // REV8 (Zbb)
                            default:    alu_sel = ALU_NOP;
                        endcase
                    end
                    
                    default: alu_sel = ALU_NOP;
                endcase
            end

            // Load instructions (LB, LH, LW, LBU, LHU)
            7'b0000011: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;  // use immediate for address calculation
                mem_read  = 1'b1;
                mem_to_reg = 1'b1; // load from memory
                alu_sel   = ALU_ADD; // ADD for address calculation
                imm_sel   = 3'b000; // I-type immediate
            end

            // Store instructions (SB, SH, SW)
            7'b0100011: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;  // use immediate for address calculation
                alu_sel   = ALU_ADD; // ADD for address calculation
                imm_sel   = 3'b001; // S-type immediate
            end

            // Branch instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            7'b1100011: begin
                branch    = 1'b1;
                alu_src   = 1'b0;  // compare registers
                imm_sel   = 3'b010; // B-type immediate
                
                case (funct3)
                    3'b000: alu_sel = ALU_SUB;  // BEQ (use SUB, check zero)
                    3'b001: alu_sel = ALU_SUB;  // BNE (use SUB, check not zero)
                    3'b100: alu_sel = ALU_SLT;  // BLT (signed)
                    3'b101: alu_sel = ALU_SLT;  // BGE (signed, inverted)
                    3'b110: alu_sel = ALU_SLTU; // BLTU (unsigned)
                    3'b111: alu_sel = ALU_SLTU; // BGEU (unsigned, inverted)
                    default: alu_sel = ALU_NOP;
                endcase
            end

            // JAL (Jump and Link)
            7'b1101111: begin
                jump      = 1'b1;
                reg_write = 1'b1;  // write PC+4 to rd
                imm_sel   = 3'b011; // J-type immediate
                alu_sel   = ALU_ADD; // ADD for PC calculation
            end

            // JALR (Jump and Link Register)
            7'b1100111: begin
                jump      = 1'b1;
                reg_write = 1'b1;  // write PC+4 to rd
                alu_src   = 1'b1;  // use immediate
                imm_sel   = 3'b000; // I-type immediate
                alu_sel   = ALU_ADD; // ADD
            end

            // LUI (Load Upper Immediate)
            7'b0110111: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_sel   = 3'b100; // U-type immediate
                alu_sel   = ALU_ADD; // ADD (just pass immediate)
            end

            // AUIPC (Add Upper Immediate to PC)
            7'b0010111: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_pc_src = 1'b1;  // Use PC as operand A
                imm_sel   = 3'b100; // U-type immediate
                alu_sel   = ALU_ADD; // ADD
            end

            default: begin
                // NOP or unknown instruction
                alu_sel    = ALU_NOP;
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


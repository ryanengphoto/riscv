/*
Author: Ryan Eng

RISC-V Control Unit
Decodes RISC-V instructions and generates control signals

Supported Instruction Sets:
  - RV32I Base: R-type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
                I-type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
                Loads (LB, LH, LW, LBU, LHU)
                Stores (SB, SH, SW)
                Branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)
                JAL, JALR
                LUI, AUIPC
  - Zbb Bit Manipulation Extension: ANDN, ORN, XNOR, MIN, MINU, MAX, MAXU
                                     ROL, ROR, RORI
                                     CLZ, CTZ, CPOP
                                     SEXT.B, SEXT.H, ZEXT.H
                                     ORC.B, REV8

ASIC Version - LibreLane compatible
*/

`timescale 1ns / 1ps
`include "alu_defs.svh"
`include "riscv_defs.svh"

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
            OPCODE_OP: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                mem_to_reg = 1'b0;
                imm_sel   = IMM_TYPE_I;
                
                case (funct7)
                    // Standard RV32I R-type
                    FUNCT7_BASE: begin
                        case (funct3)
                            FUNCT3_ADD_SUB: alu_sel = ALU_ADD;
                            FUNCT3_SLL:     alu_sel = ALU_SLL;
                            FUNCT3_SLT:     alu_sel = ALU_SLT;
                            FUNCT3_SLTU:    alu_sel = ALU_SLTU;
                            FUNCT3_XOR:     alu_sel = ALU_XOR;
                            FUNCT3_SRL_SRA: alu_sel = ALU_SRL;
                            FUNCT3_OR:      alu_sel = ALU_OR;
                            FUNCT3_AND:     alu_sel = ALU_AND;
                            default:        alu_sel = ALU_NOP;
                        endcase
                    end
                    
                    // SUB, SRA + Zbb (ANDN, ORN, XNOR)
                    FUNCT7_SUB_SRA: begin
                        case (funct3)
                            FUNCT3_ADD_SUB: alu_sel = ALU_SUB;
                            FUNCT3_XOR:     alu_sel = ALU_XNOR;
                            FUNCT3_SRL_SRA: alu_sel = ALU_SRA;
                            FUNCT3_OR:      alu_sel = ALU_ORN;
                            FUNCT3_AND:     alu_sel = ALU_ANDN;
                            default:        alu_sel = ALU_NOP;
                        endcase
                    end
                    
                    // Zbb: MIN/MAX family
                    FUNCT7_MIN_MAX: begin
                        case (funct3)
                            FUNCT3_XOR: alu_sel = ALU_MIN;
                            FUNCT3_SRL_SRA: alu_sel = ALU_MINU;
                            FUNCT3_OR:  alu_sel = ALU_MAX;
                            FUNCT3_AND: alu_sel = ALU_MAXU;
                            default:    alu_sel = ALU_NOP;
                        endcase
                    end
                    
                    // Zbb: ROL, ROR (register)
                    FUNCT7_ROL_ROR: begin
                        case (funct3)
                            FUNCT3_SLL:     alu_sel = ALU_ROL;
                            FUNCT3_SRL_SRA: alu_sel = ALU_ROR;
                            default:        alu_sel = ALU_NOP;
                        endcase
                    end
                    
                    // Zbb: ZEXT.H
                    FUNCT7_ZEXTH: begin
                        if (funct3 == FUNCT3_XOR)
                            alu_sel = ALU_ZEXTH;
                        else
                            alu_sel = ALU_NOP;
                    end
                    
                    default: alu_sel = ALU_NOP;
                endcase
            end

            // I-type ALU instructions (RV32I + Zbb)
            OPCODE_OP_IMM: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                mem_to_reg = 1'b0;
                imm_sel   = IMM_TYPE_I;
                
                case (funct3)
                    FUNCT3_ADD_SUB: alu_sel = ALU_ADD;
                    FUNCT3_SLT:    alu_sel = ALU_SLT;
                    FUNCT3_SLTU:   alu_sel = ALU_SLTU;
                    FUNCT3_XOR:    alu_sel = ALU_XOR;
                    FUNCT3_OR:     alu_sel = ALU_OR;
                    FUNCT3_AND:    alu_sel = ALU_AND;
                    
                    // Shift and Zbb unary operations
                    FUNCT3_SLL: begin
                        case (funct7)
                            FUNCT7_BASE: alu_sel = ALU_SLL;
                            // Zbb unary ops (shamt field distinguishes operation)
                            FUNCT7_ROL_ROR: begin
                                case (instruction[24:20])
                                    SHAMT_CLZ:   alu_sel = ALU_CLZ;
                                    SHAMT_CTZ:   alu_sel = ALU_CTZ;
                                    SHAMT_CPOP:  alu_sel = ALU_CPOP;
                                    SHAMT_SEXTB: alu_sel = ALU_SEXTB;
                                    SHAMT_SEXTH: alu_sel = ALU_SEXTH;
                                    default:     alu_sel = ALU_NOP;
                                endcase
                            end
                            default: alu_sel = ALU_NOP;
                        endcase
                    end
                    
                    FUNCT3_SRL_SRA: begin
                        case (funct7)
                            FUNCT7_BASE:     alu_sel = ALU_SRL;
                            FUNCT7_SUB_SRA:  alu_sel = ALU_SRA;
                            FUNCT7_ROL_ROR:  alu_sel = ALU_ROR;
                            FUNCT7_ORCB:     alu_sel = ALU_ORCB;
                            FUNCT7_REV8:     alu_sel = ALU_REV8;
                            default:         alu_sel = ALU_NOP;
                        endcase
                    end
                    
                    default: alu_sel = ALU_NOP;
                endcase
            end

            // Load instructions (LB, LH, LW, LBU, LHU)
            OPCODE_LOAD: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                mem_read  = 1'b1;
                mem_to_reg = 1'b1;
                alu_sel   = ALU_ADD;
                imm_sel   = IMM_TYPE_I;
            end

            // Store instructions (SB, SH, SW)
            OPCODE_STORE: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_sel   = ALU_ADD;
                imm_sel   = IMM_TYPE_S;
            end

            // Branch instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            // Branch comparison done in ID stage by branch_comparator module
            OPCODE_BRANCH: begin
                branch    = 1'b1;
                alu_src   = 1'b0;
                alu_sel   = ALU_NOP;
                imm_sel   = IMM_TYPE_B;
            end

            // JAL (Jump and Link)
            OPCODE_JAL: begin
                jump      = 1'b1;
                reg_write = 1'b1;
                imm_sel   = IMM_TYPE_J;
                alu_sel   = ALU_ADD;
            end

            // JALR (Jump and Link Register)
            OPCODE_JALR: begin
                jump      = 1'b1;
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_sel   = IMM_TYPE_I;
                alu_sel   = ALU_ADD;
            end

            // LUI (Load Upper Immediate)
            OPCODE_LUI: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_sel   = IMM_TYPE_U;
                alu_sel   = ALU_ADD;
            end

            // AUIPC (Add Upper Immediate to PC)
            OPCODE_AUIPC: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_pc_src = 1'b1;
                imm_sel   = IMM_TYPE_U;
                alu_sel   = ALU_ADD;
            end

            default: begin
                // Unknown instruction - treat as NOP
                alu_sel    = ALU_NOP;
                alu_src    = 1'b0;
                alu_pc_src = 1'b0;
                reg_write  = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                branch     = 1'b0;
                jump       = 1'b0;
                imm_sel    = IMM_TYPE_I;
            end
        endcase
    end

endmodule



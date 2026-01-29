/*
Author: Ryan Eng

RISC-V Instruction Format Definitions
Shared header file for instruction decoding
*/

`ifndef RISC_V_DEFS_SVH
`define RISC_V_DEFS_SVH

// =====================
// Opcodes (7-bit)
// =====================
localparam logic [6:0] OPCODE_LOAD     = 7'b0000011;  // Load instructions (LB, LH, LW, LBU, LHU)
localparam logic [6:0] OPCODE_MISC_MEM = 7'b0001111;  // FENCE, FENCE.I (not implemented)
localparam logic [6:0] OPCODE_OP_IMM   = 7'b0010011;  // I-type ALU (ADDI, SLTI, XORI, ORI, ANDI, SLLI, SRLI, SRAI + Zbb)
localparam logic [6:0] OPCODE_AUIPC    = 7'b0010111;  // AUIPC
localparam logic [6:0] OPCODE_STORE    = 7'b0100011;  // Store instructions (SB, SH, SW)
localparam logic [6:0] OPCODE_OP       = 7'b0110011;  // R-type ALU (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND + Zbb)
localparam logic [6:0] OPCODE_LUI      = 7'b0110111;  // LUI
localparam logic [6:0] OPCODE_BRANCH   = 7'b1100011;  // Branch instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
localparam logic [6:0] OPCODE_JALR     = 7'b1100111;  // JALR
localparam logic [6:0] OPCODE_JAL      = 7'b1101111;  // JAL
localparam logic [6:0] OPCODE_SYSTEM   = 7'b1110011;  // ECALL, EBREAK, etc. (not implemented)

// =====================
// Funct7 Values (7-bit)
// =====================
localparam logic [6:0] FUNCT7_BASE     = 7'b0000000;  // Standard RV32I R-type (ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND)
localparam logic [6:0] FUNCT7_SUB_SRA  = 7'b0100000;  // SUB, SRA + Zbb (ANDN, ORN, XNOR)
localparam logic [6:0] FUNCT7_MIN_MAX  = 7'b0000101;  // Zbb: MIN, MINU, MAX, MAXU
localparam logic [6:0] FUNCT7_ROL_ROR  = 7'b0110000;  // Zbb: ROL, ROR (register), RORI, CLZ, CTZ, CPOP, SEXT.B, SEXT.H
localparam logic [6:0] FUNCT7_ZEXTH    = 7'b0000100;  // Zbb: ZEXT.H
localparam logic [6:0] FUNCT7_ORCB    = 7'b0010100;  // Zbb: ORC.B
localparam logic [6:0] FUNCT7_REV8     = 7'b0110100;  // Zbb: REV8

// =====================
// Funct3 Values (3-bit)
// =====================
// Arithmetic/Logical operations
localparam logic [2:0] FUNCT3_ADD_SUB  = 3'b000;  // ADD, SUB, ADDI
localparam logic [2:0] FUNCT3_SLL      = 3'b001;  // SLL, SLLI, ROL
localparam logic [2:0] FUNCT3_SLT      = 3'b010;  // SLT, SLTI
localparam logic [2:0] FUNCT3_SLTU     = 3'b011;  // SLTU, SLTIU
localparam logic [2:0] FUNCT3_XOR      = 3'b100;  // XOR, XORI, XNOR, MIN, MINU, ZEXT.H
localparam logic [2:0] FUNCT3_SRL_SRA  = 3'b101;  // SRL, SRA, SRLI, SRAI, ROR, RORI
localparam logic [2:0] FUNCT3_OR       = 3'b110;  // OR, ORI, ORN, MAX, MAXU
localparam logic [2:0] FUNCT3_AND      = 3'b111;  // AND, ANDI, ANDN

// Load/Store size
localparam logic [2:0] FUNCT3_BYTE    = 3'b000;  // LB, LBU, SB
localparam logic [2:0] FUNCT3_HALF    = 3'b001;  // LH, LHU, SH
localparam logic [2:0] FUNCT3_WORD    = 3'b010;  // LW, SW

// Branch conditions
localparam logic [2:0] FUNCT3_BEQ     = 3'b000;  // BEQ
localparam logic [2:0] FUNCT3_BNE     = 3'b001;  // BNE
localparam logic [2:0] FUNCT3_BLT    = 3'b100;  // BLT
localparam logic [2:0] FUNCT3_BGE    = 3'b101;  // BGE
localparam logic [2:0] FUNCT3_BLTU   = 3'b110;  // BLTU
localparam logic [2:0] FUNCT3_BGEU   = 3'b111;  // BGEU

// =====================
// Immediate Type Selectors (3-bit)
// =====================
localparam logic [2:0] IMM_TYPE_I     = 3'b000;  // I-type: ADDI, Load, JALR
localparam logic [2:0] IMM_TYPE_S     = 3'b001;  // S-type: Store
localparam logic [2:0] IMM_TYPE_B     = 3'b010;  // B-type: Branch
localparam logic [2:0] IMM_TYPE_J     = 3'b011;  // J-type: JAL
localparam logic [2:0] IMM_TYPE_U     = 3'b100;  // U-type: LUI, AUIPC

// =====================
// Zbb Shamt Field Values (5-bit)
// =====================
localparam logic [4:0] SHAMT_CLZ      = 5'b00000;  // CLZ
localparam logic [4:0] SHAMT_CTZ      = 5'b00001;  // CTZ
localparam logic [4:0] SHAMT_CPOP     = 5'b00010;  // CPOP
localparam logic [4:0] SHAMT_SEXTB    = 5'b00100;  // SEXT.B
localparam logic [4:0] SHAMT_SEXTH    = 5'b00101;  // SEXT.H

`endif // RISC_V_DEFS_SVH


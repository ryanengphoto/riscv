/*
Author: Ryan Eng

ALU Operation Definitions for RISC-V CPU
Shared header file for control_unit.sv and alu_core.sv
*/

`ifndef ALU_DEFS_SVH
`define ALU_DEFS_SVH

// =====================
// ALU Operation Codes (5-bit)
// =====================

// RV32I Base Operations (0b00000-0b01111)
localparam logic [4:0] ALU_AND  = 5'b00000;  // 0x00
localparam logic [4:0] ALU_OR   = 5'b00001;  // 0x01
localparam logic [4:0] ALU_ADD  = 5'b00010;  // 0x02
localparam logic [4:0] ALU_XOR  = 5'b00011;  // 0x03
localparam logic [4:0] ALU_SLL  = 5'b00100;  // 0x04
localparam logic [4:0] ALU_SRL  = 5'b00101;  // 0x05
localparam logic [4:0] ALU_SUB  = 5'b00110;  // 0x06
localparam logic [4:0] ALU_SRA  = 5'b00111;  // 0x07
localparam logic [4:0] ALU_SLT  = 5'b01000;  // 0x08
localparam logic [4:0] ALU_SLTU = 5'b01001;  // 0x09
localparam logic [4:0] ALU_NOR  = 5'b01010;  // 0x0A - Custom
localparam logic [4:0] ALU_INC  = 5'b01011;  // 0x0B - Custom
localparam logic [4:0] ALU_DEC  = 5'b01100;  // 0x0C - Custom
localparam logic [4:0] ALU_ROL  = 5'b01101;  // 0x0D - Zbb: ROL
localparam logic [4:0] ALU_ROR  = 5'b01110;  // 0x0E - Zbb: ROR/RORI
localparam logic [4:0] ALU_NOP  = 5'b01111;  // 0x0F

// Zbb Extension Operations (0b10000-0b11111)
localparam logic [4:0] ALU_ANDN   = 5'b10000;  // 0x10 - Zbb: AND with NOT
localparam logic [4:0] ALU_ORN    = 5'b10001;  // 0x11 - Zbb: OR with NOT
localparam logic [4:0] ALU_XNOR   = 5'b10010;  // 0x12 - Zbb: XOR with NOT
localparam logic [4:0] ALU_CLZ    = 5'b10011;  // 0x13 - Zbb: Count Leading Zeros
localparam logic [4:0] ALU_CTZ    = 5'b10100;  // 0x14 - Zbb: Count Trailing Zeros
localparam logic [4:0] ALU_CPOP   = 5'b10101;  // 0x15 - Zbb: Population Count
localparam logic [4:0] ALU_MIN    = 5'b10110;  // 0x16 - Zbb: Minimum (signed)
localparam logic [4:0] ALU_MAX    = 5'b10111;  // 0x17 - Zbb: Maximum (signed)
localparam logic [4:0] ALU_SEXTB  = 5'b11000;  // 0x18 - Zbb: Sign-extend byte
localparam logic [4:0] ALU_SEXTH  = 5'b11001;  // 0x19 - Zbb: Sign-extend halfword
localparam logic [4:0] ALU_ZEXTH  = 5'b11010;  // 0x1A - Zbb: Zero-extend halfword
localparam logic [4:0] ALU_ORCB   = 5'b11011;  // 0x1B - Zbb: OR Combine bytes
localparam logic [4:0] ALU_REV8   = 5'b11100;  // 0x1C - Zbb: Byte-reverse
localparam logic [4:0] ALU_MINU   = 5'b11101;  // 0x1D - Zbb: Minimum (unsigned)
localparam logic [4:0] ALU_MAXU   = 5'b11110;  // 0x1E - Zbb: Maximum (unsigned)

`endif // ALU_DEFS_SVH



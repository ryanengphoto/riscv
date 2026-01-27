/*
Author: Ryan Eng 

This module contains the logic for the ALU itself
Purely combinational block for RISC-V CPU
Supports RV32I base + Zbb (Bitmanip Basic) extension

ASIC Version - OpenLane compatible
*/

`timescale 1ns / 1ps
`include "alu_defs.svh"

module alu_core(
    input  logic [4:0]  alu_sel,    // 5-bit ALU select for Zbb extension support
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    output logic [31:0] result
);

    // =====================
    // Combinational ALU logic
    // =====================
    always_comb begin
        // default assignment
        result = '0;

        case (alu_sel)

            // ================================ //
            // RV32I Base Operations (0x00-0x0F)
            // ================================ //

            // AND operation (0x00)
            ALU_AND: begin
                result = operand_a & operand_b; 
            end

            // OR operation (0x01)
            ALU_OR: begin
                result = operand_a | operand_b; 
            end    

            // ADD operation (0x02)
            ALU_ADD: begin
                result = operand_a + operand_b; 
            end       

            // XOR operation (0x03)
            ALU_XOR: begin
                result = operand_a ^ operand_b; 
            end

            // SLL - Shift Left Logical (0x04)
            ALU_SLL: begin
                result = operand_a << operand_b[4:0]; 
            end

            // SRL - Shift Right Logical (0x05)
            ALU_SRL: begin
                result = operand_a >> operand_b[4:0]; 
            end    

            // SUB operation (0x06)
            ALU_SUB: begin
                result = operand_a - operand_b;
            end

            // SRA - Shift Right Arithmetic (0x07)
            ALU_SRA: begin
                result = $signed(operand_a) >>> operand_b[4:0]; 
            end

            // SLT - Set Less Than, signed (0x08)
            ALU_SLT: begin
                result = ($signed(operand_a) < $signed(operand_b)) ? 32'b1 : 32'b0;
            end    

            // SLTU - Set Less Than, unsigned (0x09)
            ALU_SLTU: begin
                result = (operand_a < operand_b) ? 32'b1 : 32'b0;
            end

            // NOR operation (0x0A) - Custom
            ALU_NOR: begin
                result = ~(operand_a | operand_b); 
            end
            
            // INC - Increment (0x0B) - Custom
            ALU_INC: begin
                result = operand_a + 32'b1; 
            end    
                    
            // DEC - Decrement (0x0C) - Custom
            ALU_DEC: begin
                result = operand_a - 32'b1; 
            end 
    
            // ROL - Rotate Left (0x0D) - Zbb
            ALU_ROL: begin
                result = (operand_a << operand_b[4:0]) | (operand_a >> (32 - operand_b[4:0])); 
            end 
    
            // ROR - Rotate Right (0x0E) - Zbb
            ALU_ROR: begin
                result = (operand_a >> operand_b[4:0]) | (operand_a << (32 - operand_b[4:0])); 
            end   

            // NOP (0x0F)
            ALU_NOP: begin
                result = '0;
            end           

            // ================================ //
            // Zbb Extension Operations (0x10-0x1E)
            // ================================ //

            // ANDN - AND with inverted operand (0x10)
            ALU_ANDN: begin
                result = operand_a & ~operand_b;
            end

            // ORN - OR with inverted operand (0x11)
            ALU_ORN: begin
                result = operand_a | ~operand_b;
            end

            // XNOR - Exclusive NOR (0x12)
            ALU_XNOR: begin
                result = ~(operand_a ^ operand_b);
            end

            // CLZ - Count Leading Zeros (0x13)
            ALU_CLZ: begin
                result = 32; // Default if no '1' is found
                for (int i = 0; i <= 31; i++) begin
                    if (operand_a[i]) begin
                        result = 31 - i;
                    end
                end
            end

            // CTZ - Count Trailing Zeros (0x14)
            ALU_CTZ: begin
                result = 32; // Default if no '1' is found
                for (int i = 31; i >= 0; i--) begin
                    if (operand_a[i]) begin
                        result = i;
                    end
                end
            end

            // CPOP - Population Count (0x15)
            ALU_CPOP: begin
                result = $countones(operand_a);
            end

            // MIN - Minimum signed (0x16)
            ALU_MIN: begin
                result = ($signed(operand_a) < $signed(operand_b)) ? operand_a : operand_b;
            end

            // MAX - Maximum signed (0x17)
            ALU_MAX: begin
                result = ($signed(operand_a) > $signed(operand_b)) ? operand_a : operand_b;
            end

            // SEXT.B - Sign-extend byte (0x18)
            ALU_SEXTB: begin
                result = {{24{operand_a[7]}}, operand_a[7:0]};
            end

            // SEXT.H - Sign-extend halfword (0x19)
            ALU_SEXTH: begin
                result = {{16{operand_a[15]}}, operand_a[15:0]};
            end

            // ZEXT.H - Zero-extend halfword (0x1A)
            ALU_ZEXTH: begin
                result = {16'b0, operand_a[15:0]};
            end

            // ORC.B - OR Combine bytes (0x1B)
            // If any bit in a byte is set, set all bits in that byte to 1
            ALU_ORCB: begin
                result[7:0]   = |operand_a[7:0]   ? 8'hFF : 8'h00;
                result[15:8]  = |operand_a[15:8]  ? 8'hFF : 8'h00;
                result[23:16] = |operand_a[23:16] ? 8'hFF : 8'h00;
                result[31:24] = |operand_a[31:24] ? 8'hFF : 8'h00;
            end

            // REV8 - Byte reverse (0x1C)
            ALU_REV8: begin
                result = {operand_a[7:0], operand_a[15:8], operand_a[23:16], operand_a[31:24]};
            end

            // MINU - Minimum unsigned (0x1D)
            ALU_MINU: begin
                result = (operand_a < operand_b) ? operand_a : operand_b;
            end

            // MAXU - Maximum unsigned (0x1E)
            ALU_MAXU: begin
                result = (operand_a > operand_b) ? operand_a : operand_b;
            end

            // ================================ //
            // Default case
            // ================================ //
            default: begin
                result = '0;
            end

        endcase
    end

endmodule



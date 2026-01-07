/*
Author: Ryan Eng 

This module contains the logic for the ALU itself
Purely combinational block for RISC-V CPU
*/

`timescale 1ns / 1ps

module alu_core(
    input  logic [3:0]  alu_sel,
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

        unique case (alu_sel)

            // ******************************** //
            // AND operation (opcode 0x0)
            // ******************************** //
            4'b0000: begin
                result = operand_a & operand_b; 
            end

            // ******************************** //
            // OR operation (opcode 0x1)
            // ******************************** //
            4'b0001: begin
                result = operand_a | operand_b; 
            end    

            // ******************************** //
            // ADD operation (opcode 0x2)
            // ******************************** //
            4'b0010: begin
                result = operand_a + operand_b; 
            end       

            // ******************************** //
            // XOR operation (opcode 0x3)
            // ******************************** //
            4'b0011: begin
                result = operand_a ^ operand_b; 
            end

            // ******************************** //
            // SLL (Shift Left Logical) (opcode 0x4)
            // ******************************** //
            4'b0100: begin
                result = operand_a << operand_b[4:0]; 
            end

            // ******************************** //
            // SRL (Shift Right Logical) (opcode 0x5)
            // ******************************** //
            4'b0101: begin
                result = operand_a >> operand_b[4:0]; 
            end    

            // ******************************** //
            // SUB operation (opcode 0x6)
            // ******************************** //
            4'b0110: begin
                result = operand_a - operand_b;
            end

            // ******************************** //
            // SRA (Shift Right Arithmetic) (opcode 0x7)
            // ******************************** //
            4'b0111: begin
                result = $signed(operand_a) >>> operand_b[4:0]; 
            end

            // ******************************** //
            // SLT (Set Less Than, signed) (opcode 0x8)
            // ******************************** //
            4'b1000: begin
                result = ($signed(operand_a) < $signed(operand_b)) ? 32'b1 : 32'b0;
            end    

            // ******************************** //
            // SLTU (Set Less Than, unsigned) (opcode 0x9)
            // ******************************** //
            4'b1001: begin
                result = (operand_a < operand_b) ? 32'b1 : 32'b0;
            end

            // ******************************** //
            // NOR operation (opcode 0xA)
            // ******************************** //
            4'b1010: begin
                result = ~(operand_a | operand_b); 
            end
            
            // ******************************** //
            // INC (Increment) (opcode 0xB)
            // ******************************** //
            4'b1011: begin
                result = operand_a + 32'b1; 
            end    
                    
            // ******************************** //
            // DEC (Decrement) (opcode 0xC)
            // ******************************** //
            4'b1100: begin
                result = operand_a - 32'b1; 
            end 
    
            // ******************************** //
            // ROL (Rotate Left) (opcode 0xD)
            // ******************************** //
            4'b1101: begin
                result = (operand_a << operand_b[4:0]) | (operand_a >> (32 - operand_b[4:0])); 
            end 
    
            // ******************************** //
            // ROR (Rotate Right) (opcode 0xE)
            // ******************************** //
            4'b1110: begin
                result = (operand_a >> operand_b[4:0]) | (operand_a << (32 - operand_b[4:0])); 
            end   

            // ******************************** //
            // RESERVED / NOP (opcode 0xF)
            // ******************************** //
            4'b1111: begin
                result = '0; // no operation
            end           

            // ******************************** //
            // Default case
            // ******************************** //
            default: begin
                result = '0;
            end

        endcase
    end

endmodule

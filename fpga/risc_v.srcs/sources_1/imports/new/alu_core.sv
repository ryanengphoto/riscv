/*
Author: Ryan Eng 

This module contains the logic for the ALU itself
*/

`timescale 1ns / 1ps

module alu_core(
    input  logic        clk,
    input  logic        rst,
    input  logic [3:0]  alu_sel,
    input  logic [13:0] in_a,
    input  logic [13:0] in_b,
    input  logic        data_ready,
    output logic [31:0] out,
    output logic        data_valid
);

    // =====================
    // Internal signals
    // =====================
    logic [31:0] alu_result;
    logic valid_internal; // used to delay data_valid

    // =====================
    // Initialization
    // =====================
    initial begin
        out        = 32'b0;
        data_valid = 1'b0;
    end

    // =====================
    // Sequential logic
    // =====================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_internal <= '0;
            out        <= '0;
            data_valid <= 1'b0;
        end 
        else if (data_ready) begin
            out <= alu_result;
            valid_internal <= 1;
        end
        else if (valid_internal) begin
            data_valid <= 1;
            valid_internal <= 0;
        end
        else begin
            valid_internal = 0;
            data_valid <= 0;
        end
    end

    // =====================
    // Combinational ALU logic
    // =====================
    always_comb begin
        // default assignments
        alu_result = '0;

        // extend all to 32 bits for now
        unique case (alu_sel)

            // ******************************** //
            // AND operation (opcode 0x0)
            // ******************************** //
            4'b0000: begin
                alu_result = {18'b0, in_a} & {18'b0, in_b}; 
            end

            // ******************************** //
            // OR operation (opcode 0x1)
            // ******************************** //
            4'b0001: begin
                alu_result = {18'b0, in_a} | {18'b0, in_b}; 
            end    

            // ******************************** //
            // ADD operation (opcode 0x2)
            // ******************************** //
            4'b0010: begin
                alu_result = {18'b0, in_a} + {18'b0, in_b}; 
            end       

            // ******************************** //
            // XOR operation (opcode 0x3)
            // ******************************** //
            4'b0011: begin
                alu_result = {18'b0, in_a} ^ {18'b0, in_b}; 
            end

            // ******************************** //
            // SLL (Shift Left Logical) (opcode 0x4)
            // ******************************** //
            4'b0100: begin
                alu_result = {18'b0, in_a} << (in_b & 5'h1F); 
            end

            // ******************************** //
            // SRL (Shift Right Logical) (opcode 0x5)
            // ******************************** //
            4'b0101: begin
                alu_result = {18'b0, in_a} >> (in_b & 5'h1F); 
            end    

            // ******************************** //
            // SUB operation (opcode 0x6)
            // ******************************** //
            4'b0110: begin
                alu_result = {18'b0, in_a} - {18'b0, in_b};
            end

            // ******************************** //
            // SRA (Shift Right Arithmetic) (opcode 0x7)
            // ******************************** //
            4'b0111: begin
                alu_result = $signed(in_a) >>> (in_b & 5'h1F); 
            end

            // ******************************** //
            // SLT (Set Less Than, signed) (opcode 0x8)
            // ******************************** //
            4'b1000: begin
                alu_result = ($signed(in_a) < $signed(in_b)) ? 32'b1 : 32'b0;
            end    

            // ******************************** //
            // SLTU (Set Less Than, unsigned) (opcode 0x9)
            // ******************************** //
            4'b1001: begin
                alu_result = ({18'b0, in_a} < {18'b0, in_b}) ? 32'b1 : 32'b0;
            end

            // ******************************** //
            // NOR operation (opcode 0xA)
            // ******************************** //
            4'b1010: begin
                alu_result = ~({18'b0, in_a} | {18'b0, in_b}); 
            end
            
            // ******************************** //
            // INC (Increment) (opcode 0xB)
            // ******************************** //
            4'b1011: begin
                alu_result = {18'b0, in_a} + 1'b1; 
            end    
                    
            // ******************************** //
            // DEC (Decrement) (opcode 0xC)
            // ******************************** //
            4'b1100: begin
                alu_result = {18'b0, in_a} - 1'b1; 
            end 
    
            // ******************************** //
            // ROL (Rotate Left) (opcode 0xD)
            // ******************************** //
            4'b1101: begin
                alu_result = ({18'b0, in_a} << (in_b & 5'h1F)) | ({18'b0, in_a} >> (32 - (in_b & 5'h1F))); 
            end 
    
            // ******************************** //
            // ROR (Rotate Right) (opcode 0xE)
            // ******************************** //
            4'b1110: begin
                alu_result = ({18'b0, in_a} >> (in_b & 5'h1F)) | ({18'b0, in_a} << (32 - (in_b & 5'h1F))); 
            end   

            // ******************************** //
            // RESERVED / NOP (opcode 0xF)
            // ******************************** //
            4'b1111: begin
                alu_result = '0; // no operation
            end           

            // ******************************** //
            // Default case
            // ******************************** //
            default: begin
                alu_result = '0;
                data_valid = 1'b0;
            end

        endcase
    end

endmodule

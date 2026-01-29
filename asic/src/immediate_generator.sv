/*
Author: Ryan Eng

RISC-V Immediate Generator
Extracts and sign-extends immediates from instruction based on type

ASIC Version - LibreLane compatible
*/

`timescale 1ns / 1ps

module immediate_generator(
    input  logic [31:0] instruction,
    input  logic [2:0]  imm_sel,         // immediate type select
    output logic [31:0] immediate
);

    always_comb begin
        case (imm_sel)
            // I-type: [31:20] -> sign extended
            3'b000: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-type: [31:25][11:7] -> sign extended
            3'b001: begin
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // B-type: [31][30:25][11:8][7] -> sign extended, bit 0 = 0
            3'b010: begin
                immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end

            // J-type: [31][19:12][20][30:21][11] -> sign extended, bit 0 = 0
            3'b011: begin
                immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end

            // U-type: [31:12] -> zero extended (upper 20 bits)
            3'b100: begin
                immediate = {instruction[31:12], 12'b0};
            end

            default: begin
                immediate = 32'b0;
            end
        endcase
    end

endmodule



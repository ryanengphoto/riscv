/*
Author: Ryan Eng

Branch Control Unit
Determines if branch should be taken based on ALU result and funct3
*/

`timescale 1ns / 1ps

module branch_control(
    input  logic [31:0] alu_result,     // ALU result (SUB for BEQ/BNE, SLT/SLTU for others)
    input  logic [2:0]  funct3,         // instruction funct3 field
    output logic        branch_taken
);

    always_comb begin
        case (funct3)
            // BEQ: rs1 == rs2 (ALU does SUB, result == 0)
            3'b000: begin
                branch_taken = (alu_result == 32'b0);
            end

            // BNE: rs1 != rs2 (ALU does SUB, result != 0)
            3'b001: begin
                branch_taken = (alu_result != 32'b0);
            end

            // BLT: rs1 < rs2 (signed) - ALU does SLT, result[0] == 1 if taken
            3'b100: begin
                branch_taken = (alu_result[0] == 1'b1);
            end

            // BGE: rs1 >= rs2 (signed) - ALU does SLT, result[0] == 0 if taken (inverted)
            3'b101: begin
                branch_taken = (alu_result[0] == 1'b0);
            end

            // BLTU: rs1 < rs2 (unsigned) - ALU does SLTU, result[0] == 1 if taken
            3'b110: begin
                branch_taken = (alu_result[0] == 1'b1);
            end

            // BGEU: rs1 >= rs2 (unsigned) - ALU does SLTU, result[0] == 0 if taken (inverted)
            3'b111: begin
                branch_taken = (alu_result[0] == 1'b0);
            end

            default: begin
                branch_taken = 1'b0;
            end
        endcase
    end

endmodule


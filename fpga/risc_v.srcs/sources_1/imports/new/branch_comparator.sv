/*
Author: Ryan Eng

Branch Comparator for ID-stage branch resolution
Performs direct comparison of register values for branch decisions
This module operates in the ID stage for early branch resolution,
reducing the critical path by avoiding the ALU.
*/

`timescale 1ns / 1ps

module branch_comparator (
    input  logic [31:0] rs1_data,      // rs1 value (potentially forwarded)
    input  logic [31:0] rs2_data,      // rs2 value (potentially forwarded)
    input  logic [2:0]  funct3,        // branch type from instruction
    input  logic        is_branch,     // indicates this is a branch instruction
    output logic        branch_taken
);

    // Comparison results
    logic eq;
    logic lt_signed;
    logic lt_unsigned;
    
    // Direct comparisons (no ALU needed)
    assign eq          = (rs1_data == rs2_data);
    assign lt_signed   = $signed(rs1_data) < $signed(rs2_data);
    assign lt_unsigned = rs1_data < rs2_data;
    
    // Branch decision based on funct3
    always_comb begin
        if (!is_branch) begin
            branch_taken = 1'b0;
        end else begin
            case (funct3)
                3'b000:  branch_taken = eq;            // BEQ: rs1 == rs2
                3'b001:  branch_taken = ~eq;           // BNE: rs1 != rs2
                3'b100:  branch_taken = lt_signed;     // BLT: rs1 < rs2 (signed)
                3'b101:  branch_taken = ~lt_signed;    // BGE: rs1 >= rs2 (signed)
                3'b110:  branch_taken = lt_unsigned;   // BLTU: rs1 < rs2 (unsigned)
                3'b111:  branch_taken = ~lt_unsigned;  // BGEU: rs1 >= rs2 (unsigned)
                default: branch_taken = 1'b0;
            endcase
        end
    end

endmodule


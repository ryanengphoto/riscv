/*
Author: Ryan Eng

RISC-V Register File
32 registers (x0-x31), where x0 is hardwired to 0
2 read ports, 1 write port
*/

`timescale 1ns / 1ps

module register_file(
    input  logic        clk,
    input  logic        rst,
    input  logic        we,              // write enable
    input  logic [4:0]  raddr1,          // read address 1
    input  logic [4:0]  raddr2,          // read address 2
    input  logic [4:0]  waddr,           // write address
    input  logic [31:0] wdata,           // write data
    output logic [31:0] rdata1,          // read data 1
    output logic [31:0] rdata2           // read data 2
);

    // Register file: 32 registers of 32 bits each
    logic [31:0] registers [0:31];

    // =====================
    // Read ports (combinational)
    // =====================
    always_comb begin
        rdata1 = (raddr1 == 5'b0) ? 32'b0 : registers[raddr1];
        rdata2 = (raddr2 == 5'b0) ? 32'b0 : registers[raddr2];
    end

    // =====================
    // Write port (sequential)
    // =====================
    integer i;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (we && (waddr != 5'b0)) begin
            // x0 is hardwired to 0, cannot be written
            registers[waddr] <= wdata;
        end
    end

endmodule


/*
Author: Ryan Eng

RISC-V Register File
32 registers (x0-x31), where x0 is hardwired to 0
4 read ports (2 for ID stage, 2 for EX stage), 1 write port

ASIC Version - OpenLane compatible
*/

`timescale 1ns / 1ps

module register_file(
    input  logic        clk,
    input  logic        rst,
    input  logic        we,              // write enable
    input  logic [4:0]  raddr1,          // read address 1 (ID stage)
    input  logic [4:0]  raddr2,          // read address 2 (ID stage)
    input  logic [4:0]  raddr3,          // read address 3 (EX stage)
    input  logic [4:0]  raddr4,          // read address 4 (EX stage)
    input  logic [4:0]  waddr,           // write address
    input  logic [31:0] wdata,           // write data
    output logic [31:0] rdata1,          // read data 1 (ID stage)
    output logic [31:0] rdata2,          // read data 2 (ID stage)
    output logic [31:0] rdata3,          // read data 3 (EX stage)
    output logic [31:0] rdata4           // read data 4 (EX stage)
);

    // Register file: 32 registers of 32 bits each
    logic [31:0] registers [0:31];

    // =====================
    // Read ports (combinational)
    // =====================
    always_comb begin
        rdata1 = (raddr1 == 5'b0) ? 32'b0 : registers[raddr1];
        rdata2 = (raddr2 == 5'b0) ? 32'b0 : registers[raddr2];
        rdata3 = (raddr3 == 5'b0) ? 32'b0 : registers[raddr3];
        rdata4 = (raddr4 == 5'b0) ? 32'b0 : registers[raddr4];
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



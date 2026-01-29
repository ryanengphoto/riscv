// Gate-level timing testbench for riscv_cpu with SDF annotation (CVC-compatible)

`timescale 1ns/1ps

module tb_riscv_gate;

  // Clock / reset
  reg clk;
  reg rst;

  // DUT interface
  wire [31:0] imem_addr;
  reg  [31:0] imem_data;

  wire        dmem_read;
  wire        dmem_write;
  wire [31:0] dmem_addr;
  wire [31:0] dmem_wdata;
  reg  [31:0] dmem_rdata;

  // Simple instruction / data memories
  reg [31:0] imem [0:255];
  reg [31:0] dmem [0:1023];

  // Clock: 100 MHz (10 ns period)
  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    $sdf_annotate("/home/rye20/riscv/asic/runs/RUN_2026-01-23_13-10-42/final/sdf/nom_tt_025C_1v80/riscv_cpu__nom_tt_025C_1v80.sdf", dut);
  end

  // Reset sequence
  initial begin
    rst = 1'b1;
    #100;
    rst = 1'b0;
  end

  // Initialize memories
  integer i;
  initial begin
    // Default IMEM to NOP (ADDI x0, x0, 0)
    for (i = 0; i < 256; i = i + 1)
      imem[i] = 32'h00000013;

    // Default DMEM to 0
    for (i = 0; i < 1024; i = i + 1)
      dmem[i] = 32'h00000000;

    // Optionally preload a program:
    // $readmemh("imem.hex", imem);
  end

  // Instruction memory read (combinational)
  always @* begin
    imem_data = imem[imem_addr[31:2]];
  end

  // Data memory write (sequential)
  always @(posedge clk) begin
    if (dmem_write)
      dmem[dmem_addr[31:2]] <= dmem_wdata;
  end

  // Data memory read (combinational)
  always @* begin
    if (dmem_read)
      dmem_rdata = dmem[dmem_addr[31:2]];
    else
      dmem_rdata = 32'h00000000;
  end

  // DUT instance; instance name "dut" used by SDF annotation
  riscv_cpu dut (
    .clk       (clk),
    .rst       (rst),
    .imem_addr (imem_addr),
    .imem_data (imem_data),
    .dmem_read (dmem_read),
    .dmem_write(dmem_write),
    .dmem_addr (dmem_addr),
    .dmem_wdata(dmem_wdata),
    .dmem_rdata(dmem_rdata)
  );

  // Wave dump
  initial begin
    $dumpfile("tb_riscv_gate.vcd");
    $dumpvars(0, tb_riscv_gate);
  end

  // Simple timeout
  initial begin
    #1000000;  // 1 ms at 100 MHz; adjust as needed
    $display("Timeout reached, finishing gate-level SDF sim.");
    $finish;
  end

endmodule



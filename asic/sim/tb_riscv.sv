`timescale 1ns / 1ps
// =============================================================================
// RISC-V CPU Testbench - Main Driver (ASIC Version)
// =============================================================================
// This is the main test runner that includes and executes all test tasks.
// Individual test implementations are in the tests/ directory.
// =============================================================================

`include "common_tasks.svh"

module tb_riscv();

    // =========================================================================
    // Test Statistics
    // =========================================================================
    static int checked, errors;

    // =========================================================================
    // DUT Interface Signals
    // =========================================================================
    logic clk;
    logic rst;
    logic [31:0] imem_addr;
    logic [31:0] imem_data;
    logic dmem_read;
    logic dmem_write;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic [31:0] dmem_rdata;

    // =========================================================================
    // Memory Models
    // =========================================================================
    
    // Instruction memory (64 words)
    logic [31:0] instruction_mem [0:63];
    
    // Data memory (1024 words)
    logic [31:0] data_mem [0:1023];
    
    // Initialize memories
    initial begin
        for (int i = 0; i < 64; i++) begin
            instruction_mem[i] = 32'h00000013; // ADDI x0, x0, 0 (NOP)
        end
        for (int i = 0; i < 1024; i++) begin
            data_mem[i] = 32'h0;
        end
    end

    // Instruction memory read (combinational)
    always_comb begin
        if (imem_addr[31:2] < 64) begin
            imem_data = instruction_mem[imem_addr[31:2]];
        end else begin
            imem_data = 32'h00000013; // NOP for out-of-range
        end
    end

    // Data memory write (synchronous)
    always_ff @(posedge clk) begin
        if (dmem_write && (dmem_addr[31:2] < 1024)) begin
            data_mem[dmem_addr[31:2]] <= dmem_wdata;
        end
    end

    // Data memory read (combinational)
    always_comb begin
        if (dmem_read && (dmem_addr[31:2] < 1024)) begin
            dmem_rdata = data_mem[dmem_addr[31:2]];
        end else begin
            dmem_rdata = 32'h0;
        end
    end

    // =========================================================================
    // DUT Instantiation
    // =========================================================================
    riscv_cpu u_riscv_cpu (
        .clk(clk),
        .rst(rst),
        .imem_addr(imem_addr),
        .imem_data(imem_data),
        .dmem_read(dmem_read),
        .dmem_write(dmem_write),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_rdata(dmem_rdata)
    );

    // =========================================================================
    // Clock Generation
    // =========================================================================
    initial clk = 1'b0;
    always #5 clk = ~clk;  // 100MHz clock (10ns period)

    // =========================================================================
    // Include Test Tasks
    // =========================================================================
    `include "tests/test_basic_arithmetic.svh"
    `include "tests/test_load_use_hazard.svh"
    `include "tests/test_zbb_operations.svh"
    `include "tests/test_branch_forwarding.svh"
    `include "tests/test_jal_return_address.svh"

    // =========================================================================
    // Main Test Sequence
    // =========================================================================
    initial begin
        // VCD dump for waveform analysis
        $dumpfile("tb_riscv.vcd");
        $dumpvars(0, tb_riscv);
        
        // Initialize
        checked = 0;
        errors = 0;
        
        $display("=============================================================");
        $display("    RISC-V CPU ASIC Testbench - Starting Tests");
        $display("=============================================================\n");

        // =====================
        // Test 1: Basic Arithmetic
        // =====================
        rst = 1'b1;
        #10;
        rst = 1'b0;
        test_basic_arithmetic();
        
        // =====================
        // Test 2: Load-Use Hazard
        // =====================
        rst = 1'b1;
        #20;
        rst = 1'b0;
        test_load_use_hazard();
        
        // =====================
        // Test 3: Zbb Operations
        // =====================
        rst = 1'b1;
        #20;
        rst = 1'b0;
        test_zbb_operations();
        
        // =====================
        // Test 4: Branch Forwarding
        // =====================
        rst = 1'b1;
        #20;
        rst = 1'b0;
        test_branch_forwarding();
        
        // =====================
        // Test 5: JAL Return Address
        // =====================
        rst = 1'b1;
        #20;
        rst = 1'b0;
        test_jal_return_address();

        // =====================
        // Summary
        // =====================
        $display("\n=============================================================");
        $display("                      Test Summary");
        $display("=============================================================");
        $display("  Total Checks: %0d", checked);
        $display("  Passed:       %0d", checked - errors);
        $display("  Failed:       %0d", errors);
        $display("=============================================================\n");
        
        if (errors) begin
            display_fail();
        end else begin
            display_pass();
        end
        
        $finish;
    end

endmodule



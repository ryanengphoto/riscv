`timescale 1ns / 1ps
`include "common_tasks.svh"

module tb_riscv(
    );

    // tb pass/fail signals
    static int checked, errors;

    // riscv cpu interface signals
    logic clk;
    logic rst;
    logic [31:0] imem_addr;
    logic [31:0] imem_data;
    logic dmem_read;
    logic dmem_write;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic [31:0] dmem_rdata;

    // Instruction memory (simple model)
    logic [31:0] instruction_mem [0:15];
    initial begin
        for (int i = 0; i < 16; i++) begin
            instruction_mem[i] = 32'h00000013; // ADDI x0, x0, 0 (NOP)
        end
    end

    // Instruction memory interface
    always_comb begin
        if (imem_addr[31:2] < 16) begin
            imem_data = instruction_mem[imem_addr[31:2]];
        end else begin
            imem_data = 32'h00000013; // NOP
        end
    end

    // Data memory (simple model)
    logic [31:0] data_mem [0:1023];
    initial begin
        for (int i = 0; i < 1024; i++) begin
            data_mem[i] = 32'h0;
        end
    end

    always_ff @(posedge clk) begin
        if (dmem_write && (dmem_addr[31:2] < 1024)) begin
            data_mem[dmem_addr[31:2]] <= dmem_wdata;
        end
    end

    always_comb begin
        if (dmem_read && (dmem_addr[31:2] < 1024)) begin
            dmem_rdata = data_mem[dmem_addr[31:2]];
        end else begin
            dmem_rdata = 32'h0;
        end
    end

    // riscv cpu module
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

    initial begin
        // Test reset
        clk = 1'b0;
        rst = 1'b1;
        #10;
        rst = 1'b0;

        test_basic_arithmetic();

        $display("Checked: %d | Errors: %d", checked, errors);
        if (errors) begin
            display_fail();
        end
        else begin
            display_pass();
        end
        $finish;
    end

    always #5 clk = ~clk;

    task automatic test_basic_arithmetic();
        // Variable declarations
        logic [11:0] imm_value;
        logic [4:0]  rs1_addr;
        logic [2:0]  funct3;
        logic [4:0]  rd_addr;
        logic [6:0]  opcode;
        
        $display("Testing ADD 0 + 1...");
        
        // ADDI x1, x0, <immediate>  : Add x0 (0) + immediate, store result in x1
        // Format: {imm[11:0], rs1, funct3, rd, opcode}
        imm_value = 12'd3;        // Change this to modify immediate value
        rs1_addr  = 5'b00000;     // x0
        funct3    = 3'b000;       // ADDI
        rd_addr   = 5'b00001;     // x1
        opcode    = 7'b0010011;   // I-type ALU opcode
        
        instruction_mem[0] = {imm_value, rs1_addr, funct3, rd_addr, opcode}; // ADDI x1, x0, imm_value
        
        // Wait for pipeline to execute
        #100;
        
        $display("ALU should show: operand_a=0, operand_b=1, result=1");
        checked++;
    endtask
endmodule

// Author: Ryan Eng
// UART TX module with 16x oversampling

`timescale 1ns / 1ps
`include "typedefs.svh"

module uart_tx (
    input  logic clk,
    input  logic rst,
    input  logic tick16,
    input  logic data_valid,
    input  logic [31:0] data, 
    output logic tx
);

    // -------------------------
    // Internal signals
    // -------------------------
    uart_state_t tx_state;
    logic [3:0]  sample_counter;   // 16× oversampled ticks per bit
    logic [2:0]  bit_counter;      // 0..7 per byte
    logic [1:0]  byte_counter;     // 0..3 per packet
    logic [31:0] tx_bits;          // full 4-byte packet
    logic        tx_bit;
    logic        data_valid_latched; 

    // Latch data_valid until baud tick
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            data_valid_latched <= 1'b0;
            tx_bits <= 32'd0;
        end else if (data_valid) begin
            data_valid_latched <= 1'b1;
            tx_bits <= data; 
        end else if (tx_state == STATE_START) begin
            // unlatch
            data_valid_latched <= 1'b0;
        end
    end

    assign tx = tx_bit;

    // -------------------------
    // TX FSM
    // -------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_state       <= STATE_IDLE;
            sample_counter <= 4'd0;
            bit_counter    <= 3'd0;
            byte_counter   <= 2'd0;
            tx_bit         <= 1'b1;
        end else if (tick16) begin
            case (tx_state)
                STATE_IDLE: begin
                    tx_bit <= 1'b1;
                    sample_counter <= 0;
                    bit_counter    <= 0;
                    byte_counter   <= 0;

                    if (data_valid_latched) begin
                        tx_state <= STATE_START;
                    end
                end

                STATE_START: begin
                    tx_bit <= 1'b0; // start bit
                    sample_counter <= sample_counter + 1;
                    if (sample_counter == 4'd15) begin
                        sample_counter <= 0;
                        bit_counter    <= 0;
                        tx_state       <= STATE_PROCESSING;
                    end
                end

                STATE_PROCESSING: begin
                    tx_bit <= tx_bits[bit_counter + byte_counter*8];
                    sample_counter <= sample_counter + 1;
                    if (sample_counter == 4'd15) begin
                        sample_counter <= 0;
                        if (bit_counter == 3'd7) begin // final data bit of byte
                            bit_counter <= 0;
                            tx_state <= STATE_DONE; 
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                end

                STATE_DONE: begin
                    tx_bit <= 1'b1; // stop bit
                    sample_counter <= sample_counter + 1;
                    if (sample_counter == 4'd15) begin
                        sample_counter <= 0;
                        byte_counter <= byte_counter + 1;

                        if (byte_counter == 2'd3) begin
                            tx_state <= STATE_IDLE; // full packet done
                        end else begin
                            tx_state <= STATE_START; // next byte
                        end
                    end
                end
            endcase
        end
    end

endmodule

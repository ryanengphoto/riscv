// Author: Ryan Eng
// 16x oversampling UART RX integrated in ALU block

`timescale 1ns / 1ps
`include "typedefs.svh"

module alu_block #(
    parameter int CLK_FRQ = 100_000_000,
    parameter int BPS     = 115_200
)(
    input  logic clk,
    input  logic rst,
    input  logic rx,
    input  logic sw,
    output logic tx,
    output logic led,
    output logic led2, led3, led4, led5
);

    // -------------------------
    // Internal signals
    // -------------------------
    int packet_counter;    // bit counter within byte
    int message_counter;   // byte counter within packet
    uart_state_t uart_state;
    alu_packet_t alu_packet;
    logic [31:0] packet_bits;

    logic rx_sync1, rx_sync2;
    logic tick16;

    assign led = sw;

    // ALU signals
    logic [31:0] out;
    logic        data_ready, data_valid;

    assign alu_packet.in_a    = packet_bits[31:18];
    assign alu_packet.in_b    = packet_bits[17:4];
    assign alu_packet.alu_sel = packet_bits[3:0];

    alu_core u_alu_core (
        .clk(clk),
        .rst(rst),
        .alu_sel(alu_packet.alu_sel),
        .in_a(alu_packet.in_a),
        .in_b(alu_packet.in_b),
        .data_ready(data_ready),
        .out(out),
        .data_valid(data_valid)
    );

    // -------------------------
    // 16x Baud Generator
    // -------------------------
    baud16_gen #(
        .CLK_FREQ(CLK_FRQ),
        .BAUD(BPS)
    ) u_baud16 (
        .clk(clk),
        .rst(rst),
        .tick16(tick16)
    );

    uart_tx u_uart_tx (
        .clk(clk),
        .rst(rst),
        .tick16(tick16),
        .data_valid(data_valid),
        .data(out),
        .tx(tx)
    );

    // -------------------------
    // RX Synchronizers
    // -------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end else begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
        end
    end

    // -------------------------
    // 16x Oversampling UART FSM
    // -------------------------
    int sample_counter; // counts 16 samples per bit
    logic bit_value;    // sampled bit

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            uart_state      <= STATE_IDLE;
            packet_counter  <= 0;
            message_counter <= 0;
            sample_counter  <= 0;
            packet_bits     <= 0;
            data_ready      <= 0;
            led2 <= 1; led3 <= 0; led4 <= 0; led5 <= 0;
        end else if (tick16) begin
            case (uart_state)
                STATE_IDLE: begin
                    data_ready <= 0;
                    sample_counter <= 0;
                    if (~rx_sync2) begin // detect start bit
                        uart_state <= STATE_START;
                        led2 <= 0;
                    end
                end

                STATE_START: begin
                    sample_counter <= sample_counter + 1;
                    if (sample_counter == 7) begin // sample middle of start bit (half of 16)
                        if (~rx_sync2) begin
                            sample_counter <= 0;
                            packet_counter <= 0;
                            uart_state <= STATE_PROCESSING;
                            led3 <= 1;
                        end else begin
                            uart_state <= STATE_IDLE; // false start bit
                            led2 <= 1;
                        end
                    end
                end

                STATE_PROCESSING: begin
                    sample_counter <= sample_counter + 1;
                    if (sample_counter == 15) begin // 16 samples per bit
                        bit_value <= rx_sync2;
                        packet_bits[packet_counter + message_counter*8] <= rx_sync2;
                        packet_counter <= packet_counter + 1;
                        sample_counter <= 0;

                        if (packet_counter == 8) begin
                            message_counter <= message_counter + 1;
                            packet_counter <= 0;
                            
                            if (message_counter == 3) begin
                                uart_state <= STATE_DONE;
                            end
                            else begin
                                uart_state <= STATE_IDLE;
                            end
                        end
                    end
                end

                STATE_DONE: begin
                    data_ready <= 1;
                    uart_state <= STATE_IDLE;
                    message_counter <= 0;
                    led4 <= 1;
                    led5 <= 1;
                end

            endcase
        end
    end

endmodule
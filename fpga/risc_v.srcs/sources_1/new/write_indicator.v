`timescale 1ns / 1ps
module write_indicator(
    input wire clk,
    input wire rst,
    input wire dmem_write,
    output wire led
    );

    reg led_reg;

    assign led = dmem_write | led_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_reg <= 1'b0;
        end else begin
            led_reg <= led;
        end
    end
endmodule

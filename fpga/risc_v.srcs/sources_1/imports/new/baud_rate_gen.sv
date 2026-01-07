module baud16_gen #(
    parameter int unsigned CLK_FREQ = 100_000_000,   // FPGA clock
    parameter int unsigned BAUD     = 115_200         // desired UART baud
)(
    input  logic clk,
    input  logic rst,
    output logic tick16              // 16× baud tick
);

    // divisor = clk / (baud × 16)
    localparam int DIVISOR = CLK_FREQ / (BAUD * 16);

    logic [$clog2(DIVISOR)-1:0] cnt;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt    <= 0;
            tick16 <= 0;
        end else begin
            if (cnt == DIVISOR-1) begin
                cnt    <= 0;
                tick16 <= 1;
            end else begin
                cnt    <= cnt + 1;
                tick16 <= 0;
            end
        end
    end

endmodule

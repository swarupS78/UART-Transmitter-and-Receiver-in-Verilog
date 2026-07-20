module UART_top #(
    parameter CLKS_PER_BIT = 217
)(
    input clk,
    input rst,

    input load,
    input [7:0] tx_data,
    output tx,

    input rx,
    output [7:0] rx_data
);

    UART_TX #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) tx_inst (
        .clk(clk),
        .rst(rst),
        .load(load),
        .data(tx_data),
        .tx(tx)
    );

    UART_RX #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data(rx_data)
    );

endmodule

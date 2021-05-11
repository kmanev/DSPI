`timescale 1ns / 1ps
module BlockerTestSuccessful(
    input clk,
    input [7:0] EtoWbusIn,
    output reg [7:0] EtoWbusOut,
    input [7:0] WtoEbusIn,
    output reg [7:0] WtoEbusOut
    );
    always @ (posedge clk) begin
        EtoWbusOut <= EtoWbusIn;
        WtoEbusOut <= WtoEbusIn;
    end
endmodule

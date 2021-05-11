`timescale 1ns / 1ps
module BlockerTest(
    input clk,
    input [8:0] EtoWbusIn,
    output reg [8:0] EtoWbusOut,
    input [8:0] WtoEbusIn,
    output reg [8:0] WtoEbusOut
    );
    always @ (posedge clk) begin
        EtoWbusOut <= EtoWbusIn;
        WtoEbusOut <= WtoEbusIn;
    end
endmodule

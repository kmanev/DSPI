`timescale 1ns / 1ps
module WestCon(
    input clk,
    output reg [7:0] WtoEbusIn,
    input [7:0] EtoWbusOut
    );
(* mark_debug = "true", keep = "true" *)reg [7:0] WtoEbusIn_src;
(* mark_debug = "true", keep = "true" *)reg [7:0] EtoWbusOut_dst;

    always @ (posedge clk) begin
        WtoEbusIn <= WtoEbusIn_src;
        EtoWbusOut_dst <= EtoWbusOut;
    end
endmodule

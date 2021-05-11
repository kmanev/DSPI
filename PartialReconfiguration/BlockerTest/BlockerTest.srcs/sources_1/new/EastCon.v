`timescale 1ns / 1ps
module EastCon(
    input clk,
    output reg [8:0] EtoWbusIn,
    input [8:0] WtoEbusOut
    );
    
(* mark_debug = "true", keep = "true" *)reg [8:0] EtoWbusIn_src;
(* mark_debug = "true", keep = "true" *)reg [8:0] WtoEbusOut_dst;
    always @ (posedge clk) begin
        EtoWbusIn <= EtoWbusIn_src;
        WtoEbusOut_dst <= WtoEbusOut;
    end
endmodule

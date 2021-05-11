// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Tue May 11 15:15:31 2021
// Host        : DESKTOP-47LU6A1 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/prruns/BlockerTestSuccessful/BlockerTestSuccessful.srcs/sources_1/bd/bd/ip/bd_WestCon_0_0/bd_WestCon_0_0_stub.v
// Design      : bd_WestCon_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "WestCon,Vivado 2020.1" *)
module bd_WestCon_0_0(clk, WtoEbusIn, EtoWbusOut)
/* synthesis syn_black_box black_box_pad_pin="clk,WtoEbusIn[7:0],EtoWbusOut[7:0]" */;
  input clk;
  output [7:0]WtoEbusIn;
  input [7:0]EtoWbusOut;
endmodule

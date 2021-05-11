// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Tue May 11 13:48:21 2021
// Host        : DESKTOP-47LU6A1 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bd_WestCon_0_0_sim_netlist.v
// Design      : bd_WestCon_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_WestCon
   (WtoEbusIn,
    clk,
    EtoWbusOut);
  output [8:0]WtoEbusIn;
  input clk;
  input [8:0]EtoWbusOut;

  wire [8:0]EtoWbusOut;
  (* MARK_DEBUG *) (* RTL_KEEP = "true" *) wire [8:0]EtoWbusOut_dst;
  wire [8:0]WtoEbusIn;
  (* MARK_DEBUG *) (* RTL_KEEP = "true" *) wire [8:0]WtoEbusIn_src;
  wire clk;

  (* KEEP = "yes" *) 
  FDRE \EtoWbusOut_dst_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusOut[0]),
        .Q(EtoWbusOut_dst[0]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \EtoWbusOut_dst_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusOut[1]),
        .Q(EtoWbusOut_dst[1]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \EtoWbusOut_dst_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusOut[2]),
        .Q(EtoWbusOut_dst[2]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \EtoWbusOut_dst_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusOut[3]),
        .Q(EtoWbusOut_dst[3]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \EtoWbusOut_dst_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusOut[4]),
        .Q(EtoWbusOut_dst[4]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \EtoWbusOut_dst_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusOut[5]),
        .Q(EtoWbusOut_dst[5]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \EtoWbusOut_dst_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusOut[6]),
        .Q(EtoWbusOut_dst[6]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \EtoWbusOut_dst_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusOut[7]),
        .Q(EtoWbusOut_dst[7]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \EtoWbusOut_dst_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusOut[8]),
        .Q(EtoWbusOut_dst[8]),
        .R(1'b0));
  FDRE \WtoEbusIn_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn_src[0]),
        .Q(WtoEbusIn[0]),
        .R(1'b0));
  FDRE \WtoEbusIn_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn_src[1]),
        .Q(WtoEbusIn[1]),
        .R(1'b0));
  FDRE \WtoEbusIn_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn_src[2]),
        .Q(WtoEbusIn[2]),
        .R(1'b0));
  FDRE \WtoEbusIn_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn_src[3]),
        .Q(WtoEbusIn[3]),
        .R(1'b0));
  FDRE \WtoEbusIn_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn_src[4]),
        .Q(WtoEbusIn[4]),
        .R(1'b0));
  FDRE \WtoEbusIn_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn_src[5]),
        .Q(WtoEbusIn[5]),
        .R(1'b0));
  FDRE \WtoEbusIn_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn_src[6]),
        .Q(WtoEbusIn[6]),
        .R(1'b0));
  FDRE \WtoEbusIn_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn_src[7]),
        .Q(WtoEbusIn[7]),
        .R(1'b0));
  FDRE \WtoEbusIn_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn_src[8]),
        .Q(WtoEbusIn[8]),
        .R(1'b0));
  LUT1 #(
    .INIT(2'h2)) 
    insti_0
       (.I0(1'b0),
        .O(WtoEbusIn_src[8]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_1
       (.I0(1'b0),
        .O(WtoEbusIn_src[7]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_2
       (.I0(1'b0),
        .O(WtoEbusIn_src[6]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_3
       (.I0(1'b0),
        .O(WtoEbusIn_src[5]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_4
       (.I0(1'b0),
        .O(WtoEbusIn_src[4]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_5
       (.I0(1'b0),
        .O(WtoEbusIn_src[3]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_6
       (.I0(1'b0),
        .O(WtoEbusIn_src[2]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_7
       (.I0(1'b0),
        .O(WtoEbusIn_src[1]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_8
       (.I0(1'b0),
        .O(WtoEbusIn_src[0]));
endmodule

(* CHECK_LICENSE_TYPE = "bd_WestCon_0_0,WestCon,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "WestCon,Vivado 2020.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clk,
    WtoEbusIn,
    EtoWbusOut);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, FREQ_HZ 99990005, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN bd_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input clk;
  output [8:0]WtoEbusIn;
  input [8:0]EtoWbusOut;

  wire [8:0]EtoWbusOut;
  wire [8:0]WtoEbusIn;
  wire clk;

  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_WestCon inst
       (.EtoWbusOut(EtoWbusOut),
        .WtoEbusIn(WtoEbusIn),
        .clk(clk));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif

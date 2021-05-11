// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Tue May 11 15:15:30 2021
// Host        : DESKTOP-47LU6A1 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bd_EastCon_0_0_sim_netlist.v
// Design      : bd_EastCon_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_EastCon
   (EtoWbusIn,
    clk,
    WtoEbusOut);
  output [7:0]EtoWbusIn;
  input clk;
  input [7:0]WtoEbusOut;

  wire [7:0]EtoWbusIn;
  (* MARK_DEBUG *) (* RTL_KEEP = "true" *) wire [7:0]EtoWbusIn_src;
  wire [7:0]WtoEbusOut;
  (* MARK_DEBUG *) (* RTL_KEEP = "true" *) wire [7:0]WtoEbusOut_dst;
  wire clk;

  FDRE \EtoWbusIn_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn_src[0]),
        .Q(EtoWbusIn[0]),
        .R(1'b0));
  FDRE \EtoWbusIn_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn_src[1]),
        .Q(EtoWbusIn[1]),
        .R(1'b0));
  FDRE \EtoWbusIn_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn_src[2]),
        .Q(EtoWbusIn[2]),
        .R(1'b0));
  FDRE \EtoWbusIn_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn_src[3]),
        .Q(EtoWbusIn[3]),
        .R(1'b0));
  FDRE \EtoWbusIn_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn_src[4]),
        .Q(EtoWbusIn[4]),
        .R(1'b0));
  FDRE \EtoWbusIn_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn_src[5]),
        .Q(EtoWbusIn[5]),
        .R(1'b0));
  FDRE \EtoWbusIn_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn_src[6]),
        .Q(EtoWbusIn[6]),
        .R(1'b0));
  FDRE \EtoWbusIn_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn_src[7]),
        .Q(EtoWbusIn[7]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \WtoEbusOut_dst_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusOut[0]),
        .Q(WtoEbusOut_dst[0]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \WtoEbusOut_dst_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusOut[1]),
        .Q(WtoEbusOut_dst[1]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \WtoEbusOut_dst_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusOut[2]),
        .Q(WtoEbusOut_dst[2]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \WtoEbusOut_dst_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusOut[3]),
        .Q(WtoEbusOut_dst[3]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \WtoEbusOut_dst_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusOut[4]),
        .Q(WtoEbusOut_dst[4]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \WtoEbusOut_dst_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusOut[5]),
        .Q(WtoEbusOut_dst[5]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \WtoEbusOut_dst_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusOut[6]),
        .Q(WtoEbusOut_dst[6]),
        .R(1'b0));
  (* KEEP = "yes" *) 
  FDRE \WtoEbusOut_dst_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusOut[7]),
        .Q(WtoEbusOut_dst[7]),
        .R(1'b0));
  LUT1 #(
    .INIT(2'h2)) 
    insti_0
       (.I0(1'b0),
        .O(EtoWbusIn_src[7]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_1
       (.I0(1'b0),
        .O(EtoWbusIn_src[6]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_2
       (.I0(1'b0),
        .O(EtoWbusIn_src[5]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_3
       (.I0(1'b0),
        .O(EtoWbusIn_src[4]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_4
       (.I0(1'b0),
        .O(EtoWbusIn_src[3]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_5
       (.I0(1'b0),
        .O(EtoWbusIn_src[2]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_6
       (.I0(1'b0),
        .O(EtoWbusIn_src[1]));
  LUT1 #(
    .INIT(2'h2)) 
    insti_7
       (.I0(1'b0),
        .O(EtoWbusIn_src[0]));
endmodule

(* CHECK_LICENSE_TYPE = "bd_EastCon_0_0,EastCon,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "EastCon,Vivado 2020.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clk,
    EtoWbusIn,
    WtoEbusOut);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, FREQ_HZ 99990005, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN bd_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input clk;
  output [7:0]EtoWbusIn;
  input [7:0]WtoEbusOut;

  wire [7:0]EtoWbusIn;
  wire [7:0]WtoEbusOut;
  wire clk;

  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_EastCon inst
       (.EtoWbusIn(EtoWbusIn),
        .WtoEbusOut(WtoEbusOut),
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

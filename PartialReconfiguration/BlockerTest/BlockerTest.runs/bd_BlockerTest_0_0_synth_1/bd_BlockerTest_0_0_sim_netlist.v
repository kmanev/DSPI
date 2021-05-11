// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Tue May 11 13:48:21 2021
// Host        : DESKTOP-47LU6A1 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bd_BlockerTest_0_0_sim_netlist.v
// Design      : bd_BlockerTest_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_BlockerTest
   (EtoWbusOut,
    WtoEbusOut,
    EtoWbusIn,
    clk,
    WtoEbusIn);
  output [8:0]EtoWbusOut;
  output [8:0]WtoEbusOut;
  input [8:0]EtoWbusIn;
  input clk;
  input [8:0]WtoEbusIn;

  wire [8:0]EtoWbusIn;
  wire [8:0]EtoWbusOut;
  wire [8:0]WtoEbusIn;
  wire [8:0]WtoEbusOut;
  wire clk;

  FDRE \EtoWbusOut_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn[0]),
        .Q(EtoWbusOut[0]),
        .R(1'b0));
  FDRE \EtoWbusOut_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn[1]),
        .Q(EtoWbusOut[1]),
        .R(1'b0));
  FDRE \EtoWbusOut_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn[2]),
        .Q(EtoWbusOut[2]),
        .R(1'b0));
  FDRE \EtoWbusOut_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn[3]),
        .Q(EtoWbusOut[3]),
        .R(1'b0));
  FDRE \EtoWbusOut_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn[4]),
        .Q(EtoWbusOut[4]),
        .R(1'b0));
  FDRE \EtoWbusOut_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn[5]),
        .Q(EtoWbusOut[5]),
        .R(1'b0));
  FDRE \EtoWbusOut_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn[6]),
        .Q(EtoWbusOut[6]),
        .R(1'b0));
  FDRE \EtoWbusOut_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn[7]),
        .Q(EtoWbusOut[7]),
        .R(1'b0));
  FDRE \EtoWbusOut_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(EtoWbusIn[8]),
        .Q(EtoWbusOut[8]),
        .R(1'b0));
  FDRE \WtoEbusOut_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn[0]),
        .Q(WtoEbusOut[0]),
        .R(1'b0));
  FDRE \WtoEbusOut_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn[1]),
        .Q(WtoEbusOut[1]),
        .R(1'b0));
  FDRE \WtoEbusOut_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn[2]),
        .Q(WtoEbusOut[2]),
        .R(1'b0));
  FDRE \WtoEbusOut_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn[3]),
        .Q(WtoEbusOut[3]),
        .R(1'b0));
  FDRE \WtoEbusOut_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn[4]),
        .Q(WtoEbusOut[4]),
        .R(1'b0));
  FDRE \WtoEbusOut_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn[5]),
        .Q(WtoEbusOut[5]),
        .R(1'b0));
  FDRE \WtoEbusOut_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn[6]),
        .Q(WtoEbusOut[6]),
        .R(1'b0));
  FDRE \WtoEbusOut_reg[7] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn[7]),
        .Q(WtoEbusOut[7]),
        .R(1'b0));
  FDRE \WtoEbusOut_reg[8] 
       (.C(clk),
        .CE(1'b1),
        .D(WtoEbusIn[8]),
        .Q(WtoEbusOut[8]),
        .R(1'b0));
endmodule

(* CHECK_LICENSE_TYPE = "bd_BlockerTest_0_0,BlockerTest,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "BlockerTest,Vivado 2020.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clk,
    EtoWbusIn,
    EtoWbusOut,
    WtoEbusIn,
    WtoEbusOut);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, FREQ_HZ 99990005, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN bd_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input clk;
  input [8:0]EtoWbusIn;
  output [8:0]EtoWbusOut;
  input [8:0]WtoEbusIn;
  output [8:0]WtoEbusOut;

  wire [8:0]EtoWbusIn;
  wire [8:0]EtoWbusOut;
  wire [8:0]WtoEbusIn;
  wire [8:0]WtoEbusOut;
  wire clk;

  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_BlockerTest inst
       (.EtoWbusIn(EtoWbusIn),
        .EtoWbusOut(EtoWbusOut),
        .WtoEbusIn(WtoEbusIn),
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

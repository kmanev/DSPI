//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
//Date        : Tue May 11 13:45:30 2021
//Host        : DESKTOP-47LU6A1 running 64-bit major release  (build 9200)
//Command     : generate_target bd.bd
//Design      : bd
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "bd,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=bd,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=4,numReposBlks=4,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=3,numPkgbdBlks=0,bdsource=USER,da_zynq_ultra_ps_e_cnt=1,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "bd.hwdef" *) 
module bd
   ();

  wire [8:0]BlockerTest_0_EtoWbusOut;
  wire [8:0]BlockerTest_0_WtoEbusOut;
  wire [8:0]EastCon_0_EtoWbusIn;
  wire [8:0]WestCon_0_WtoEbusIn;
  wire zynq_ultra_ps_e_0_pl_clk0;

  bd_BlockerTest_0_0 BlockerTest_0
       (.EtoWbusIn(EastCon_0_EtoWbusIn),
        .EtoWbusOut(BlockerTest_0_EtoWbusOut),
        .WtoEbusIn(WestCon_0_WtoEbusIn),
        .WtoEbusOut(BlockerTest_0_WtoEbusOut),
        .clk(zynq_ultra_ps_e_0_pl_clk0));
  bd_EastCon_0_0 EastCon_0
       (.EtoWbusIn(EastCon_0_EtoWbusIn),
        .WtoEbusOut(BlockerTest_0_WtoEbusOut),
        .clk(zynq_ultra_ps_e_0_pl_clk0));
  bd_WestCon_0_0 WestCon_0
       (.EtoWbusOut(BlockerTest_0_EtoWbusOut),
        .WtoEbusIn(WestCon_0_WtoEbusIn),
        .clk(zynq_ultra_ps_e_0_pl_clk0));
  bd_zynq_ultra_ps_e_0_0 zynq_ultra_ps_e_0
       (.pl_clk0(zynq_ultra_ps_e_0_pl_clk0),
        .pl_ps_irq0(1'b0));
endmodule

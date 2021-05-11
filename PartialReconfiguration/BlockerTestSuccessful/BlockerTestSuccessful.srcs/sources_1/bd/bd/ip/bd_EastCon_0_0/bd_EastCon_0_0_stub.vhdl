-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Tue May 11 15:15:31 2021
-- Host        : DESKTOP-47LU6A1 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/prruns/BlockerTestSuccessful/BlockerTestSuccessful.srcs/sources_1/bd/bd/ip/bd_EastCon_0_0/bd_EastCon_0_0_stub.vhdl
-- Design      : bd_EastCon_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bd_EastCon_0_0 is
  Port ( 
    clk : in STD_LOGIC;
    EtoWbusIn : out STD_LOGIC_VECTOR ( 7 downto 0 );
    WtoEbusOut : in STD_LOGIC_VECTOR ( 7 downto 0 )
  );

end bd_EastCon_0_0;

architecture stub of bd_EastCon_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,EtoWbusIn[7:0],WtoEbusOut[7:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "EastCon,Vivado 2020.1";
begin
end;

-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Tue May 11 13:48:21 2021
-- Host        : DESKTOP-47LU6A1 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bd_BlockerTest_0_0_stub.vhdl
-- Design      : bd_BlockerTest_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  Port ( 
    clk : in STD_LOGIC;
    EtoWbusIn : in STD_LOGIC_VECTOR ( 8 downto 0 );
    EtoWbusOut : out STD_LOGIC_VECTOR ( 8 downto 0 );
    WtoEbusIn : in STD_LOGIC_VECTOR ( 8 downto 0 );
    WtoEbusOut : out STD_LOGIC_VECTOR ( 8 downto 0 )
  );

end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,EtoWbusIn[8:0],EtoWbusOut[8:0],WtoEbusIn[8:0],WtoEbusOut[8:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "BlockerTest,Vivado 2020.1";
begin
end;
-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Tue May 11 15:15:30 2021
-- Host        : DESKTOP-47LU6A1 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bd_BlockerTestSuccessful_0_0_sim_netlist.vhdl
-- Design      : bd_BlockerTestSuccessful_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_BlockerTestSuccessful is
  port (
    EtoWbusOut : out STD_LOGIC_VECTOR ( 7 downto 0 );
    WtoEbusOut : out STD_LOGIC_VECTOR ( 7 downto 0 );
    EtoWbusIn : in STD_LOGIC_VECTOR ( 7 downto 0 );
    clk : in STD_LOGIC;
    WtoEbusIn : in STD_LOGIC_VECTOR ( 7 downto 0 )
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_BlockerTestSuccessful;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_BlockerTestSuccessful is
begin
\EtoWbusOut_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn(0),
      Q => EtoWbusOut(0),
      R => '0'
    );
\EtoWbusOut_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn(1),
      Q => EtoWbusOut(1),
      R => '0'
    );
\EtoWbusOut_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn(2),
      Q => EtoWbusOut(2),
      R => '0'
    );
\EtoWbusOut_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn(3),
      Q => EtoWbusOut(3),
      R => '0'
    );
\EtoWbusOut_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn(4),
      Q => EtoWbusOut(4),
      R => '0'
    );
\EtoWbusOut_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn(5),
      Q => EtoWbusOut(5),
      R => '0'
    );
\EtoWbusOut_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn(6),
      Q => EtoWbusOut(6),
      R => '0'
    );
\EtoWbusOut_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn(7),
      Q => EtoWbusOut(7),
      R => '0'
    );
\WtoEbusOut_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn(0),
      Q => WtoEbusOut(0),
      R => '0'
    );
\WtoEbusOut_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn(1),
      Q => WtoEbusOut(1),
      R => '0'
    );
\WtoEbusOut_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn(2),
      Q => WtoEbusOut(2),
      R => '0'
    );
\WtoEbusOut_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn(3),
      Q => WtoEbusOut(3),
      R => '0'
    );
\WtoEbusOut_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn(4),
      Q => WtoEbusOut(4),
      R => '0'
    );
\WtoEbusOut_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn(5),
      Q => WtoEbusOut(5),
      R => '0'
    );
\WtoEbusOut_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn(6),
      Q => WtoEbusOut(6),
      R => '0'
    );
\WtoEbusOut_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn(7),
      Q => WtoEbusOut(7),
      R => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  port (
    clk : in STD_LOGIC;
    EtoWbusIn : in STD_LOGIC_VECTOR ( 7 downto 0 );
    EtoWbusOut : out STD_LOGIC_VECTOR ( 7 downto 0 );
    WtoEbusIn : in STD_LOGIC_VECTOR ( 7 downto 0 );
    WtoEbusOut : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "bd_BlockerTestSuccessful_0_0,BlockerTestSuccessful,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "BlockerTestSuccessful,Vivado 2020.1";
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 clk CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clk : signal is "XIL_INTERFACENAME clk, FREQ_HZ 99990005, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN bd_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
begin
inst: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_BlockerTestSuccessful
     port map (
      EtoWbusIn(7 downto 0) => EtoWbusIn(7 downto 0),
      EtoWbusOut(7 downto 0) => EtoWbusOut(7 downto 0),
      WtoEbusIn(7 downto 0) => WtoEbusIn(7 downto 0),
      WtoEbusOut(7 downto 0) => WtoEbusOut(7 downto 0),
      clk => clk
    );
end STRUCTURE;

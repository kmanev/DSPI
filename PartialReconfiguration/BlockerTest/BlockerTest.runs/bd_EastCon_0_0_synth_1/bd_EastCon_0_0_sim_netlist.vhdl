-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Tue May 11 13:48:21 2021
-- Host        : DESKTOP-47LU6A1 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bd_EastCon_0_0_sim_netlist.vhdl
-- Design      : bd_EastCon_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_EastCon is
  port (
    EtoWbusIn : out STD_LOGIC_VECTOR ( 8 downto 0 );
    clk : in STD_LOGIC;
    WtoEbusOut : in STD_LOGIC_VECTOR ( 8 downto 0 )
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_EastCon;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_EastCon is
  signal EtoWbusIn_src : STD_LOGIC_VECTOR ( 8 downto 0 );
  attribute MARK_DEBUG : boolean;
  attribute MARK_DEBUG of EtoWbusIn_src : signal is std.standard.true;
  attribute RTL_KEEP : string;
  attribute RTL_KEEP of EtoWbusIn_src : signal is "true";
  signal WtoEbusOut_dst : STD_LOGIC_VECTOR ( 8 downto 0 );
  attribute MARK_DEBUG of WtoEbusOut_dst : signal is std.standard.true;
  attribute RTL_KEEP of WtoEbusOut_dst : signal is "true";
  attribute KEEP : string;
  attribute KEEP of \WtoEbusOut_dst_reg[0]\ : label is "yes";
  attribute KEEP of \WtoEbusOut_dst_reg[1]\ : label is "yes";
  attribute KEEP of \WtoEbusOut_dst_reg[2]\ : label is "yes";
  attribute KEEP of \WtoEbusOut_dst_reg[3]\ : label is "yes";
  attribute KEEP of \WtoEbusOut_dst_reg[4]\ : label is "yes";
  attribute KEEP of \WtoEbusOut_dst_reg[5]\ : label is "yes";
  attribute KEEP of \WtoEbusOut_dst_reg[6]\ : label is "yes";
  attribute KEEP of \WtoEbusOut_dst_reg[7]\ : label is "yes";
  attribute KEEP of \WtoEbusOut_dst_reg[8]\ : label is "yes";
begin
\EtoWbusIn_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn_src(0),
      Q => EtoWbusIn(0),
      R => '0'
    );
\EtoWbusIn_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn_src(1),
      Q => EtoWbusIn(1),
      R => '0'
    );
\EtoWbusIn_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn_src(2),
      Q => EtoWbusIn(2),
      R => '0'
    );
\EtoWbusIn_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn_src(3),
      Q => EtoWbusIn(3),
      R => '0'
    );
\EtoWbusIn_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn_src(4),
      Q => EtoWbusIn(4),
      R => '0'
    );
\EtoWbusIn_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn_src(5),
      Q => EtoWbusIn(5),
      R => '0'
    );
\EtoWbusIn_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn_src(6),
      Q => EtoWbusIn(6),
      R => '0'
    );
\EtoWbusIn_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn_src(7),
      Q => EtoWbusIn(7),
      R => '0'
    );
\EtoWbusIn_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusIn_src(8),
      Q => EtoWbusIn(8),
      R => '0'
    );
\WtoEbusOut_dst_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusOut(0),
      Q => WtoEbusOut_dst(0),
      R => '0'
    );
\WtoEbusOut_dst_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusOut(1),
      Q => WtoEbusOut_dst(1),
      R => '0'
    );
\WtoEbusOut_dst_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusOut(2),
      Q => WtoEbusOut_dst(2),
      R => '0'
    );
\WtoEbusOut_dst_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusOut(3),
      Q => WtoEbusOut_dst(3),
      R => '0'
    );
\WtoEbusOut_dst_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusOut(4),
      Q => WtoEbusOut_dst(4),
      R => '0'
    );
\WtoEbusOut_dst_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusOut(5),
      Q => WtoEbusOut_dst(5),
      R => '0'
    );
\WtoEbusOut_dst_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusOut(6),
      Q => WtoEbusOut_dst(6),
      R => '0'
    );
\WtoEbusOut_dst_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusOut(7),
      Q => WtoEbusOut_dst(7),
      R => '0'
    );
\WtoEbusOut_dst_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusOut(8),
      Q => WtoEbusOut_dst(8),
      R => '0'
    );
insti_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => EtoWbusIn_src(8)
    );
insti_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => EtoWbusIn_src(7)
    );
insti_2: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => EtoWbusIn_src(6)
    );
insti_3: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => EtoWbusIn_src(5)
    );
insti_4: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => EtoWbusIn_src(4)
    );
insti_5: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => EtoWbusIn_src(3)
    );
insti_6: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => EtoWbusIn_src(2)
    );
insti_7: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => EtoWbusIn_src(1)
    );
insti_8: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => EtoWbusIn_src(0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  port (
    clk : in STD_LOGIC;
    EtoWbusIn : out STD_LOGIC_VECTOR ( 8 downto 0 );
    WtoEbusOut : in STD_LOGIC_VECTOR ( 8 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "bd_EastCon_0_0,EastCon,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "EastCon,Vivado 2020.1";
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 clk CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clk : signal is "XIL_INTERFACENAME clk, FREQ_HZ 99990005, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN bd_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
begin
inst: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_EastCon
     port map (
      EtoWbusIn(8 downto 0) => EtoWbusIn(8 downto 0),
      WtoEbusOut(8 downto 0) => WtoEbusOut(8 downto 0),
      clk => clk
    );
end STRUCTURE;

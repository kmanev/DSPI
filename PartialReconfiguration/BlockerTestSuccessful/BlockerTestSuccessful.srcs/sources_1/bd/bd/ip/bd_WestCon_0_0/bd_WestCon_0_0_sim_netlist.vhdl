-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Tue May 11 15:15:31 2021
-- Host        : DESKTOP-47LU6A1 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               d:/prruns/BlockerTestSuccessful/BlockerTestSuccessful.srcs/sources_1/bd/bd/ip/bd_WestCon_0_0/bd_WestCon_0_0_sim_netlist.vhdl
-- Design      : bd_WestCon_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity bd_WestCon_0_0_WestCon is
  port (
    WtoEbusIn : out STD_LOGIC_VECTOR ( 7 downto 0 );
    clk : in STD_LOGIC;
    EtoWbusOut : in STD_LOGIC_VECTOR ( 7 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of bd_WestCon_0_0_WestCon : entity is "WestCon";
end bd_WestCon_0_0_WestCon;

architecture STRUCTURE of bd_WestCon_0_0_WestCon is
  signal EtoWbusOut_dst : STD_LOGIC_VECTOR ( 7 downto 0 );
  attribute MARK_DEBUG : boolean;
  attribute MARK_DEBUG of EtoWbusOut_dst : signal is std.standard.true;
  attribute RTL_KEEP : string;
  attribute RTL_KEEP of EtoWbusOut_dst : signal is "true";
  signal WtoEbusIn_src : STD_LOGIC_VECTOR ( 7 downto 0 );
  attribute MARK_DEBUG of WtoEbusIn_src : signal is std.standard.true;
  attribute RTL_KEEP of WtoEbusIn_src : signal is "true";
  attribute KEEP : string;
  attribute KEEP of \EtoWbusOut_dst_reg[0]\ : label is "yes";
  attribute KEEP of \EtoWbusOut_dst_reg[1]\ : label is "yes";
  attribute KEEP of \EtoWbusOut_dst_reg[2]\ : label is "yes";
  attribute KEEP of \EtoWbusOut_dst_reg[3]\ : label is "yes";
  attribute KEEP of \EtoWbusOut_dst_reg[4]\ : label is "yes";
  attribute KEEP of \EtoWbusOut_dst_reg[5]\ : label is "yes";
  attribute KEEP of \EtoWbusOut_dst_reg[6]\ : label is "yes";
  attribute KEEP of \EtoWbusOut_dst_reg[7]\ : label is "yes";
begin
\EtoWbusOut_dst_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusOut(0),
      Q => EtoWbusOut_dst(0),
      R => '0'
    );
\EtoWbusOut_dst_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusOut(1),
      Q => EtoWbusOut_dst(1),
      R => '0'
    );
\EtoWbusOut_dst_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusOut(2),
      Q => EtoWbusOut_dst(2),
      R => '0'
    );
\EtoWbusOut_dst_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusOut(3),
      Q => EtoWbusOut_dst(3),
      R => '0'
    );
\EtoWbusOut_dst_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusOut(4),
      Q => EtoWbusOut_dst(4),
      R => '0'
    );
\EtoWbusOut_dst_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusOut(5),
      Q => EtoWbusOut_dst(5),
      R => '0'
    );
\EtoWbusOut_dst_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusOut(6),
      Q => EtoWbusOut_dst(6),
      R => '0'
    );
\EtoWbusOut_dst_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => EtoWbusOut(7),
      Q => EtoWbusOut_dst(7),
      R => '0'
    );
\WtoEbusIn_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn_src(0),
      Q => WtoEbusIn(0),
      R => '0'
    );
\WtoEbusIn_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn_src(1),
      Q => WtoEbusIn(1),
      R => '0'
    );
\WtoEbusIn_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn_src(2),
      Q => WtoEbusIn(2),
      R => '0'
    );
\WtoEbusIn_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn_src(3),
      Q => WtoEbusIn(3),
      R => '0'
    );
\WtoEbusIn_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn_src(4),
      Q => WtoEbusIn(4),
      R => '0'
    );
\WtoEbusIn_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn_src(5),
      Q => WtoEbusIn(5),
      R => '0'
    );
\WtoEbusIn_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn_src(6),
      Q => WtoEbusIn(6),
      R => '0'
    );
\WtoEbusIn_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => WtoEbusIn_src(7),
      Q => WtoEbusIn(7),
      R => '0'
    );
insti_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => WtoEbusIn_src(7)
    );
insti_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => WtoEbusIn_src(6)
    );
insti_2: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => WtoEbusIn_src(5)
    );
insti_3: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => WtoEbusIn_src(4)
    );
insti_4: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => WtoEbusIn_src(3)
    );
insti_5: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => WtoEbusIn_src(2)
    );
insti_6: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => WtoEbusIn_src(1)
    );
insti_7: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => WtoEbusIn_src(0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity bd_WestCon_0_0 is
  port (
    clk : in STD_LOGIC;
    WtoEbusIn : out STD_LOGIC_VECTOR ( 7 downto 0 );
    EtoWbusOut : in STD_LOGIC_VECTOR ( 7 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of bd_WestCon_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of bd_WestCon_0_0 : entity is "bd_WestCon_0_0,WestCon,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of bd_WestCon_0_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of bd_WestCon_0_0 : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of bd_WestCon_0_0 : entity is "WestCon,Vivado 2020.1";
end bd_WestCon_0_0;

architecture STRUCTURE of bd_WestCon_0_0 is
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 clk CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clk : signal is "XIL_INTERFACENAME clk, FREQ_HZ 99990005, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN bd_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
begin
inst: entity work.bd_WestCon_0_0_WestCon
     port map (
      EtoWbusOut(7 downto 0) => EtoWbusOut(7 downto 0),
      WtoEbusIn(7 downto 0) => WtoEbusIn(7 downto 0),
      clk => clk
    );
end STRUCTURE;

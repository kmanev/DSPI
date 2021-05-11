// (c) Copyright 1995-2021 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


#include "bd_zynq_ultra_ps_e_0_0_sc.h"

#include "bd_zynq_ultra_ps_e_0_0.h"

#include "zynq_ultra_ps_e_tlm.h"

#include <map>
#include <string>





#ifdef XILINX_SIMULATOR
bd_zynq_ultra_ps_e_0_0::bd_zynq_ultra_ps_e_0_0(const sc_core::sc_module_name& nm) : bd_zynq_ultra_ps_e_0_0_sc(nm), pl_ps_irq0("pl_ps_irq0"), pl_resetn0("pl_resetn0"), pl_clk0("pl_clk0")
{

  // initialize pins
  mp_impl->pl_ps_irq0(pl_ps_irq0);
  mp_impl->pl_resetn0(pl_resetn0);
  mp_impl->pl_clk0(pl_clk0);

}

void bd_zynq_ultra_ps_e_0_0::before_end_of_elaboration()
{
}

#endif // XILINX_SIMULATOR




#ifdef XM_SYSTEMC
bd_zynq_ultra_ps_e_0_0::bd_zynq_ultra_ps_e_0_0(const sc_core::sc_module_name& nm) : bd_zynq_ultra_ps_e_0_0_sc(nm), pl_ps_irq0("pl_ps_irq0"), pl_resetn0("pl_resetn0"), pl_clk0("pl_clk0")
{

  // initialize pins
  mp_impl->pl_ps_irq0(pl_ps_irq0);
  mp_impl->pl_resetn0(pl_resetn0);
  mp_impl->pl_clk0(pl_clk0);

}

void bd_zynq_ultra_ps_e_0_0::before_end_of_elaboration()
{
}

#endif // XM_SYSTEMC




#ifdef RIVIERA
bd_zynq_ultra_ps_e_0_0::bd_zynq_ultra_ps_e_0_0(const sc_core::sc_module_name& nm) : bd_zynq_ultra_ps_e_0_0_sc(nm), pl_ps_irq0("pl_ps_irq0"), pl_resetn0("pl_resetn0"), pl_clk0("pl_clk0")
{

  // initialize pins
  mp_impl->pl_ps_irq0(pl_ps_irq0);
  mp_impl->pl_resetn0(pl_resetn0);
  mp_impl->pl_clk0(pl_clk0);

}

void bd_zynq_ultra_ps_e_0_0::before_end_of_elaboration()
{
}

#endif // RIVIERA




#ifdef VCSSYSTEMC
bd_zynq_ultra_ps_e_0_0::bd_zynq_ultra_ps_e_0_0(const sc_core::sc_module_name& nm) : bd_zynq_ultra_ps_e_0_0_sc(nm),  pl_ps_irq0("pl_ps_irq0"), pl_resetn0("pl_resetn0"), pl_clk0("pl_clk0")
{
  // initialize pins
  mp_impl->pl_ps_irq0(pl_ps_irq0);
  mp_impl->pl_resetn0(pl_resetn0);
  mp_impl->pl_clk0(pl_clk0);
  // Instantiate Socket Stubs


}

void bd_zynq_ultra_ps_e_0_0::before_end_of_elaboration()
{
}

#endif // VCSSYSTEMC




#ifdef MTI_SYSTEMC
bd_zynq_ultra_ps_e_0_0::bd_zynq_ultra_ps_e_0_0(const sc_core::sc_module_name& nm) : bd_zynq_ultra_ps_e_0_0_sc(nm),  pl_ps_irq0("pl_ps_irq0"), pl_resetn0("pl_resetn0"), pl_clk0("pl_clk0")
{
  // initialize pins
  mp_impl->pl_ps_irq0(pl_ps_irq0);
  mp_impl->pl_resetn0(pl_resetn0);
  mp_impl->pl_clk0(pl_clk0);
  // Instantiate Socket Stubs


}

void bd_zynq_ultra_ps_e_0_0::before_end_of_elaboration()
{
}

#endif // MTI_SYSTEMC




bd_zynq_ultra_ps_e_0_0::~bd_zynq_ultra_ps_e_0_0()
{
}

#ifdef MTI_SYSTEMC
SC_MODULE_EXPORT(bd_zynq_ultra_ps_e_0_0);
#endif

#ifdef XM_SYSTEMC
XMSC_MODULE_EXPORT(bd_zynq_ultra_ps_e_0_0);
#endif

#ifdef RIVIERA
SC_MODULE_EXPORT(bd_zynq_ultra_ps_e_0_0);
#endif

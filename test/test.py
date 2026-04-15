# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles


@cocotb.test()
async def test_neurospike_clean(dut):
    """Clean NeuroSpike test (FSM-style like your working example)"""

    dut._log.info("Starting NeuroSpike FSM-style test")

    # Clock
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # -----------------------------
    # CLEAN STIMULUS LOOP (FSM STYLE)
    # -----------------------------
    for cycle in range(15):

        # spike pulse (like FSM instruction style)
        dut.ui_in.value = 0x01
        await RisingEdge(dut.clk)

        dut.ui_in.value = 0x00
        await RisingEdge(dut.clk)

        acc = int(dut.uo_out.value)
        spike = acc & 0x1
        membrane = acc >> 1
        threshold = int(dut.uio_out.value)

        dut._log.info(
            f"Cycle {cycle} | Membrane={membrane} | Spike={spike} | Threshold={threshold}"
        )

    # -----------------------------
    # CLEAN END (NO TIMER HACKS)
    # -----------------------------
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    dut._log.info("Test completed cleanly")

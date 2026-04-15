import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles


@cocotb.test()
async def test_neurospike_clean(dut):
    """Stable NeuroSpike test for GitHub Actions"""

    dut._log.info("Starting NeuroSpike test")

    # Start clock
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await ClockCycles(dut.clk, 5)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # Run controlled stimulus
    for i in range(15):
        dut.ui_in.value = 0x01  # stimulus pulse
        await RisingEdge(dut.clk)

        dut.ui_in.value = 0x00
        await RisingEdge(dut.clk)

        await RisingEdge(dut.clk)

        membrane = int(dut.uo_out.value >> 1)
        spike = int(dut.uo_out.value & 0x1)
        threshold = int(dut.uio_out.value)

        dut._log.info(
            f"Cycle {i} | Membrane={membrane} | Spike={spike} | Threshold={threshold}"
        )

    # Small extra wait to ensure clean exit
    await ClockCycles(dut.clk, 5)

    dut._log.info("Test completed cleanly")

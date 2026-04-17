import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

@cocotb.test()
async def water_test(dut):

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1

    # CLEAN
    for _ in range(5):
        dut.uio_in.value = 20
        dut.ui_in.value = 1
        await RisingEdge(dut.clk)

    # WARNING
    for i in range(5):
        dut.uio_in.value = 50 + i*10
        await RisingEdge(dut.clk)

    # UNSAFE
    for _ in range(5):
        dut.uio_in.value = 200
        await RisingEdge(dut.clk)

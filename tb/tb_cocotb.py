#******************************************************************************
# file:    tb_cocotb.py
#
# author:  JAY CONVERTINO
#
# date:    2025/05/21
#
# about:   Brief
# Cocotb test bench
#
# license: License MIT
# Copyright 2025 Jay Convertino
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#
#******************************************************************************

import random
import itertools

import cocotb
from cocotb.clock import Clock
from cocotb.utils import get_sim_time
from cocotb.triggers import FallingEdge, RisingEdge, Timer, Event
from cocotb.binary import BinaryValue

# Function: random_bool
# Return a infinte cycle of random bools
#
# Returns: List
def random_bool():
  temp = []

  for x in range(0, 256):
    temp.append(bool(random.getrandbits(1)))

  return itertools.cycle(temp)

# Function: start_clock
# Start the simulation clock generator.
#
# Parameters:
#   dut - Device under test passed from cocotb test function
def start_clock(dut):
  cocotb.start_soon(Clock(dut.rd_clk, int(1000000000/dut.RD_CLOCK_SPEED.value), units="ns").start())
  cocotb.start_soon(Clock(dut.wr_clk, int(1000000000/dut.WR_CLOCK_SPEED.value), units="ns").start())

# Function: reset_dut
# Cocotb coroutine for resets, used with await to make sure system is reset.
async def reset_dut(dut):
  dut.rd_rstn.value = 0
  dut.wr_rstn.value = 0
  await Timer(200, units="ns")
  dut.rd_rstn.value = 1
  dut.wr_rstn.value = 1

# Function: random test
# Coroutine that is identified as a test routine. Write random data, on one clock edge, read
# on the next.
#
# Parameters:
#   dut - Device under test passed from cocotb.
@cocotb.test()
async def random_test(dut):

  write_data = []

  start_clock(dut)

  await reset_dut(dut)
  
  dut.wr_ben.value = ~0
  
  dut.rd_en.value = 0
  
  dut.rd_addr.value = 0
  
  await RisingEdge(dut.wr_clk)

  for x in range(0, dut.RAM_DEPTH.value):
    
    write_data.append(random.randrange(1, 2**(dut.BYTE_WIDTH.value*8)))
    
    dut.wr_data.value = write_data[-1]
    dut.wr_addr.value = x
    dut.wr_en.value = 1

    await RisingEdge(dut.wr_clk)
  
  await RisingEdge(dut.rd_clk)

  for x in range(0, dut.RAM_DEPTH.value):
    
    dut.rd_addr.setimmediatevalue(x)
    dut.rd_en.setimmediatevalue(1)
    
    await RisingEdge(dut.rd_clk)
    
    assert write_data.pop(0) == dut.rd_data.value.integer, "WRITE DOES NOT MATCH READ"
    

# Function: in_reset
# Coroutine that is identified as a test routine. This routine tests if device stays
# in unready state when in reset.
#
# Parameters:
#   dut - Device under test passed from cocotb.
@cocotb.test()
async def in_reset(dut):

  start_clock(dut)

  dut.rd_rstn.value = 0
  dut.wr_rstn.value = 0

  await Timer(int(1000000000/dut.RD_CLOCK_SPEED.value)*50, units="ns")

  assert dut.rd_data.value.integer == 0, "RD DATA IS NOT 0!"

# Function: no_clock
# Coroutine that is identified as a test routine. This routine tests if no ready when clock is lost
# and device is left in reset.
#
# Parameters:
#   dut - Device under test passed from cocotb.
@cocotb.test()
async def no_clock(dut):

  dut.rd_rstn.value = 0
  dut.wr_rstn.value = 0

  await Timer(int(1000000000/dut.RD_CLOCK_SPEED.value)*50, units="ns")

  assert dut.rd_data.value.integer == 0, "RD DATA IS NOT 0!"

//******************************************************************************
// file:    tb_dc_block_ram.v
//
// author:  JAY CONVERTINO
//
// date:    2025/01/17
//
// about:   Brief
// Test bench for Generic Dual Port RAM
//
// license: License MIT
// Copyright 2025 Jay Convertino
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
//******************************************************************************

`timescale 1ns/100ps

/*
 * Module: dc_block_ram
 *
 * Test bench for Generic Dual Port RAM
 *
 * Parameters:
 *
 *   RAM_DEPTH    - Number of words using the size of BYTE_WIDTH.
 *   BYTE_WIDTH   - Width of the data bus in bytes.
 *   ADDR_WIDTH   - Width of the address bus in bits.
 *   HEX_FILE     - Read a hex value text file as the initial state of the RAM.
 *   RAM_TYPE     - Used to set the ram_style atribute.
 */
module tb_dc_block_ram #(
  parameter RAM_DEPTH  = 256,
  parameter BYTE_WIDTH = 4,
  parameter ADDR_WIDTH = 32,
  parameter HEX_FILE   = "",
  parameter RAM_TYPE   = "block"
  )();

  wire                      tb_dut_clk;
  wire                      tb_dut_rstn;

  reg                         tb_rd_en;
  wire  [(BYTE_WIDTH*8)-1:0]  tb_rd_data;
  reg   [ADDR_WIDTH-1:0]      tb_rd_addr;
  reg                         tb_wr_en;
  reg   [BYTE_WIDTH-1:0]      tb_wr_ben;
  reg   [(BYTE_WIDTH*8)-1:0]  tb_wr_data;
  reg   [ADDR_WIDTH-1:0]      tb_wr_addr;

  integer write_address = 0;
  integer read_address  = 0;

  //Group: Instantiated Modules

  /*
   * Module: clk_stim
   *
   * Generate a 50/50 duty cycle set of clocks and reset.
   */
  clk_stimulus #(
    .CLOCKS(1),
    .CLOCK_BASE(1000000),
    .RESETS(1),
    .RESET_BASE(2000)
  ) clk_stim (
    .clkv(tb_dut_clk),
    .rstnv(tb_dut_rstn),
    .rstv()
  );
  
  // Module: inst_dc_block_ram
  //
  // Module instance of dc_block_ram
  dc_block_ram #(
    .RAM_DEPTH(RAM_DEPTH),
    .BYTE_WIDTH(BYTE_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .HEX_FILE(HEX_FILE),
    .RAM_TYPE(RAM_TYPE)
  ) inst_dc_block_ram (
    .rd_clk(tb_dut_clk),
    .rd_rstn(tb_dut_rstn),
    .rd_en(tb_rd_en),
    .rd_data(tb_rd_data),
    .rd_addr(tb_rd_addr),
    .wr_clk(tb_dut_clk),
    .wr_rstn(tb_dut_rstn),
    .wr_en(tb_wr_en),
    .wr_ben(tb_wr_ben),
    .wr_data(tb_wr_data),
    .wr_addr(tb_wr_addr)
  );

  always @(posedge tb_dut_clk)
  begin
    if(!tb_dut_rstn)
    begin
      tb_rd_en    <= 1'b0;
      tb_rd_addr  <= 0;

      tb_wr_en    <= 1'b0;
      tb_wr_ben   <= 0;
      tb_wr_data  <= 0;
      tb_wr_addr  <= 0;
    end else begin
      tb_rd_en    <= 1'b0;
      tb_rd_addr  <= 0;

      tb_wr_en    <= 1'b0;
      tb_wr_ben   <= 0;
      tb_wr_data  <= 0;
      tb_wr_addr  <= 0;

      if(write_address < RAM_DEPTH)
      begin
        tb_wr_en <= 1'b1;
        tb_wr_ben <= ~0;
        tb_wr_data <= write_address;
        tb_wr_addr <= write_address;

        write_address <= write_address + 1;
      end else if (read_address < RAM_DEPTH)
      begin
        tb_rd_en <= 1'b1;
        tb_rd_addr <= read_address;

        read_address <= read_address + 1;
      end else begin
        $finish();
      end
    end
  end
  
  // vcd dump command
  initial begin
    $dumpfile ("tb_dc_block_ram.vcd");
    $dumpvars (0, tb_dc_block_ram);
    #1;
  end
  
endmodule


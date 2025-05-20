//******************************************************************************
// file:    dc_block_ram.v
//
// author:  JAY CONVERTINO
//
// date:    2024/03/07
//
// about:   Brief
// Generic Dual Port RAM
//
// license: License MIT
// Copyright 2024 Jay Convertino
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
 * Generic Dual Port RAM
 *
 * Parameters:
 *
 *   RAM_DEPTH    - Number of words using the size of BYTE_WIDTH.
 *   BYTE_WIDTH   - Width of the data bus in bytes.
 *   ADDR_WIDTH   - Width of the address bus in bits.
 *   HEX_FILE     - Read a hex value text file as the initial state of the RAM.
 *   RAM_TYPE     - Used to set the ram_style atribute.
 *
 * Ports:
 *
 *   rd_clk       - Read clock positive edge
 *   rd_rstn      - Read reset active low
 *   rd_en        - Read enable active high
 *   rd_data      - Read data output
 *   rd_addr      - Read data address select
 *   wr_clk       - Write clock positive edge
 *   wr_rstn      - Write reset active low
 *   wr_en        - Write enable active high
 *   wr_ben       - Write byte enable, each bit represents one byte of write data.
 *   wr_data      - Write data input
 *   wr_addr      - Write data address select
 */
module dc_block_ram #(
    parameter RAM_DEPTH  = 1,
    parameter BYTE_WIDTH = 1,
    parameter ADDR_WIDTH = 1,
    parameter HEX_FILE   = "",
    parameter RAM_TYPE   = "block"
  )
  (
    input                         rd_clk,
    input                         rd_rstn,
    input                         rd_en,
    output  [(BYTE_WIDTH*8)-1:0]  rd_data,
    input   [ADDR_WIDTH-1:0]      rd_addr,
    input                         wr_clk,
    input                         wr_rstn,
    input                         wr_en,
    input   [BYTE_WIDTH-1:0]      wr_ben,
    input   [(BYTE_WIDTH*8)-1:0]  wr_data,
    input   [ADDR_WIDTH-1:0]      wr_addr
  );
  
  integer index;

  (* ram_style = RAM_TYPE *) reg [(BYTE_WIDTH*8)-1:0] block_ram[RAM_DEPTH];
  reg [(BYTE_WIDTH*8)-1:0] r_rd_data;

  generate
    initial begin
      if(HEX_FILE != "") begin
        $readmemh(HEX_FILE, block_ram);
      end
    end
  endgenerate

  assign rd_data = r_rd_data;

  // Produce data for the buffer from the write input.
  always @(posedge wr_clk) begin
    if(wr_rstn != 1'b0) begin
      if(wr_en == 1'b1) begin
        for(index = 0; index < BYTE_WIDTH; index = index + 1)
        begin
          if(wr_ben[index] == 1'b1)
          begin
            block_ram[wr_addr][8*index +:8] <= wr_data[8*index +:8];
          end
        end
      end
    end
  end
  
  // Consume data from the buffer for the read output.
  always @(posedge rd_clk) begin
    if(rd_rstn == 1'b0) begin
      r_rd_data <= 0;
    end else begin
      if(rd_en == 1'b1)
      begin
        r_rd_data <= block_ram[rd_addr];
      end
    end
  end
  
endmodule

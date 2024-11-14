# DC BLOCK RAM
### Dual Clock block ram for all FPGA systems

![image](docs/manual/img/AFRL.png)

---

   author: Jay Convertino  
   
   date: 2024.02.11
   
   details: Generic dual clock block RAM that has data write enables.
   
   license: MIT   
   
---

### Version
#### Current
  - V1.0.0 - initial

#### Previous
  - none

### DOCUMENTATION
  For detailed usage information, please navigate to one of the following sources. They are the same, just in a different format.

  - [dc_block_ram.pdf](docs/manual/dc_block_ram.pdf)
  - [github page](https://johnathan-convertino-afrl.github.io/dc_block_ram/)

### DEPENDENCIES
#### Build
  - AFRL:utility:helper:1.0.0
  
#### Simulation
  - AFRL:simulation:clock_stimulator
  - AFRL:utility:sim_helper
  
### PARAMETERS

* RAM_DEPTH   : Depth of the RAM in size BYTE_WIDTH
* ADDR_WIDTH  : Address size for RAM(THIS DOES NOT AUTOMATICALLY SIZE INTERNALLY, THATS UP TO YOU)
* BYTE_WIDTH  : How many bytes wide the data in/out will be.
* HEX_FILE    : Hex file to initialize RAM with ("" is none).
* RAM_TYPE    : Set the BLOCK RAM type of the fifo.

### COMPONENTS
#### SRC

* dc_block_ram.v
  
#### TB

* tb_fifo.v (not done at the moment)
  
### FUSESOC

* fusesoc_info.core created.
* Simulation uses icarus to run data through the core.

#### Targets

* RUN WITH: (fusesoc run --target=sim VENDER:CORE:NAME:VERSION)
  - default (for IP integration builds)
  - sim

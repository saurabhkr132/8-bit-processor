---- TEAM  LOGIC ARCHITECTS ----

This repository contains four files:
1. cpu.v: This is the main verilog file containing all the modules and their integration into a cpu module. This also contains the program feeded into the memory for programming while implementating on FPGA.

2. cpu_tb.v: This is the testbench file useful for simulating the processor without any hardware. This also contains the program, so the program in the main cpu.v can be commented.

3. cpu_fpga.v: This is the testbench developed for simulating the ports as it would be while using FPGA, basically simulating the FPGA. This was used for debugging the errors encountered while implementating on the FPGA board.

4. control.xdc: This contains the physical and clock constrains, specifically for Xilinx PYNQ-Z2 FPGA board.

To use these files on software like Vivado, add these in the following manner:

cpu.v: As design source file

cpu_tb.v: As simulation source file

cpu_fpga.v: As simulation source file

control.xdc: As constraints.

The source code is available at: https://github.com/saurabhkr132/8-bit-processor

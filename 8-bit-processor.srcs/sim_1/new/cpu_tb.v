//`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

module cpu_tb;
  
  // Signals
  wire SERIAL_OUT;
  reg NCLR, CLK;
  
  // Instantiate the CPU (Device Under Test)
  cpu dut (
    .NCLR(NCLR),
    .CLK(CLK),
    .SERIAL_OUT(SERIAL_OUT)
  );
  
  // Clock generation: Toggle CLK every 5 time units
  always #5 CLK = ~CLK;
  
  // Testbench stimuli
  initial begin
    // Initialize clock and reset
    CLK = 1'b0;  // Start clock at 0
    NCLR = 1'b0; // Hold reset initially

    // Release reset after a few cycles
    #10 NCLR = 1'b1;
 
    // Test program: simple add and subtract instructions
    dut.memory.mem[8'h00] = 16'b1010000000000111; // INPUT ACC 7
    dut.memory.mem[8'h01] = 16'b0100000000000001; // ADD ACC 1
    dut.memory.mem[8'h02] = 16'b1110000000001000; // OUTPUT ACC, address 8
    dut.memory.mem[8'h03] = 16'b0000000011111111; // LOAD ACC 255
    dut.memory.mem[8'h04] = 16'b0110000000000010; // SUB 2
    dut.memory.mem[8'h05] = 16'b1110000000001001; // OUTPUT ACC, address 9
    dut.memory.mem[8'h06] = 16'b1000000000000000; // JUMP to address 00
    dut.memory.mem[8'h07] = 16'b0000000000000100; // DATA 4
    dut.memory.mem[8'h08] = 16'b0000000000000000; // DATA 0
    dut.memory.mem[8'h09] = 16'b0000000000000000; // DATA 0
    
    // Wait for 50 clock cycles (for operations to execute)
    #400;
    
    // Verify the result stored in memory
    $display("\nCheck RAM ");
//    $display("Expected:\t%b", 16'b0000000001101110); // Expected result: 110 (100 + 10)
    $display("Data stored:\t%b", dut.memory.mem[9]);
    
    // End simulation
   // $finish;
  end
  
  // Generate waveform file for debugging
 initial begin
  $dumpfile("dump.vcd"); 
  $dumpvars(0, cpu_tb.dut);  // Dump everything in DUT scope
  $dumpvars(0, cpu_tb.dut.memory);  // Dump memory scope if needed
end
  
endmodule
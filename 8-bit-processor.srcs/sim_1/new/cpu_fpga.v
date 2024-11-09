module cpu_fpga;
  
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
    
    
   end
   

    
 endmodule
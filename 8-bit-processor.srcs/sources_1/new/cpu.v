// Comouter Architecture and Organization Project: 8-bit CPU Design and Implementation
// Team Logic Architects
// Members:
//  Ajit Kumar Singh (SC22B123)
//  Anurag (SC22B125)
//  Saurabh Kumar (SC22B146)
//  Uttam Kumar (SC22B156)


`timescale 1ns / 1ps


//8 bit 2 to 1 multiplexer
module mux_2x1_8 (output reg [7:0] Z,
                  input [7:0] A, B, 
                  input SEL);
  always @ (A, B, SEL)
    case (SEL)
      0: Z <= A; // if sel is 0 select A input
      1: Z <= B; // if sel is 1 select B input
      default: Z <= 8'b00000000; //default case to prevent latch being formed
    endcase
endmodule


// Use behavioural modelling to achieve correct ALU performance 
module alu (input [7:0] A, B,
                input [4:0] SEL,
                output reg [7:0] Z,
                output reg Cout);
  always @ (A, B, SEL) begin
    case (SEL)
      // S4 S3 S2 S1 S0
      5'b00000: {Cout,Z} = A+B; 	// add
      5'b00001: {Cout,Z} = A & B; 	// bitwise and
      5'b00101: {Cout,Z} = A | B; 	// bitwise or
      5'b00010: Z = A; 				// input A
      5'b00011: Z = B; 				// input B
      5'b01100: {Cout,Z} = A - B; 	// subtract
      5'b01110: {Cout,Z} = A * B;   // multiply
//      5'b01010: div(A,B,Z);         // divide
      5'b01010: Z = A / B;           // divide
//      5'b01010: fact(A,B,Z);        // factorial
//      5'b01010: hcf(A,B,Z);         // hcf
//      5'b01010: conv(A,B,Z);         // conv
      5'b10100: {Cout,Z} = A + 1; 	// increment
      5'b10000: Z = A; 				// input A
      5'b00100: {Cout,Z} = A+B+1;   // add and increment
      5'b01000: {Cout,Z} = A-B-1;	// subtract and decrement
      default: Z=8'b00000000; 		// default case to prevent latching
    endcase
  end
  
//task conv;
//    input [7:0] A;
//    input [7:0] B;
//    output reg [7:0] result;
    
//    integer k, m;
    
//    for (k=0; k<8; k=k+1) begin
//        for (m=0; m<8; m=m+1) begin
//            result[k] = A[m-A[7]]*B[k-m-B[7]];
//        end
//    end
//endtask
  
task div;
    input [7:0] dividend;
    input [7:0] divisor;
    output reg [7:0] quotient;
    reg [7:0] remainder;
    integer i;
    
    begin
        quotient = 0;
        remainder = dividend;
        if (divisor != 0) begin
            for (i = 0; remainder >= divisor; i = i + 1) begin
                remainder = remainder - divisor;
                quotient = quotient + 1;
            end
        end
    end
endtask


endmodule


module dff (input D, CE, CLR, C,
            output reg Q);

  always @(posedge C or posedge CLR) begin
    if (CLR)
      Q <= 0; // clear signal sets output to zero
    else if (CE)
      Q <= D; // on rising clock edge, set output to data if enabled
  end  
endmodule
// 2 bit register using D flip flops
module register_2 (input [1:0] D, 
                   input CLK, CE, CLR,
                   output [1:0] Q);
  dff Zero(D[0], CE, CLR, CLK, Q[0]);
  dff Carry(D[1], CE, CLR, CLK, Q[1]);
endmodule


// 4 bit register using D flip flops
module register_4 (input [3:0] D, 
                   input CLK, CE, CLR,
                   output [3:0] Q);
  dff D0(D[0], CE, CLR, CLK, Q[0]); // connect each input and output to flip flop
  dff D1(D[1], CE, CLR, CLK, Q[1]);
  dff D2(D[2], CE, CLR, CLK, Q[2]);
  dff D3(D[3], CE, CLR, CLK, Q[3]);
endmodule


// 8 bit register using 2 4-bit registers
module register_8 (input [7:0] D,
                   input CLK, CE, CLR,
                   output [7:0] Q);
  register_4 R0(D[3:0],CLK,CE,CLR,Q[3:0]); //use 2 4-bit registers to create 8-bit register
  register_4 R1(D[7:4],CLK,CE,CLR,Q[7:4]);
endmodule


// 16 bit register using 2 8-bit registers
module register_16 (input [15:0] D,
                    input CLK, CE, CLR,
                    output [15:0] Q);
  register_8 R0(D[7:0],CLK,CE,CLR,Q[7:0]); //use 2 8-bit registers to create 16-bit register
  register_8 R1(D[15:8],CLK,CE,CLR,Q[15:8]);
endmodule


// one-hot encoded ring oscillator adapted to generate processor state sequence
module sequence_generator (input CLK, CE, CLR,
                           output reg F, D, E, I);
  always @ (posedge CLK) begin
    // using case statements here proved more robust than 
    // one-hot incrementing as it allows easier reset to fetch (default state)
    case ({CLR, CE, F, D, E, I})
      6'b1xxxxx: {F,D,E,I} <= 4'b1000; 
      6'b00xxxx: {F,D,E,I} <= {F,D,E,I};
      6'b011000: {F,D,E,I} <= 4'b0100;
      6'b010100: {F,D,E,I} <= 4'b0010;
      6'b010010: {F,D,E,I} <= 4'b0001;
      6'b010001: {F,D,E,I} <= 4'b1000;
      default: {F,D,E,I} <= 4'b1000; // default prevents latching circuit 
    endcase      
  end
endmodule


// Instruction decoder module to interpret instruction code 
// output is one hot encoded
module instruction_decoder (input [7:0] A,
                            input DECODE, EXECUTE,
                            output reg ADD, LOAD, OUTPUT, INPUT, JUMPZ, 
                            	   JUMP, JUMPNZ, JUMPC, JUMPNC, SUB, BITAND, BITOR, MUL, DIV);
  reg or_out;
   
  always @(*) begin
    or_out = (EXECUTE|DECODE); // only interpret isntruction during eexcute and decode phases
    if(or_out)
      casex (A) // need to use casex when dealing with x terms
        8'b1010xxxx: INPUT = 1;
        8'b1110xxxx: OUTPUT = 1;
        8'b0000xxxx: LOAD = 1;
        8'b0100xxxx: ADD = 1;
        8'b1000xxxx: JUMP = 1;
        8'b0110xxxx: SUB = 1;
        8'b0111xxxx: MUL = 1;
        8'b0101xxxx: DIV = 1;
        8'b0001xxxx: BITAND = 1;
        8'b0011xxxx: BITOR = 1;
        8'b100100xx: JUMPZ = 1;
        8'b100101xx: JUMPNZ = 1;
        8'b100110xx: JUMPC = 1;
        8'b100111xx: JUMPNC = 1;
        default: {ADD,LOAD,OUTPUT,INPUT,JUMPZ,JUMP,JUMPNZ,JUMPC,JUMPNC,SUB,BITAND,BITOR,MUL, DIV} = 14'b0000000000000;
      endcase
    else
      {ADD,LOAD,OUTPUT,INPUT,JUMPZ,JUMP,JUMPNZ,JUMPC,JUMPNC,SUB,BITAND,BITOR,MUL, DIV} = 14'b0000000000000;
  end
endmodule


// Decoder module includes instruction decoder, sequence geenrator, flip flop and combinational logic
module decoder (input [7:0] IR,
                input Carry, Zero, CLK, CE, CLR,
                output reg RAM, ALU_S4, ALU_S3, ALU_S2, ALU_S1, ALU_S0, MUXA, MUXB, MUXC, EN_IN, EN_DA, EN_PC );
  
  wire fetch, decode, execute, increment, carry_reg, zero_reg, add, load, instr_output, instr_input, jumpz, jump, jumpnz, jumpc, jumpnc, sub, bitand, bitor, jump_not_taken, mul;
  
  reg en_st, OR5, FDC_D_B4_INV;
  
  // One hot encoded ring oscillator for processor state
  sequence_generator sequence_generator(.CLK(CLK), .CE(CE), .CLR(CLR), .F(fetch), .D(decode), .E(execute), .I(increment)); 
   
  // 2 bit register for zero/carry
  register_2 zero_carry(.D({Zero,Carry}), .CLK(CLK), .CE(en_st), .CLR(CLR), .Q({zero_reg,carry_reg}));
  
  // place instruction decoder module with explicit port connnections
  instruction_decoder instruction_decoder(.A(IR), .DECODE(decode), .EXECUTE(execute), .ADD(add), .LOAD(load), .OUTPUT(instr_output), .INPUT(instr_input), .JUMPZ(jumpz), .JUMP(jump), .JUMPNZ(jumpnz), .JUMPC(jumpc), .JUMPNC(jumpnc), .SUB(sub), .BITAND(bitand), .BITOR(bitor), .MUL(mul), .DIV(div));
  
  // jump not taken register
  dff jump_n_taken(.D(~FDC_D_B4_INV), .CE(1'b1), .CLR(CLR), .C(CLK), .Q(jump_not_taken));
  
  always @(*) begin   // combinational logic
    en_st = (add|sub|bitand|bitor|mul|div);
    RAM = (execute&instr_output);
    OR5 = (jump|jumpz|jumpnz|jumpc|jumpnc);
    ALU_S0 = (OR5|load|instr_input|bitand|bitor);
    ALU_S1 = (OR5|instr_output|instr_input|load|mul|div);
    ALU_S2 = (increment|sub|mul|bitor);
    ALU_S3 = (sub|mul|div);
    ALU_S4 = increment;
    MUXA = increment;
    MUXB = (load|add|bitand|bitor|sub|mul|div);
    MUXC = (instr_input|instr_output);
    EN_IN = fetch;
    EN_DA = (execute&(load|add|sub|bitand|bitor|mul|div|instr_input));
    FDC_D_B4_INV = ((jumpz&zero_reg)|(jumpnz&(~zero_reg))|(jumpc&carry_reg)|(jumpnc&(~carry_reg))|jump);
    EN_PC = ((increment&jump_not_taken)|(execute&FDC_D_B4_INV));
  end
endmodule


    
// 16 bit 256 address ram module
// 8 bit address gives 256 locations
// Memory is von Neumann architecture - instructions and data stored together
module ram(input we, clk,
           input [15:0] din,
           input [7:0] addr,
           output reg [15:0] dout);
  reg [15:0] mem [255:0]; //256 16 bit regs
  
   // Load instruction and data into RAM during reset cycle at start
   //instructions are 16 bits but data is 8 bits. Pad the first byte of data with 0x00
   // OP CODES
    parameter INPUT = 8'b10100000;
    parameter OUTPUT = 8'b11100000;
    parameter LOAD = 8'b00000000;
    parameter ADD = 8'b01000000;
    parameter JUMP = 8'b10000000;
    parameter SUB = 8'b01100000;
    parameter MUL = 8'b01110000;
    parameter DIV = 8'b01010000;
    parameter BITAND = 8'b00010000;
    parameter BITOR = 8'b00110000;
    parameter JUMPZ = 8'b10010000;
    parameter JUMPNZ = 8'b10010100;
    parameter JUMPC = 8'b10011000;
    parameter JUMPNC = 8'b10011100;
    
    // PROGRAMMING INSTRUCTIONS
    initial
    begin
        mem[8'h00] = {LOAD, 8'd05};
        mem[8'h01] = {MUL, 8'd03};
        mem[8'h02] = {OUTPUT, 8'hFF};
    end
    
  always @ (posedge clk) begin
    if (we)
        mem[addr] <= din;
  end
  
  always @ (posedge clk) begin
    if (~we) 
      dout <= mem[addr];
  end
 
endmodule

// module to convert hexadecimal result to seven segment display
module hex_to_7seg (
    input [3:0] hex,       // 4-bit hex input (0x0 to 0xF)
    output reg [6:0] Out // 7-segment output
);

    always @ (hex) begin
        case (hex)
            4'b0000: Out = 7'b1111110; // 0
            4'b0001: Out = 7'b0110000; // 1
            4'b0010: Out = 7'b1101101; // 2
            4'b0011: Out = 7'b1111001; // 3
            4'b0100: Out = 7'b0110011; // 4
            4'b0101: Out = 7'b1011011; // 5
            4'b0110: Out = 7'b1011111; // 6
            4'b0111: Out = 7'b1110000; // 7
            4'b1000: Out = 7'b1111111; // 8
            4'b1001: Out = 7'b1111011; // 9
            4'b1010: Out = 7'b1110111; // A
            4'b1011: Out = 7'b0011111; // B
            4'b1100: Out = 7'b1001110; // C
            4'b1101: Out = 7'b0111101; // D
            4'b1110: Out = 7'b1001111; // E
            4'b1111: Out = 7'b1000111; // F
            default: Out = 7'b0000000; // Turn off all segments for invalid input
        endcase
    end
endmodule

// top module tying everything together
// active low reset signal on NCLR. Assert reset cycle at start to reset registers
// SERIAL_OUT output is only needed for testing physical operation on an FPGA


module cpu (input NCLR, CLK,
            	 output reg [6:0] out, reg [3:0] out_led, reg disp1, reg disp2, reg SERIAL_OUT);
  
  wire FD_CLR, FDCE_Q, EN_IN, EN_PC, EN_DA, ALU_S4,ALU_S3,ALU_S2,ALU_S1,ALU_S0, CARRY, RAM_WE, MUXA, MUXB, MUXC;
  wire [7:0] ACC_Q, MUX_A_Q, MUX_B_Q, MUX_C_Q, PC_Q, ALU_Q;
  wire [15:0] CPU_DI, IR_Q;
  wire [6:0] res_0, res_1;
  
//  reg [15:0] code [255:0];
  
  
  
  reg [15:0] CPU_DO;
  reg [7:0] IR_LOW, IR_HIGH, CPU_DI_LOW;
  reg ZERO;
  
  // Active low clear flip flop
  dff fd(.D(~NCLR), .CE(1'b1), .CLR(1'b0), .C(CLK), .Q(FD_CLR));
  
  // Flip flop for outputting data to oscilloscope in serial transmission
  dff fdce(.D(CPU_DO[0]), .CE(&MUX_C_Q), .CLR(FD_CLR), .C(CLK), .Q(FDCE_Q));
  
  //Instruction register
  register_16 instr_reg(.D(CPU_DI), .CLK(CLK), .CE(EN_IN), .CLR(FD_CLR), .Q(IR_Q));  
   
  //Program counter register
  register_8 program_counter(.D(ALU_Q), .CLK(CLK), .CE(EN_PC), .CLR(FD_CLR), .Q(PC_Q));  
  
  //Accumulator register
  register_8 accumulator(.D(ALU_Q), .CLK(CLK), .CE(EN_DA), .CLR(FD_CLR), .Q(ACC_Q));  
  
  // ALU 
  alu alu_unit(.A(MUX_A_Q), .B(MUX_B_Q), .SEL({ALU_S4,ALU_S3,ALU_S2,ALU_S1,ALU_S0}), .Z(ALU_Q), .Cout(CARRY));
  
  // Data Mux A selects between program counter and accumulator outputs
  mux_2x1_8 muxa(.Z(MUX_A_Q), .A(ACC_Q), .B(PC_Q), .SEL(MUXA));
  
  // Data mux B selects between CPU data input bus and instruction register data byte output
  mux_2x1_8 muxb(.Z(MUX_B_Q), .A(CPU_DI_LOW), .B(IR_LOW), .SEL(MUXB));
  
  // Address Mux points to location in RAM to read or write and selects between instruction register data byte
  mux_2x1_8 muxc(.Z(MUX_C_Q), .A(PC_Q), .B(IR_LOW), .SEL(MUXC));
   
  // Tie memory to CPU data in and out buses and address signal from the address mux
  ram memory(.we(RAM_WE), .clk(CLK), .din(CPU_DO), .addr(MUX_C_Q), .dout(CPU_DI));
  
  // Decoder to interpret instruction from upper byte of instruction register
  decoder decoder(.IR(IR_HIGH), .Carry(CARRY), .Zero(ZERO), .CLK(CLK), .CE(1'b1), .CLR(FD_CLR), .RAM(RAM_WE), .ALU_S4(ALU_S4), .ALU_S3(ALU_S3), .ALU_S2(ALU_S2), .ALU_S1(ALU_S1), .ALU_S0(ALU_S0), .MUXA(MUXA), .MUXB(MUXB), .MUXC(MUXC), .EN_IN(EN_IN), .EN_DA(EN_DA), .EN_PC(EN_PC));
  
  
  hex_to_7seg hex_to_7seg_0(.hex(memory.mem[8'hFF][3:0]), .Out(res_0));
  hex_to_7seg hex_to_7seg_1(.hex(memory.mem[8'hFF][7:4]), .Out(res_1));

   
    
    // Seven segment display multiplexing
    integer COUNT = 10; // displaying one digit at a time for 10 clock pulses
    integer counter; // counter to add the delay
    
    initial begin
        disp1 <= 1;
        disp2 <= 1;
        counter <= 0; 
    end
    
    always @(posedge CLK) begin
        if(counter == COUNT) begin
            counter = 0;
        end
        else if (counter >= COUNT/2) begin
            counter <= counter + 1;
            disp1 <= 1;
            disp2 <= 0;
            out = res_1;
        end
        else begin
            counter <= counter + 1;
            disp1 <= 0;
            disp2 <= 1;
            out = res_0;
        end
    end
          
  always @(*) begin
    // Split instruction register output into 2 bytes
    IR_LOW = IR_Q[7:0]; // Data byte
    IR_HIGH = IR_Q[15:8]; // Instruction byte
    
    // Discard first byte from memory when it is data
    CPU_DI_LOW = CPU_DI[7:0];
    
    // NOR all bits of ALU output to determine if there is a zero or not
    ZERO = ~|ALU_Q;
    
    // concatenate byte of zeros and accumulator output to store 8-bit data in 16-bit memory location
    CPU_DO = {8'b00000000, ACC_Q};
    
    // Serial ouptut for use with oscilloscope if programming an FPGA
    SERIAL_OUT = ~FDCE_Q;
   
    
  end
  
    // Displaying 4 LSB of the results on the 4 LEDs for the FPGA
    always @(*) begin
        out_led[0] = memory.mem[8'hFF][0];
        out_led[1] = memory.mem[8'hFF][1];
        out_led[2] = memory.mem[8'hFF][2];
        out_led[3] = memory.mem[8'hFF][3];
        
    end
    
endmodule
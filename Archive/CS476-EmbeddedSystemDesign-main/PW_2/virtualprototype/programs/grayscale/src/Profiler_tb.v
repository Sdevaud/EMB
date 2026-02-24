`timescale 1ns/1ns

/*
iverilog -s ProfilerTestBench -o testbench Profiler.v Profiler_tb.v
*/

module ProfilerTestBench;

  // Inputs
  reg start, clock, reset, stall, busIdle;
  reg [31:0] valueA, valueB;
  reg [7:0] ciN;

  // Outputs
  wire done;
  wire [31:0] result;

  // Instantiate the dut

  Profiler dut
  (
    .start(start),
    .clock(clock),
    .reset(reset),
    .stall(stall),
    .busIdle(busIdle),
    .valueA(valueA),
    .valueB(valueB),
    .ciN(ciN),
    .done(done),
    .result(result)
  );

  // Clock generation
  initial begin
    clock = 0;
    forever #5 clock = ~clock;  // 100 MHz clock
  end

  // Test sequence
  initial begin
    // Initialize Inputs
    start = 0;
    reset = 0;
    stall = 0;
    busIdle = 0;
    valueA = 32'b0;
    valueB = 32'b0;
    ciN = 8'b0;

    // reset test
    start = 1;
    reset = 1;
    stall = 1;
    busIdle = 1;
    valueA = 32'b0;
    valueB = 32'd15;
    ciN = 8'b0;
    #30;

    // start test
    start = 0;
    reset = 0;
    stall = 1;
    busIdle = 1;
    valueA = 32'b0;
    valueB = 32'd15;
    ciN = 8'b0;
    #30;

    // stall, busIdle and CPU test
    start = 1;
    reset = 0;
    stall = 1;
    busIdle = 1;
    valueA = 32'b0;
    valueB = 32'd15;
    ciN = 8'b0;
    #30;

    start = 1;
    reset = 0;
    stall = 1;
    busIdle = 1;
    valueA = 32'b0;
    valueB = 32'b0;
    ciN = 8'b0;
    #30;

    // outpu test (result and done)
    start = 1;
    reset = 0;
    stall = 1;
    busIdle = 0;
    valueA = 32'b1; // test the value of counter1 (stall)
    valueB = 32'd15;
    ciN = 8'b0;
    #30;

    start = 0; // result and done must be 0
    reset = 0;
    stall = 1;
    busIdle = 0;
    valueA = 32'b1; // test the value of counter1 (stall)
    valueB = 32'd15;
    ciN = 8'b0;
    #30;    

    start = 1;
    reset = 0;
    stall = 0;
    busIdle = 1;
    valueA = 32'b10; // test the value of counter2 (busIDle)
    valueB = 32'd15;
    ciN = 8'b0;
    #30;

    start = 1;
    reset = 0;
    stall = 0;
    busIdle = 0;
    valueA = 32'b11; // test the value of counter0 and 3 (CPU)
    valueB = 32'd15;
    ciN = 8'b0;
    #30;


    start = 1;
    reset = 0;
    stall = 0;
    busIdle = 0;
    valueA = 32'b11; 
    valueB = 32'd15;
    ciN = 8'b1; // test result when ciN !=customId
    #30;

    // test disables
    start = 1;
    reset = 0;
    stall = 1;
    busIdle = 1;
    valueA = 32'b11; 
    valueB = 8'b00011111;
    ciN = 8'b0;
    #30;

    valueB = 8'b00111111;
    #30

    valueB = 8'b01111111;
    #30

    valueB = 8'b11111111;
    #30


    // test reset of each counter and general reset 
    start = 1;
    reset = 0;
    stall = 1;
    busIdle = 1;
    valueA = 32'b11; 
    valueB = 32'd256;
    ciN = 8'b0;
    #30;

    valueB = 32'd512;
    #30

    valueB = 32'd1024;
    #30

    valueB = 32'd2048;
    #30

    reset = 1;
    #30


    // Test complete
    $finish;
  end

  initial
    begin
      $dumpfile("ProfilerSignals.vcd");
      $dumpvars(1,dut);
    end

endmodule

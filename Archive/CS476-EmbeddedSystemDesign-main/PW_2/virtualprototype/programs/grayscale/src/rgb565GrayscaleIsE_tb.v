`timescale 1ns / 1ns

/*
iverilog -s rgb565GrayscaleIsETestBench -o rgb565GrayscaleIsE_tb rgb565GrayscaleIsE.v rgb565GrayscaleIsE_tb.v
./rgb565GrayscaleIsE_tb
gtkwave RGB565.vcd 
*/


module rgb565GrayscaleIsETestBench;

    // Testbench Signals
    reg start;
    reg [31:0] valueA;    // RGB565 value
    reg [7:0] iseId;      // Custom instruction ID
    wire done;
    wire [31:0] result;

    // Instantiate the Design Under Test (DUT)
    rgb565GrayscaleIsE dut (
        .start(start),
        .valueA(valueA),
        .iseId(iseId),
        .done(done),
        .result(result)
    );

    initial begin
        // Initialize inputs
        start = 0;
        valueA = 32'b0;
        iseId = 8'd0;
        #30; 

        // test start
        valueA = 32'b00000000000101010100;  //682
        start = 1;     
        #30;    

        start = 0;     
        #30;

        // iseId test
        start = 1;
        iseId = 1'b1;
        #30;

        iseId = 1'b0;
        #30; 

        // valueA test
        valueA[31:16] = 16'b1;
        valueA[15:0] = 16'b0;
        #30;

        
        #100; 
        $finish;
    end

    initial begin
      $dumpfile("RGB565.vcd"); 
      $dumpvars(1, dut);       
    end

endmodule
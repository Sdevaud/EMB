`timescale 1ns/1ns

/*
iverilog -s ramDmaCiDMATestBench -o DMAbench_23 DMA_23.v DMA_23_tb.v
./DMAbench_23
gtkwave DMA_23_Signals.vcd
*/

module ramDmaCiDMATestBench;
    //Input
    reg start, clock, reset, dataValid, busError, s_busGrants;
    reg [31:0] valueA, valueB;
    reg [7:0] ciN;

    //Output
    wire done, busy;
    wire [31:0] result;

    ramDmaCiDMA dut
    (
        .start(start),
        .clock(clock),
        .reset(reset),
        .dataValid(dataValid),
        .busError(busError),
        .s_busGrants(s_busGrants),
        .valueA(valueA),
        .valueB(valueB),
        .ciN(ciN),
        .done(done),
        .result(result)
  );

    // Clock generation
    initial begin
        clock = 0;
        forever #15 clock = ~clock;  // 100 MHz clock
    end

    initial begin

        // Initialize Inputs
        start = 0;
        reset = 0;
        dataValid = 0;
        busError = 0;
        s_busGrants = 0;
        valueA = 32'b0;
        valueB = 32'd1500;
        ciN = 8'b0;
        #30;

        // test start
        valueA[12:9] = 4'b1011;
        dataValid = 1;
        s_busGrants = 1;
        #30;

        // bus Error
        dataValid = 0;
        s_busGrants = 0;
        start = 1;
        busError = 1;
        #30;

        // test s_busGrants and dataValid
        valueA[12:9] = 4'b0001;
        busError = 0;
        dataValid = 0;
        s_busGrants = 1;
        #30;

        valueA[12:9] = 4'b0101;
        dataValid = 1;
        s_busGrants = 0;
        #30;


        // test the buffer 
        valueA[12:9] = 4'b0001;
        dataValid = 1;
        s_busGrants = 1;
        #30;

        valueA[12:9] = 4'b0000;
        dataValid = 1;
        s_busGrants = 1;
        #30; 

        // test controller
        valueA[12:9] = 4'b1011;
        #30

        // test write memory
        valueA[12:9] = 4'b0001;
        valueA[8:0] = 9'd74;
        #30;

        // test read memory
        valueA[12:9] = 4'b0000;
        #30;

        valueA[8:0] = 9'd14;
        #30;

        // test write and read bus start
        valueA[12:9] = 4'b0011;
        #30;

        valueA[12:9] = 4'b0010;
        #30;

        // test write and read memory adress
        valueA[12:9] = 4'b0101;
        #30;

        valueA[12:9] = 4'b0100;
        #30;

        // test write and read block size
        valueA[12:9] = 4'b0111;
        #30;

        valueA[12:9] = 4'b0110;
        #30;

        // test write and read burst size
        valueA[12:9] = 4'b1001;
        #30;

        valueA[12:9] = 4'b1000;
        #30;

        // test read status register
        valueA[12:9] = 4'b1010;
        #30;

        // we let the fifo buffer deacrease
        s_busGrants = 0;

        #180;


        // test reset 
        reset = 1;
        #30;
        

        // Test complete
        $finish;
    end

    initial
        begin
            $dumpfile("DMA_23_Signals.vcd");
            $dumpvars(1,dut);
        end

endmodule
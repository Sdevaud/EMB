`timescale 1ns / 1ps

module ramDmaCi_tb;

    reg clock;
    reg reset;
    reg start;
    reg dataValid;
    reg busError;
    reg s_busGrants;
    reg [31:0] valueA;
    reg [31:0] valueB;
    reg [7:0] ciN;

    wire done;
    wire s_busrequest;
    wire [31:0] result;

    // Instantiate the ramDmaCi module
    ramDmaCi uut (
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
        .s_busrequest(s_busrequest),
        .result(result)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 100MHz clock
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        start = 0;
        dataValid = 0;
        busError = 0;
        s_busGrants = 0;
        valueA = 0;
        valueB = 0;
        ciN = 8'h00;

        // Wait for a few clock cycles
        #20;
        reset = 0;

        // Test 1: Write 2 to control register to initiate DMA transfer
        #10;
        valueA = 32'h00000A00; // Address for control register with write enable
        valueB = 32'h00000002; // Value to initiate DMA transfer
        start = 1;
        #10;
        start = 0;

        // Wait for DMA transfer to complete
        wait(done);
        #10;

        // Test 2: Write 3 to control register (invalid value)
        valueA = 32'h00000A00; // Address for control register with write enable
        valueB = 32'h00000003; // Invalid value
        start = 1;
        #10;
        start = 0;

        // Wait and check that DMA does not start
        #50;

        // Test 3: Simulate busError during DMA transfer
        valueA = 32'h00000A00; // Address for control register with write enable
        valueB = 32'h00000002; // Value to initiate DMA transfer
        start = 1;
        #10;
        start = 0;

        // After some time, assert busError
        #20;
        busError = 1;
        #10;
        busError = 0;

        // Wait for DMA transfer to handle busError
        wait(done);
        #10;

        // Test 4: Simulate busy signal during DMA transfer
        valueA = 32'h00000A00; // Address for control register with write enable
        valueB = 32'h00000002; // Value to initiate DMA transfer
        start = 1;
        #10;
        start = 0;

        // Simulate busy signal (assuming s_busGrants is used to indicate bus availability)
        #15;
        s_busGrants = 0; // Bus is busy
        #20;
        s_busGrants = 1; // Bus is available

        // Wait for DMA transfer to complete
        wait(done);
        #10;

        // Finish simulation
        $finish;
    end
    initial
        begin
            $dumpfile("ramDmaCi_24_tb.vcd");
            $dumpvars(1,ramDmaCi_tb);
        end
endmodule

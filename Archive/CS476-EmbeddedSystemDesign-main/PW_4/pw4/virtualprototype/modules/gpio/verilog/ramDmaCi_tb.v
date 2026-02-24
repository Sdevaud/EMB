`timescale 1ns/1ps

module ramDmaCi_tb;

    // Parameters
    parameter [7:0] CUSTOM_ID = 8'h01;

    // Testbench signals
    reg start;
    reg clock;
    reg reset;
    reg [31:0] valueA;
    reg [31:0] valueB;
    reg [7:0] ciN;
    wire done;
    wire [31:0] result;

    // Instantiate the DUT (Device Under Test)
    ramDmaCi #( .customId(CUSTOM_ID) ) dut (
        .start(start),
        .clock(clock),
        .reset(reset),
        .valueA(valueA),
        .valueB(valueB),
        .ciN(ciN),
        .done(done),
        .result(result)
    );

    // Clock generation (50 MHz)
    initial clock = 0;
    always #10 clock = ~clock; // 20ns period

    // Test procedure
    initial begin
        // Initialize signals
        start = 0;
        reset = 1;
        valueA = 0;
        valueB = 0;
        ciN = 0;

        // Apply reset
        #20;
        reset = 0;

        // Test 1: Write to memory
        ciN = CUSTOM_ID;
        valueA = (1 << 9) | 5; 
        valueB = 32'hDEADBEEF; // Data to write
        start = 1;
        #20;
        start = 0;
        #20;

        // Check if write is done
        // $display("Test 1: Write to memory");
        // $display("valueA = %h, valueB = %h, done = %b", valueA, valueB, done);
        if (!done) $display("Write operation failed!");
        else $display("Write operation successful!");

        // Test 2: Read from memory
        ciN = CUSTOM_ID;
        valueA = 32'h00000005; // Address 5, write-enable = 0
        start = 1;
        #20;
        start = 0;
        #40; // Wait for 2 cycles

        // Check if read is done and result is correct
        // $display("Test 2: Read from memory");
        // $display("valueA = %h, result = %h, done = %b", valueA, result, done);
        if (!done || result != 32'hDEADBEEF) $display("Read operation failed!");
        else $display("Read operation successful!");

        // Test 3: Invalid address
        ciN = CUSTOM_ID;
        valueA = 32'hFFFF0005; // Invalid address (bits 31:10 are not 0)
        start = 1;
        #20;
        start = 0;
        #20;

        // Check if operation is ignored
        // $display("Test 3: Invalid address");
        // $display("valueA = %h, done = %b", valueA, done);
        if (done) $display("Invalid address operation failed!");
        else $display("Invalid address operation successful!");

        // Test 4: Write to another address
        ciN = CUSTOM_ID;
        valueA = (1 << 9) | 16;
        valueB = 32'hCAFEBABE; // Data to write
        start = 1;
        #20;
        start = 0;
        #20;

        // Check if write is done
        // $display("Test 4: Write to another address");
        // $display("valueA = %h, valueB = %h, done = %b", valueA, valueB, done);
        if (!done) $display("Write operation to address 16 failed!");
        else $display("Write operation to address 16 successful!");

        // Test 5: Read from another address
        ciN = CUSTOM_ID;
        valueA = 32'h00000010; // Address 16, write-enable = 0
        start = 1;
        #20;
        start = 0;
        #40; // Wait for 2 cycles

        // Check if read is done and result is correct
        // $display("Test 5: Read from another address");
        // $display("valueA = %h, result = %h, done = %b", valueA, result, done);
        if (!done || result != 32'hCAFEBABE) $display("Read operation from address 16 failed!");
        else $display("Read operation from address 16 successful!");

        // End simulation
        $stop;
    end

endmodule
module rgb565GrayscaleIsE #(parameter [7:0] customInstructionId = 8'd0)
                            (input wire         start,
                             input wire [31:0]  valueA,    // RGB565 value
                             input wire [7:0]   iseId,
                             output wire        done,
                             output wire [31:0] result);

    reg [31:0] result_reg;  // Temporary register for the result
    reg done_reg;           // Temporary register for the done signal
    reg [4:0] red, blue;
    reg [5:0] green;

    // Initial values
    initial begin
        result_reg = 32'b0;
        done_reg = 1'b0;
    end

    always @(*) begin

        // Check if the custom instruction ID matches
        if ((iseId == customInstructionId) && start) begin

            // Extract RGB565 values from valueA
            // the lower 16 bits of valueA
            red = valueA[15:11];   
            green = valueA[10:5];  
            blue = valueA[4:0];  

            // Calculate grayscale using the pre-optimized formula
            result_reg = ((54 * red) + (183 * green) + (19 * blue)) >> 8;

            //  grayscale value in the lower 8 bits of result
            result_reg[7:0] = result_reg[7:0];
            result_reg[31:8] = 24'b0;
            
            // Set done signal
            done_reg = 1'b1;
        end else begin
            done_reg = 1'b0;
            result_reg = 32'b0;
        end
    end

    // Continuous assignments to output wires
    assign done = done_reg;  
    assign result = result_reg;

endmodule

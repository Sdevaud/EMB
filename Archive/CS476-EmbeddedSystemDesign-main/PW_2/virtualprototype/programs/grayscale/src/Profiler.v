module Profiler #(parameter [7:0] customId = 8'h00)
                  (input wire         start,
                   input wire         clock,
                   input wire         reset,
                   input wire         stall,
                   input wire         busIdle,
                   input wire [31:0]  valueA,
                   input wire [31:0]  valueB,
                   input wire [7:0]   ciN,
                   output wire        done,   // remains wire
                   output wire [31:0] result  // remains wire
                  );

    reg [31:0] counter0, counter1, counter2, counter3;
    reg done_reg;   // temporary register for done
    reg [31:0] result_reg;  // temporary register for result

    // Initial values
    initial begin
        counter0 = 32'b0;
        counter1 = 32'b0;
        counter2 = 32'b0;
        counter3 = 32'b0;
        done_reg = 1'b0;
        result_reg = 32'b0;
    end

   // Always block to update counters and done_reg, result_reg
   always @(posedge clock or posedge reset) begin
        // Reset values when reset is asserted
        if (reset) begin
            counter0 <= 32'b0;
            counter1 <= 32'b0;
            counter2 <= 32'b0;
            counter3 <= 32'b0;
            done_reg <= 1'b0;
            result_reg <= 32'b0;
        end else begin
            // Counter 0: count the CPU enable
            if (valueB[8]) begin
                counter0 <= 32'b0;
            end else if (valueB[0] && !valueB[4] && start) begin
                counter0 <= counter0 + 1;
            end

            // Counter 1: count the μC stall cycles
            if (valueB[9]) begin
                counter1 <= 32'b0;
            end else if (valueB[1] && stall && !valueB[5] && start) begin
                counter1 <= counter1 + 1;
            end

            // Counter 2: count the bus-idle cycles
            if (valueB[10]) begin
                counter2 <= 32'b0;
            end else if (valueB[2] && busIdle && !valueB[6] && start) begin
                counter2 <= counter2 + 1;
            end

            // Counter 3: count the CPU cycles
            if (valueB[11]) begin
                counter3 <= 32'b0;
            end else if (valueB[3] && !valueB[7] && start) begin
                counter3 <= counter3 + 1;
            end

            // Determine the done and result values based on conditions
            if ((ciN != customId) || !start) begin
                result_reg <= 32'b0;
                done_reg <= 1'b0;
            end else begin
                case (valueA[1:0])
                    2'd0: result_reg <= counter0;
                    2'd1: result_reg <= counter1;
                    2'd2: result_reg <= counter2;
                    2'd3: result_reg <= counter3;
                    default: result_reg <= 32'b0;
                endcase
                done_reg <= 1'b1;
            end
        end
    end      

    // Continuous assignments to output wires
    assign done = done_reg;         // connect register to output wire
    assign result = result_reg;     // connect register to output wire

endmodule

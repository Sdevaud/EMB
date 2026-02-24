module ramDmaCi #(parameter [7:0] customId = 8'h00)
(
    input wire start,
    input wire clock,
    input wire reset,
    input wire [31:0] valueA,
    input wire [31:0] valueB,
    input wire [7:0] ciN,
    output reg done,
    output reg [31:0] result
);

    // Memory declaration: 512x32-bit dual-port SSRAM
    reg [31:0] memoryContent [0:511];

    // Port A signals (CPU interface)
    wire [8:0] addressA = valueA[8:0];
    wire writeEnableA = valueA[9];
    wire validAddressA = (valueA[31:10] == 0);

    // Port B signals (DMA interface - currently unused)
    wire [8:0] addressB = 9'd0;
    wire writeEnableB = 1'b0;
    wire [31:0] dataInB = 32'd0;

    // Internal signals for read delay
    reg [31:0] readDataA;
    reg readPending;

    // Port A logic (CPU interface)
    reg done_next;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            done <= 0;
            result <= 0;
            readPending <= 0;
        end else begin
            done <= done_next;

            if (readPending) begin
                result <= readDataA;
                readPending <= 0;
                done_next <= 1;
            end else if (start && ciN == customId && validAddressA) begin
                if (writeEnableA) begin
                    memoryContent[addressA] <= valueB;
                    done_next <= 1;
                end else begin
                    readDataA <= memoryContent[addressA];
                    readPending <= 1;
                    done_next <= 0;
                end
            end else begin
                done_next <= 0;
            end
        end
    end



    // Port B logic (currently unused, but ready for DMA integration)
    always @(posedge clock) begin
        if (writeEnableB) begin
            memoryContent[addressB] <= dataInB;
        end
    end
endmodule
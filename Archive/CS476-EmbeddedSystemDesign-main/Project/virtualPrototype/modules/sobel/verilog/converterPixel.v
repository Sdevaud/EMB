module converterPixel #(parameter [7:0] customInstructionId = 8'd22 )
(
    input  wire        start,
    input  wire [31:0] valueA, // {00, P3, P2, P1}
    input  wire [31:0] valueB, // {00, P5, 00, P4}
    input  wire [7:0]  iseId,
    output wire        done,
    output wire [31:0] result0, // First 4 pixels: {P4, P3, P2, P1}
);

    wire s_isMyIse = (iseId == customInstructionId) ? start : 1'b0;

    // Extract pixels from inputs
    wire [7:0] P3 = valueA[23:16];
    wire [7:0] P2 = valueA[15:8];
    wire [7:0] P1 = valueA[7:0];

    wire [7:0] P4 = valueB[7:0];

    assign done    = s_isMyIse;
    assign result0 = (s_isMyIse == 1'b1) ? {P4, P3, P2, P1} : 32'd0;
endmodule

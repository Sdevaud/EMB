module converterPixel1 #(parameter [7:0] customInstructionId = 8'd23 )
(
    input  wire        start,
    input  wire [31:0] valueB, // {00, P5, 00, P4}
    input  wire [31:0] valueC, // {00, P8, P7, P6}
    input  wire [7:0]  iseId,
    output wire        done,
    output wire [31:0] result1  // Next 4 pixels: {P8, P7, P6, P5}
);

    wire s_isMyIse = (iseId == customInstructionId) ? start : 1'b0;

    // Extract pixels from inputs
    wire [7:0] P5 = valueB[23:16];

    wire [7:0] P8 = valueC[23:16];
    wire [7:0] P7 = valueC[15:8];
    wire [7:0] P6 = valueC[7:0];

    assign done    = s_isMyIse;
    assign result1 = (s_isMyIse == 1'b1) ? {P8, P7, P6, P5} : 32'd0;

endmodule
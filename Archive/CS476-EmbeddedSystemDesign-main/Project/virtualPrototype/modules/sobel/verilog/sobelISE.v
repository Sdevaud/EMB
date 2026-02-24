module sobelIse #(parameter [7:0] customInstructionId = 8'd24 )
(
    input  wire        start,
    input  wire [31:0] valueA0, valueB0, // Inputs for Sobel 0
    input  wire [31:0] valueA1, valueB1, // Inputs for Sobel 1
    input  wire [31:0] valueA2, valueB2, // Inputs for Sobel 2
    input  wire [31:0] valueA3, valueB3, // Inputs for Sobel 3
    input  wire [7:0]  iseId,
    output wire        done,
    output wire [31:0] result // {sobel3, sobel2, sobel1, sobel0}
);

    wire s_isMyIse = (iseId == customInstructionId) ? start : 1'b0;

    wire [31:0] s_sobelResult0, s_sobelResult1, s_sobelResult2, s_sobelResult3;
    wire        s_sobelDone0, s_sobelDone1, s_sobelDone2, s_sobelDone3;

    sobel sobel0 (
        .start  (s_isMyIse),
        .valueA (valueA0),
        .valueB (valueB0),
        .iseId  (customInstructionId),
        .done   (s_sobelDone0),
        .result (s_sobelResult0)
    );
    sobel sobel1 (
        .start  (s_isMyIse),
        .valueA (valueA1),
        .valueB (valueB1),
        .iseId  (customInstructionId),
        .done   (s_sobelDone1),
        .result (s_sobelResult1)
    );
    sobel sobel2 (
        .start  (s_isMyIse),
        .valueA (valueA2),
        .valueB (valueB2),
        .iseId  (customInstructionId),
        .done   (s_sobelDone2),
        .result (s_sobelResult2)
    );
    sobel sobel3 (
        .start  (s_isMyIse),
        .valueA (valueA3),
        .valueB (valueB3),
        .iseId  (customInstructionId),
        .done   (s_sobelDone3),
        .result (s_sobelResult3)
    );

    assign done = s_isMyIse;
    assign result = (s_isMyIse == 1'b1) ?
        { s_sobelResult3[7:0], s_sobelResult2[7:0], s_sobelResult1[7:0], s_sobelResult0[7:0] } :
        32'd0;

endmodule
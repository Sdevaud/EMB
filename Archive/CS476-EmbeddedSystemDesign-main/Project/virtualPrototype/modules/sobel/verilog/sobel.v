module sobel #(
    parameter [7:0] customInstructionId = 8'd20
)(
    input  wire         start,
    input  wire [31:0]  valueA, // P1, P2, P3, P4
    input  wire [31:0]  valueB, // P6, P7, P8, P9
    input  wire [7:0]   iseId,
    output wire         done,
    output wire [31:0]  result
);

    wire s_isMyIse = (iseId == customInstructionId) ? start : 1'b0;
    wire [7:0] max_mag = 8'd255;

    // Extract 8 pixel from valueA and valueB
    wire signed [10:0] p1 = {3'b000, valueA[7:0]};
    wire signed [10:0] p2 = {3'b000, valueA[15:8]};
    wire signed [10:0] p3 = {3'b000, valueA[23:16]};
    wire signed [10:0] p4 = {3'b000, valueA[31:24]};

    wire signed [10:0] p6 = {3'b000, valueB[7:0]};
    wire signed [10:0] p7 = {3'b000, valueB[15:8]};
    wire signed [10:0] p8 = {3'b000, valueB[23:16]};
    wire signed [10:0] p9 = {3'b000, valueB[31:24]};

    // compute Gx and Gy
    wire signed [12:0] Gx = p1 + (p2 <<< 1) + p3 - p7 - (p8 <<< 1) - p9;
    wire signed [12:0] Gy = p3 + (p6 <<< 1) + p9 - p1 - (p4 <<< 1) - p7;

    wire [12:0] absGx = (Gx < 0) ? -Gx : Gx;
    wire [12:0] absGy = (Gy < 0) ? -Gy : Gy;

    wire [13:0] mag = absGx + absGy;

    wire [7:0] sobelOut = (mag > max_mag) ? max_mag : mag[7:0];

    assign done   = s_isMyIse;
    assign result = (s_isMyIse == 1'b1) ? {24'd0, sobelOut} : 32'd0;

endmodule

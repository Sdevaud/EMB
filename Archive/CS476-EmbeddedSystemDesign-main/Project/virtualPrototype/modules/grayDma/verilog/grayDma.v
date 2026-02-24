// grayDma: DMA grayscale conversion module
// Reads RGB565 pixels from SSRAM, converts to grayscale, writes result to destination

module grayDma #(
    parameter [7:0] customId = 8'h30
) (
    input wire        start,
    input wire        clock,
    input wire        reset,
    input wire [31:0] srcAddr,   // Source address in SSRAM (read RGB565)
    input wire [31:0] dstAddr,   // Destination address in SSRAM (write grayscale)
    input wire [9:0]  numPixels, // Number of pixels to process
    output wire       done,

    // SSRAM dual-port interface (A: read, B: write)
    output reg        ssramReadEnable,
    output reg        ssramWriteEnable,
    output reg [8:0]  ssramReadAddr,
    output reg [8:0]  ssramWriteAddr,
    input wire [15:0] ssramReadData, // RGB565 pixel
    output reg [7:0]  ssramWriteData // Grayscale pixel
);

    // State machine
    localparam IDLE = 2'd0, READ = 2'd1, CONVERT = 2'd2, WRITE = 2'd3, DONE = 2'd4;
    reg [2:0] state, nextState;
    reg [9:0] pixelCount;

    // Grayscale computation wires
    wire [7:0] grayscale;
    rgb565Grayscale grayscaleUnit(
        .rgb565(ssramReadData),
        .grayscale(grayscale)
    );

    // State machine logic
    always @(posedge clock) begin
        if (reset) begin
            state <= IDLE;
            pixelCount <= 0;
        end else begin
            state <= nextState;
            if (state == WRITE)
                pixelCount <= pixelCount + 1;
            else if (state == IDLE && start)
                pixelCount <= 0;
        end
    end

    always @* begin
        nextState = state;
        case (state)
            IDLE:    nextState = start ? READ : IDLE;
            READ:    nextState = CONVERT;
            CONVERT: nextState = WRITE;
            WRITE:   nextState = (pixelCount + 1 >= numPixels) ? DONE : READ;
            DONE:    nextState = IDLE;
            default: nextState = IDLE;
        endcase
    end

    // SSRAM control
    always @* begin
        ssramReadEnable = (state == READ);
        ssramWriteEnable = (state == WRITE);
        ssramReadAddr = srcAddr[8:0] + pixelCount;
        ssramWriteAddr = dstAddr[8:0] + pixelCount;
        ssramWriteData = grayscale;
    end

    assign done = (state == DONE);

endmodule

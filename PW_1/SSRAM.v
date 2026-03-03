module singlePortSSRAM #( parameter bitwidth = 8,
parameter nrOfEntries = 512,
parameter readAfterWrite = 0 )
( input wire clock,
writeEnable,
input wire [$clog2(nrOfEntries)-1 : 0] address,
input wire [bitwidth-1 : 0] dataIn,
output reg [bitwidth-1 : 0] dataOut);
reg [bitwidth-1 : 0] memoryContent [nrOfEntries-1 : 0];
always @(posedge clock)module singlePortSSRAM #( parameter bitwidth = 8,
parameter nrOfEntries = 512,
parameter readAfterWrite = 0 )
( input wire clock,
writeEnable,
input wire [$clog2(nrOfEntries)-1 : 0] address,
input wire [bitwidth-1 : 0] dataIn,
output reg [bitwidth-1 : 0] dataOut);
reg [bitwidth-1 : 0] memoryContent [nrOfEntries-1 : 0];
always @(posedge clock)
begin
if (readAfterWrite != 0) dataOut = memoryContent[address];
if (writeEnable == 1’b1) memoryContent[address] = dataIn;
if (readAfterWrite == 0) dataOut = memoryContent[address];
end
endmodule
begin
if (readAfterWrite != 0) dataOut = memoryContent[address];
if (writeEnable == 1’b1) memoryContent[address] = dataIn;
if (readAfterWrite == 0) dataOut = memoryContent[address];
end
endmodule
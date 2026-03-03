module fifo #(parameter nrOfEntries = 16,
              parameter bitWidth = 32)
              (input wire                 clock,
                                          reset,
                                          push,
                                          pop,
              input wire [bitWidth-1:0]   pushData,
              output wire                 full,
                                          empty,
              output wire [bitWidth-1:0]  popData);

  reg [7:0] push_value, pop_value;
  
  counter #(.WIDTH(8)) dut 
    ( .reset(reset),
      .clock(clock),
      .enable(push),
      .direction(1'b1),
      .counterValue(push_value));

  counter #(.WIDTH(8)) dut 
    ( .reset(reset),
      .clock(clock),
      .enable(pop),
      .direction(1'b1),
      .counterValue(pop_value));

  always @(posedge clock)


endmodule


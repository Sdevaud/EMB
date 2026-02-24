module fifo #(
    parameter nrOfEntries = 16,    
    parameter bitWidth = 64         
)(
    input wire clock,
    input wire reset,
    input wire push,
    input wire pop,
    input wire [bitWidth-1:0] pushData,
    output wire [bitWidth-1:0] popData,
    output wire full,
    output wire empty
);

    
    localparam ADDR_WIDTH = $clog2(nrOfEntries);

    reg [bitWidth-1:0] mem [0:nrOfEntries-1];  
    reg [ADDR_WIDTH-1:0] write_ptr = 0;         
    reg [ADDR_WIDTH-1:0] read_ptr = 0;          
    reg [ADDR_WIDTH:0] count = 0;               

    assign full = (count == nrOfEntries);
    assign empty = (count == 0);
    assign popData = mem[read_ptr];

always @(posedge clock or posedge reset) begin
    if (reset) begin
        write_ptr <= 0;
        read_ptr <= 0;
        count <= 0;
    end else begin
        case ({push, pop})
            2'b10: begin  // Push only
                if (!full) begin
                    mem[write_ptr] <= pushData;
                    write_ptr <= write_ptr + 1;
                    count <= count + 1;
                end
            end

            2'b01: begin  // Pop only
                if (!empty) begin
                    read_ptr <= read_ptr + 1;
                    count <= count - 1;
                end
            end

            2'b11: begin  // Push and Pop simultaneously
                if (!full && !empty) begin
                    mem[write_ptr] <= pushData;
                    write_ptr <= write_ptr + 1;
                    read_ptr <= read_ptr + 1;
                end
            end

            default: ; 
        endcase
    end
end

endmodule

module ramDmaCi #(
    parameter [7:0] customId = 8'h00
)(
    input wire          start,
                        clock,
                        reset,
                        dataValid,
                        busError,
                        s_busGrants,
    input wire [31:0]   valueA,
    input wire [31:0]   valueB,
    input wire [7:0]    ciN,

    output wire         done,
                        s_busrequest,
    output wire [31:0]  result
);

    // FIFO parameter
    wire full, empty;
    reg push, pop;
    wire [63:0] popData;
    reg [31:0] valueA_ff, valueB_ff;

    // FIFO initialization
    fifo #(
        .nrOfEntries(16),  
        .bitWidth(64)      
    ) fifo_instance (
        .clock(clock),
        .reset(reset),
        .push(push),
        .pop(pop),
        .pushData({valueA, valueB}),
        .full(full),
        .empty(empty),
        .popData(popData)
    );

    // === CI Memory (Port A and Port B) ===
    reg [31:0] memory [0:511];

    // DMA registers
    reg [31:0] dma_bus_addr;
    reg [8:0]  dma_mem_addr;
    reg [9:0]  dma_block_size;
    reg [7:0]  dma_burst_size;
    reg [1:0]  dma_status;  // 0 = idle, 1 = active, 2 = bus error
    reg        dma_controller;  // Direction: 0 = bus->mem, 1 = mem->bus

    // intermediate output
    reg        done_reg, s_busrequest_reg; 
    reg [31:0] result_reg;

    // Bus output registers
    reg [31:0] bus_addr_reg;
    reg [31:0] bus_data_reg;
    reg        bus_write_reg;

    integer i;

    initial begin
        dma_bus_addr <= 32'b0;
        dma_mem_addr <= 9'b0;
        dma_block_size <= 10'b0;
        dma_burst_size <= 8'b0;
        dma_status <= 2'b0;
        dma_controller <= 0;
        done_reg <= 0;
        s_busrequest_reg <= 1;
        result_reg <= 32'b0;
        bus_addr_reg <= 32'b0;
        bus_data_reg <= 32'b0;
        bus_write_reg <= 1'b0;
        push <= 0;
        pop <= 0;

        for (i = 0; i < 512; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end

    always @(negedge clock or reset) begin
        if (reset) begin
            dma_bus_addr <= 32'b0;
            dma_mem_addr <= 9'b0;
            dma_block_size <= 10'b0;
            dma_burst_size <= 8'b0;
            dma_status <= 2'b0;
            dma_controller <= 0;
            done_reg <= 0;
            s_busrequest_reg <= 1;
            result_reg <= 32'b0;
            bus_addr_reg <= 32'b0;
            bus_data_reg <= 32'b0;
            bus_write_reg <= 1'b0;
            push <= 0;
            pop <= 0;

            for (i = 0; i < 512; i = i + 1) begin
                memory[i] <= 32'b0;
            end
        end else begin
            pop <= 0;
            push <= 0;
            done_reg <= 0;
            bus_write_reg <= 1'b0;

            if (start) begin
                if ((dma_status[0] == 1) && busError) begin
                    // Handle bus error
                    dma_status <= 2'b10;
                    dma_controller <= 0;
                    done_reg <= 1;
                    s_busrequest_reg <= 1;
                end else if (dma_status[0] == 1) begin
                    // DMA is active
                    if (s_busGrants) begin
                        if (dma_controller == 1'b1) begin
                            // MEM->BUS transfer
                            if (dma_block_size != 0) begin
                                if (!dataValid) begin
                                    // Prepare next transfer if not busy
                                    bus_addr_reg <= dma_bus_addr;
                                    bus_data_reg <= memory[dma_mem_addr];
                                    bus_write_reg <= 1'b1;
                                    s_busrequest_reg <= 1;
                                end else begin
                                    // Wait until dataValid goes low
                                    s_busrequest_reg <= 1;
                                end

                                // When transaction acknowledged
                                if (dataValid) begin
                                    dma_bus_addr <= dma_bus_addr + 4;
                                    dma_mem_addr <= dma_mem_addr + 1;
                                    dma_block_size <= dma_block_size - 1;
                                    bus_write_reg <= 1'b0;

                                    if (dma_block_size == 1) begin
                                        // Transfer complete
                                        dma_status <= 2'b00;
                                        done_reg <= 1;
                                        s_busrequest_reg <= 1;
                                    end
                                end
                            end
                        end
                    end
                end else if ((s_busGrants && dataValid) || (!empty)) begin
                    // Handle normal CPU accesses
                    s_busrequest_reg <= 0;
                    
                    if ((valueA[12:9] == 4'b1011) || (dma_status[0] == 1)) begin
                        if (empty) begin
                            valueA_ff <= valueA;
                            valueB_ff <= valueB;
                        end else begin
                            push <= 1;
                            pop <= 1;
                            valueA_ff <= popData[63:32];
                            valueB_ff <= popData[31:0];
                        end

                        case (valueA_ff[12:10])
                            3'b000: begin
                                if (valueA_ff[9]) memory[valueA_ff[8:0]] <= valueB_ff;
                                else result_reg <= memory[valueA_ff[8:0]];
                            end

                            3'b001: begin
                                if (valueA_ff[9]) dma_bus_addr <= valueB_ff;
                                else result_reg <= dma_bus_addr;
                            end

                            3'b010: begin
                                if (valueA_ff[9]) dma_mem_addr <= valueB_ff[8:0];
                                else result_reg[8:0] <= dma_mem_addr;
                            end

                            3'b011: begin
                                if (valueA_ff[9]) dma_block_size <= valueB_ff[9:0];
                                else result_reg[9:0] <= dma_block_size;
                            end

                            3'b100: begin
                                if (valueA_ff[9]) dma_burst_size <= valueB_ff[7:0];
                                else result_reg[7:0] <= dma_burst_size;
                            end

                            3'b101: begin
                                if (valueA_ff[9]) begin
                                    // Control register write
                                    if (valueB_ff == 32'd1) begin
                                        dma_status <= 2'b01;
                                        dma_controller <= 1'b0; // Bus to Memory
                                    end else if (valueB_ff == 32'd2) begin
                                        dma_status <= 2'b01;
                                        dma_controller <= 1'b1; // Memory to Bus
                                    end else begin
                                        dma_status <= 2'b00; // invalid
                                    end
                                end else begin
                                    // Control register read
                                    result_reg[1:0] <= dma_status;
                                end
                            end

                            default: done_reg <= 0;
                        endcase
                    end else begin
                        push <= 1;
                    end

                    if (valueA[12:9] == 4'b1011) dma_status[0] <= 1;
                end
            end
        end
    end

    assign done = done_reg;
    assign result = result_reg;
    assign s_busrequest = s_busrequest_reg;

endmodule

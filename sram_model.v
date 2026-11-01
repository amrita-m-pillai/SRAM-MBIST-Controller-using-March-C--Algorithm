module sram_model #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 8
)(
    input wire                   clk,
    input wire                   write_enable,
    input wire                   read_enable,

    input wire [ADDR_WIDTH-1:0]  address,
    input wire [DATA_WIDTH-1:0]  write_data,

    output reg [DATA_WIDTH-1:0]  read_data
);

    // 2^ADDR_WIDTH memory locations
    localparam DEPTH = (1 << ADDR_WIDTH);

    // SRAM array
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];


    always @(posedge clk) begin

        // Write operation
        if (write_enable)

            mem[address] <= write_data;


        // Synchronous read operation
        if (read_enable)

            read_data <= mem[address];

    end

endmodule
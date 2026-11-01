module address_generator #(
    parameter ADDR_WIDTH = 6
)(
    input wire                   clk,
    input wire                   reset,

    input wire                   load,
    input wire [ADDR_WIDTH-1:0]  load_value,

    input wire                   increment,
    input wire                   decrement,

    output reg [ADDR_WIDTH-1:0]  address
);

    always @(posedge clk or posedge reset) begin

        if (reset)

            address <= 0;

        else if (load)

            address <= load_value;

        else if (increment)

            address <= address + 1'b1;

        else if (decrement)

            address <= address - 1'b1;

    end

endmodule
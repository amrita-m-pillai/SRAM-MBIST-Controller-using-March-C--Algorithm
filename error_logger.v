module error_logger #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 8
)(
    input wire                   clk,
    input wire                   reset,

    input wire                   clear,
    input wire                   capture,

    input wire [ADDR_WIDTH-1:0]  address,
    input wire [DATA_WIDTH-1:0]  expected_data,
    input wire [DATA_WIDTH-1:0]  actual_data,

    output reg                   error,
    output reg [ADDR_WIDTH-1:0]  error_address,
    output reg [DATA_WIDTH-1:0]  expected_data_out,
    output reg [DATA_WIDTH-1:0]  actual_data_out
);

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            error <= 1'b0;
            error_address <= 0;
            expected_data_out <= 0;
            actual_data_out <= 0;

        end

        else if (clear) begin

            error <= 1'b0;
            error_address <= 0;
            expected_data_out <= 0;
            actual_data_out <= 0;

        end

        else if (capture && !error) begin

            error <= 1'b1;

            error_address <= address;

            expected_data_out <= expected_data;

            actual_data_out <= actual_data;

        end

    end

endmodule
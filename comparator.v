module comparator #(
    parameter DATA_WIDTH = 8
)(
    input wire                   compare_enable,

    input wire [DATA_WIDTH-1:0]  actual_data,
    input wire [DATA_WIDTH-1:0]  expected_data,

    output wire                  mismatch
);

    assign mismatch =
        compare_enable &&
        (actual_data != expected_data);

endmodule
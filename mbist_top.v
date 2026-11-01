module mbist_top #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 8
)(
    input wire                   clk,
    input wire                   reset,
    input wire                   start,

    output wire                  busy,
    output wire                  done,
    output wire                  pass,
    output wire                  error,

    output wire [ADDR_WIDTH-1:0] error_address,
    output wire [DATA_WIDTH-1:0] expected_error_data,
    output wire [DATA_WIDTH-1:0] actual_error_data
);


    //========================================================
    // INTERNAL SIGNALS
    //========================================================

    // SRAM
    wire mem_we;
    wire mem_re;

    wire [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;


    // Comparator
    wire [DATA_WIDTH-1:0] expected_data;
    wire compare_enable;
    wire mismatch;


    // Address generator
    wire [ADDR_WIDTH-1:0] address;

    wire address_load;
    wire address_increment;
    wire address_decrement;

    wire [ADDR_WIDTH-1:0] address_load_value;


    // Error logger
    wire logger_clear;
    wire logger_error;


    //========================================================
    // MBIST CONTROLLER
    //========================================================

    mbist_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_controller (

        .clk(clk),
        .reset(reset),
        .start(start),

        .mismatch(mismatch),
        .address(address),

        .mem_we(mem_we),
        .mem_re(mem_re),
        .mem_wdata(mem_wdata),

        .expected_data(expected_data),
        .compare_enable(compare_enable),

        .address_load(address_load),
        .address_increment(address_increment),
        .address_decrement(address_decrement),
        .address_load_value(address_load_value),

        .logger_clear(logger_clear),

        .busy(busy),
        .done(done),
        .pass(pass),
        .error(error)

    );


    //========================================================
    // ADDRESS GENERATOR
    //========================================================

    address_generator #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_address (

        .clk(clk),
        .reset(reset),

        .load(address_load),
        .load_value(address_load_value),

        .increment(address_increment),
        .decrement(address_decrement),

        .address(address)

    );


    //========================================================
    // SRAM UNDER TEST
    //========================================================

    sram_model #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_memory (

        .clk(clk),

        .write_enable(mem_we),
        .read_enable(mem_re),

        .address(address),
        .write_data(mem_wdata),

        .read_data(mem_rdata)

    );


    //========================================================
    // COMPARATOR
    //========================================================

    comparator #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_comparator (

        .compare_enable(compare_enable),

        .actual_data(mem_rdata),
        .expected_data(expected_data),

        .mismatch(mismatch)

    );


    //========================================================
    // ERROR LOGGER
    //========================================================

    error_logger #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_logger (

        .clk(clk),
        .reset(reset),

        .clear(logger_clear),
        .capture(mismatch),

        .address(address),

        .expected_data(expected_data),
        .actual_data(mem_rdata),

        .error(logger_error),
        .error_address(error_address),
        .expected_data_out(expected_error_data),
        .actual_data_out(actual_error_data)

    );

endmodule
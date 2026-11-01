module mbist_controller #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  start,

    input  wire                  mismatch,
    input  wire [ADDR_WIDTH-1:0] address,

    // SRAM control
    output reg                   mem_we,
    output reg                   mem_re,
    output reg  [DATA_WIDTH-1:0] mem_wdata,

    // Comparator control
    output reg  [DATA_WIDTH-1:0] expected_data,
    output reg                   compare_enable,

    // Address generator control
    output reg                   address_load,
    output reg                   address_increment,
    output reg                   address_decrement,
    output reg  [ADDR_WIDTH-1:0] address_load_value,

    // Error logger
    output reg                   logger_clear,

    // Status
    output wire                  busy,
    output wire                  done,
    output wire                  pass,
    output wire                  error
);

    //========================================================
    // FSM STATES
    //========================================================

    localparam ST_IDLE      = 3'b000;
    localparam ST_WRITE0_UP = 3'b001;
    localparam ST_R0W1_UP   = 3'b010;
    localparam ST_R1W0_UP   = 3'b011;
    localparam ST_R0W1_DOWN = 3'b100;
    localparam ST_R1W0_DOWN = 3'b101;
    localparam ST_R0_UP     = 3'b110;

    localparam LAST_ADDRESS = {ADDR_WIDTH{1'b1}};

    reg [2:0] state;
    reg [2:0] next_state;

    // Indicates that a read was issued
    // and its result is now ready to be checked.
    reg read_pending;

    // Status registers
    reg done_flag;
    reg error_flag;


    //========================================================
    // 1. STATE REGISTER
    //========================================================

    always @(posedge clk or posedge reset) begin

        if (reset)
            state <= ST_IDLE;

        else
            state <= next_state;

    end


    //========================================================
    // 2. NEXT-STATE + OUTPUT LOGIC
    //========================================================

    always @(*) begin

        // Default values
        next_state = state;

        mem_we = 1'b0;
        mem_re = 1'b0;
        mem_wdata = 0;

        expected_data = 0;
        compare_enable = 1'b0;

        address_load = 1'b0;
        address_increment = 1'b0;
        address_decrement = 1'b0;
        address_load_value = 0;

        logger_clear = 1'b0;


        case (state)

            //================================================
            // IDLE
            //================================================

            ST_IDLE: begin

                if (start) begin

                    next_state = ST_WRITE0_UP;

                    // Start from address 0
                    address_load = 1'b1;
                    address_load_value = 0;

                    // Clear previous error
                    logger_clear = 1'b1;

                end

            end


            //================================================
            // up(w0)
            //================================================

            ST_WRITE0_UP: begin

                mem_we = 1'b1;
                mem_wdata = 0;

                if (address == LAST_ADDRESS) begin

                    // Move to next March operation
                    next_state = ST_R0W1_UP;

                    // Start next operation from address 0
                    address_load = 1'b1;
                    address_load_value = 0;

                end

                else begin

                    address_increment = 1'b1;

                end

            end


            //================================================
            // up(r0,w1)
            //================================================

            ST_R0W1_UP: begin

                expected_data = 0;

                if (!read_pending) begin

                    // Issue read
                    mem_re = 1'b1;

                end

                else begin

                    // Read result is available
                    compare_enable = 1'b1;

                    if (mismatch) begin

                        next_state = ST_IDLE;

                    end

                    else begin

                        // Write 1
                        mem_we = 1'b1;
                        mem_wdata = 1;//32'hFFFFFFFF;

                        if (address == LAST_ADDRESS) begin

                            next_state = ST_R1W0_UP;

                            // Start next operation from last address
                            address_load = 1'b1;
                            address_load_value = 0;

                        end

                        else begin

                            address_increment = 1'b1;

                        end

                    end

                end

            end


            //================================================
            // up(r1,w0)
            //================================================

            ST_R1W0_UP: begin

                expected_data = 1;

                if (!read_pending) begin

                    mem_re = 1'b1;

                end

                else begin

                    compare_enable = 1'b1;

                    if (mismatch) begin

                        next_state = ST_IDLE;

                    end

                    else begin

                        // Write 0
                        mem_we = 1'b1;
                        mem_wdata = 0;

                        if (address == LAST_ADDRESS) begin

                            next_state = ST_R0W1_DOWN;

                            // Start downward traversal
                            address_load = 1'b1;
                            address_load_value = LAST_ADDRESS;

                        end

                        else begin

                            address_increment = 1'b1;

                        end

                    end

                end

            end


            //================================================
            // down(r0,w1)
            //================================================

            ST_R0W1_DOWN: begin

                expected_data = 0;

                if (!read_pending) begin

                    mem_re = 1'b1;

                end

                else begin

                    compare_enable = 1'b1;

                    if (mismatch) begin

                        next_state = ST_IDLE;

                    end

                    else begin

                        // Write 1
                        mem_we = 1'b1;
                        mem_wdata = 1;//32'hFFFFFFFF

                        if (address == 0) begin

                            next_state = ST_R1W0_DOWN;

                            // Start next operation from last address
                            address_load = 1'b1;
                            address_load_value = LAST_ADDRESS;

                        end

                        else begin

                            address_decrement = 1'b1;

                        end

                    end

                end

            end


            //================================================
            // down(r1,w0)
            //================================================

            ST_R1W0_DOWN: begin

                expected_data = 1;

                if (!read_pending) begin

                    mem_re = 1'b1;

                end

                else begin

                    compare_enable = 1'b1;

                    if (mismatch) begin

                        next_state = ST_IDLE;

                    end

                    else begin

                        // Write 0
                        mem_we = 1'b1;
                        mem_wdata = 0;

                        if (address == 0) begin

                            next_state = ST_R0_UP;

                            // Start final upward traversal
                            address_load = 1'b1;
                            address_load_value = 0;

                        end

                        else begin

                            address_decrement = 1'b1;

                        end

                    end

                end

            end


            //================================================
            // up(r0)
            //================================================

            ST_R0_UP: begin

                expected_data = 0;

                if (!read_pending) begin

                    mem_re = 1'b1;

                end

                else begin

                    compare_enable = 1'b1;

                    if (mismatch) begin

                        next_state = ST_IDLE;

                    end

                    else if (address == LAST_ADDRESS) begin

                        // Entire March test completed
                        next_state = ST_IDLE;

                    end

                    else begin

                        address_increment = 1'b1;

                    end

                end

            end


            //================================================
            // DEFAULT
            //================================================

            default: begin

                next_state = ST_IDLE;

            end

        endcase

    end


    //========================================================
    // 3. READ PENDING REGISTER
    //========================================================

    always @(posedge clk or posedge reset) begin

        if (reset)

            read_pending <= 1'b0;

        else begin

            case (state)

                ST_R0W1_UP,
                ST_R1W0_UP,
                ST_R0W1_DOWN,
                ST_R1W0_DOWN,
                ST_R0_UP: begin

                    if (!read_pending)
                        read_pending <= 1'b1;

                    else
                        read_pending <= 1'b0;

                end

                default:

                    read_pending <= 1'b0;

            endcase

        end

    end


    //========================================================
    // 4. STATUS REGISTERS
    //========================================================

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            done_flag  <= 1'b0;
            error_flag <= 1'b0;

        end

        else begin

            // New test started
            if (start) begin

                done_flag  <= 1'b0;
                error_flag <= 1'b0;

            end


            // Error detected
            if ((state != ST_IDLE) &&
                read_pending &&
                mismatch) begin

                error_flag <= 1'b1;

            end


            // Final read passed
            if ((state == ST_R0_UP) &&
                read_pending &&
                (address == LAST_ADDRESS) &&
                !mismatch) begin

                done_flag <= 1'b1;

            end

        end

    end


    //========================================================
    // STATUS OUTPUTS
    //========================================================

    assign busy  = (state != ST_IDLE);

    assign done  = done_flag;

    assign error = error_flag;

    assign pass  = done_flag && !error_flag;

endmodule
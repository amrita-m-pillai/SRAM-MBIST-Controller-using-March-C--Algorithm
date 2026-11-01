
`timescale 1ns/1ps

module tb_mbist_test2;

    reg clk;
    reg reset;
    reg start;

    wire busy;
    wire done;
    wire pass;
    wire error;

    wire [5:0] error_address;
    wire [7:0] expected_error_data;
    wire [7:0] actual_error_data;

    reg fault_injected;


    // =========================================================
    // DUT
    // =========================================================

    mbist_top dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .busy(busy),
        .done(done),
        .pass(pass),
        .error(error),
        .error_address(error_address),
        .expected_error_data(expected_error_data),
        .actual_error_data(actual_error_data)
    );


    // =========================================================
    // CLOCK
    // =========================================================

    always #5 clk = ~clk;


    // =========================================================
    // FAULT INJECTION
    // =========================================================

    always @(posedge clk) begin

        /*
         * STATE = 010 = ST_R0W1_UP
         *
         * When MBIST reaches address 10 before
         * performing the read, force the SRAM
         * location to contain 01.
         */

        if (!fault_injected &&
            dut.u_controller.state == 3'b010 &&
            dut.u_address.address == 6'd10 &&
            dut.u_controller.read_pending == 1'b0) begin

            force dut.u_memory.mem[10] = 8'h01;

            fault_injected = 1'b1;

            $display("====================================");
            $display("FAULT INJECTED");
            $display("Address       = 10");
            $display("Forced value  = 01");
            $display("====================================");

        end

    end


    // =========================================================
    // TEST
    // =========================================================

    initial begin

        $dumpfile("mbist_test2.vcd");

    $dumpvars(0, tb_mbist_test2.dut.u_controller);
    $dumpvars(0, tb_mbist_test2.dut.u_address);
    $dumpvars(0, tb_mbist_test2.dut.u_memory);
    $dumpvars(0, tb_mbist_test2.dut.u_comparator);

        clk = 0;
        reset = 1;
        start = 0;
        fault_injected = 0;


        // Reset
        #20;
        reset = 0;


        // Start MBIST
        #20;
        start = 1;

        #10;
        start = 0;


        // Wait for completion
        wait(done || error);

        #20;


        // Display result
        if (error) begin

            $display("====================================");
            $display("TEST 2: FAULT-INJECTED SRAM");
            $display("MBIST FAILED - ERROR DETECTED");
            $display("ERROR ADDRESS = %d", error_address);
            $display("EXPECTED DATA = %h", expected_error_data);
            $display("ACTUAL DATA   = %h", actual_error_data);
            $display("====================================");

        end

        else if (pass) begin

            $display("====================================");
            $display("TEST 2: FAULT-INJECTED SRAM");
            $display("ERROR: MBIST PASSED");
            $display("Fault was NOT detected.");
            $display("====================================");

        end

        else begin

            $display("TEST 2 FAILED - UNKNOWN STATUS");

        end


        // Release the forced value
        release dut.u_memory.mem[10];


        #20;
        $finish;

    end

endmodule


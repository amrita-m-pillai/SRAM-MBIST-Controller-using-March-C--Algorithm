`timescale 1ns/1ps

module tb_mbist;

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

    always #5 clk = ~clk;

    initial begin

       
        
        $dumpfile("mbist.vcd");

        $dumpvars(0, tb_mbist.dut.u_controller);
        $dumpvars(0, tb_mbist.dut.u_address);
        $dumpvars(0, tb_mbist.dut.u_memory);
        $dumpvars(0, tb_mbist.dut.u_comparator);

    

        clk = 0;
        reset = 1;
        start = 0;

        #20;
        reset = 0;

        #20;
        start = 1;

        #10;
        start = 0;

        wait(done || error);

        #20;

       if (pass) begin
    $display("MBIST PASSED");
end
else if (error) begin
    $display("MBIST FAILED - ERROR DETECTED");
    $display("ERROR ADDRESS = %d", error_address);
    $display("EXPECTED DATA = %h", expected_error_data);
    $display("ACTUAL DATA   = %h", actual_error_data);
end
else begin
    $display("MBIST FAILED - DONE/ERROR STATUS UNKNOWN");
end

        $finish;        

    end
    always @(posedge clk) begin
    $display("T=%0t STATE=%b ADDR=%d RP=%b RE=%b WE=%b EXP=%h RDATA=%h CMP=%b MISM=%b",
             $time,
             dut.u_controller.state,
             dut.u_address.address,
             dut.u_controller.read_pending,
             dut.u_controller.mem_re,
             dut.u_controller.mem_we,
             dut.u_controller.expected_data,
             dut.u_memory.read_data,
             dut.u_controller.compare_enable,
             dut.u_controller.mismatch);
end

endmodule
`default_nettype none
`timescale 1ns / 1ps

module tb;

    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uio_in;

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    tt_um_top dut (
        .ui_in(ui_in),
        .uio_in(uio_in),
        .uo_out(uo_out),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        $dumpvars(1, dut);
    end

    initial begin
        clk = 0;
        rst_n = 0;
        ena = 1;
        ui_in = 0;
        uio_in = 0;

        #20 rst_n = 1;

        // CLEAN
        repeat (10) begin
            uio_in = 20;
            ui_in = 1;
            #10;
        end

        // WARNING
        repeat (10) begin
            uio_in = uio_in + 10;
            ui_in = 1;
            #10;
        end

        // UNSAFE
        repeat (10) begin
            uio_in = 200;
            ui_in = 1;
            #10;
        end

        #50;
        $finish;
    end

endmodule

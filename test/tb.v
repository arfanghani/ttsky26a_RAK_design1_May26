`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
`default_nettype none
`timescale 1ns / 1ps

module tb ();

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    $dumpvars(1, user_project);
  end

  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in_reg;
  reg [7:0] uio_in_reg;

  wire [7:0] ui_in;
  wire [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  assign ui_in  = ui_in_reg;
  assign uio_in = uio_in_reg;

  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  tt_um_neurospike user_project (
    .clk(clk),
    .rst_n(rst_n),
    .ena(ena),
    .ui_in(ui_in),
    .uio_in(uio_in),
    .uo_out(uo_out),
    .uio_out(uio_out),
    .uio_oe(uio_oe)
  );

  initial begin
    rst_n = 0;
    ena = 1;
    ui_in_reg = 0;
    uio_in_reg = 0;

    #25;
    rst_n = 1;

    // Stimulus pulses
    repeat (10) begin
      ui_in_reg = 8'b00000001;
      #20;
      ui_in_reg = 8'b00000000;
      #40;
    end

    // Adjust threshold
    ui_in_reg = 8'b00000010; #20;
    ui_in_reg = 8'b00000000;

    #200;
    $finish;
  end

  initial begin
    $monitor("Time=%0t | ui_in=%b | spike=%b | membrane=%d | threshold=%d",
      $time, ui_in, uo_out[0], uo_out[7:1], uio_out);
  end

endmodule

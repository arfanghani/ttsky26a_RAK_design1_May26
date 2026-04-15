/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`timescale 1ns / 1ps

module tt_um_neurospike (
    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    reg [7:0] membrane = 0;
    reg [7:0] threshold = 8'd20;

    // -----------------------------
    // INPUT SIGNALS
    // -----------------------------
    wire stimulus  = ui_in[0];
    wire inc_th    = ui_in[1];
    wire dec_th    = ui_in[2];
    wire reset_nrn = ui_in[3];

    // -----------------------------
    // EXPLICIT SPIKE SIGNAL
    // -----------------------------
    wire spike;

    assign spike = (membrane >= threshold);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || reset_nrn) begin
            membrane <= 0;
            threshold <= 8'd20;
            uo_out <= 0;
        end else if (ena) begin

            // Threshold control
            if (inc_th) threshold <= threshold + 1;
            if (dec_th) threshold <= threshold - 1;

            // Leak (decay)
            if (membrane > 0)
                membrane <= membrane - 1;

            // Input stimulus
            if (stimulus)
                membrane <= membrane + 3;

            // Spike event (clean logic)
            if (spike) begin
                uo_out[0] <= 1;
                membrane <= 0;
            end else begin
                uo_out[0] <= 0;
            end

            // Output membrane (upper bits)
            uo_out[7:1] <= membrane[6:0];
        end
    end

    // Threshold output for debug
    assign uio_out = threshold;
    assign uio_oe  = 8'hFF;

endmodule

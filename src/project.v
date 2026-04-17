`default_nettype none

module tt_um_arfanghani_design1_top (
    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // -------------------------
    // INPUTS
    // -------------------------
    wire sample_en = ui_in[0];
    wire [7:0] sensor = uio_in;

    // -------------------------
    // FEATURE ENGINE
    // -------------------------
    reg [7:0] prev;
    reg [7:0] peak;
    reg [7:0] avg;

    wire [7:0] diff = (sensor > prev) ? (sensor - prev) : (prev - sensor);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev <= 0;
            peak <= 0;
            avg  <= 0;
        end
        else if (ena && sample_en) begin
            prev <= sensor;

            avg <= (avg + sensor) >> 1;

            if (sensor > peak)
                peak <= sensor;
        end
    end

    // -------------------------
    // CLASSIFIER ENGINE
    // -------------------------
    reg [1:0] state;

    always @(*) begin
        if (!rst_n)
            state = 2'b00;
        else if (peak < 40 && diff < 10)
            state = 2'b00;   // CLEAN
        else if (peak < 120)
            state = 2'b01;   // WARNING
        else
            state = 2'b10;   // UNSAFE
    end

    // -------------------------
    // DEBUG ENCODING (SYNTHESIZABLE)
    // -------------------------
    reg [1:0] state_dbg;

    always @(*) begin
        state_dbg = state;
    end

    // -------------------------
    // OUTPUT
    // -------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uo_out <= 0;
        end else begin
            uo_out[1:0] <= state;      // real output
            uo_out[3:2] <= state_dbg;  // debug mirror
            uo_out[7:4] <= avg[3:0];   // optional activity monitor
        end
    end

    assign uio_out = peak;
    assign uio_oe  = 8'b0;

endmodule

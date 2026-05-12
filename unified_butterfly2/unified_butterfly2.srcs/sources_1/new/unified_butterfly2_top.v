`timescale 1ns / 1ps

// Additively masked wrapper around two butterfly cores.
//
// Inputs are split modulo q:
//   a = a0 + a1 mod q
//   b = b0 + b1 mod q
//
// The butterfly equations are linear in a and b once zeta is public:
//   CT: out1 = a + b*zeta,    out2 = a - b*zeta
//   GS: out1 = a + b,         out2 = (a-b)*zeta
//
// Each share passes through an independent identical core using the same public
// ROM zeta. The wrapper intentionally never recombines shares inside RTL.
module masked_unified_butterfly2_top(
    input   clk,
    input  [31:0] a0, a1,
    input  [31:0] b0, b1,
    input  mode, mode2,
    input  [9:0]  k,
    output [31:0] out1_0,
    output [31:0] out1_1,
    output [31:0] out2_0,
    output [31:0] out2_1
);

    wire [31:0] mode_q;
    assign mode_q = (mode2 == 1'b0) ? 32'd3329 : 32'd8380417;

    localparam [9:0] KYBER_INV_ZETA_START = 10'd0;
    localparam [9:0] KYBER_ZETA_START     = 10'd256;
    localparam [9:0] DIL_INV_ZETA_START   = 10'd512;
    localparam [9:0] DIL_ZETA_START       = 10'd768;

    wire [9:0] base_addr;
    wire [9:0] rom_addr;

    assign base_addr = (mode2 == 1'b0) ?
                       (mode ? KYBER_ZETA_START : KYBER_INV_ZETA_START) :
                       (mode ? DIL_ZETA_START : DIL_INV_ZETA_START);
    assign rom_addr = base_addr + k;

    wire [31:0] ref_zeta;

    blk_mem_gen_0 ZETA_ROM (
        .clka  (clk),
        .addra (rom_addr),
        .douta (ref_zeta)
    );

    reg [31:0] a0_r;
    reg [31:0] a1_r;
    reg [31:0] b0_r;
    reg [31:0] b1_r;
    reg [31:0] q_r;
    reg        mode_r;

    always @(posedge clk) begin
        a0_r   <= a0;
        a1_r   <= a1;
        b0_r   <= b0;
        b1_r   <= b1;
        q_r    <= mode_q;
        mode_r <= mode;
    end

    unified_butterfly2_core core_share0 (
        .clk      (clk),
        .a        (a0_r),
        .b        (b0_r),
        .ref_zeta (ref_zeta),
        .q        (q_r),
        .mode     (mode_r),
        .out1     (out1_0),
        .out2     (out2_0)
    );

    unified_butterfly2_core core_share1 (
        .clk      (clk),
        .a        (a1_r),
        .b        (b1_r),
        .ref_zeta (ref_zeta),
        .q        (q_r),
        .mode     (mode_r),
        .out1     (out1_1),
        .out2     (out2_1)
    );

endmodule

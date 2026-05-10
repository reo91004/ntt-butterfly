`timescale 1ns / 1ps

// Pipelined unified butterfly2 core.
//
// Equivalence with the original combinational core (preserved):
//   CT (mode=1):  out1 = (a + b * zeta) mod q,    out2 = (a - b * zeta) mod q
//   GS (mode=0):  out1 = (a + b)        mod q,    out2 = ((a - b) * zeta) mod q
//
// Pipeline structure (registers introduced; everything else is combinational):
//   S1   : pre-mul mux + (a-b)mod q   (1 cycle register)
//   S2   : 32x32 multiplier            (1 cycle register)
//   S3..S6 : Modular_Reduction32      (4 cycles internal pipeline, Montgomery)
//   S7   : final add/sub + mod-correct (1 cycle register)
// Total latency: 7 cycles. Throughput: 1 result per cycle.
//
// Reduction is Montgomery (R = 2^32), so t_after_mr = (m1*ref_zeta) * R^-1 mod q.
// The final add/sub stage stays unchanged — it operates in whatever domain the
// inputs (a, b) and ref_zeta live in. The surrounding NTT pipeline is assumed
// to be in the Montgomery domain (operands scaled by R), so the per-butterfly
// R^-1 from the reducer cancels the R already present on the b operand.
//
// The mux2_1 / demux1_2 sub-modules from the previous version are inlined
// here so register insertion stays clean. They remain available in the
// project for any other instantiations and are otherwise unused.

module unified_butterfly2_core(
    input              clk,
    input  [31:0]      a, b, ref_zeta, q,
    input              mode,                  // 0: GS, 1: CT
    output reg [31:0]  out1,
    output reg [31:0]  out2
);

    // ---------- Stage 0 (combinational pre-mul) ----------
    // GS path needs (a-b) mod q at the mul input; CT path uses b directly.
    wire [31:0] sub_ab_s0 = (a >= b) ? (a - b) : (a + q - b);
    wire [31:0] m1_in_s0  = mode ? b : sub_ab_s0;

    // ---------- Stage 1 register ----------
    reg [31:0] m1_s1, ref_zeta_s1;
    reg [31:0] a_s1, b_s1, q_s1;
    reg        mode_s1;
    always @(posedge clk) begin
        m1_s1       <= m1_in_s0;
        ref_zeta_s1 <= ref_zeta;
        a_s1        <= a;
        b_s1        <= b;
        q_s1        <= q;
        mode_s1     <= mode;
    end

    // ---------- Stage 2 register: 32x32 multiplier ----------
    reg [63:0] mul_s2;
    reg [31:0] a_s2, b_s2, q_s2;
    reg        mode_s2;
    always @(posedge clk) begin
        mul_s2  <= m1_s1 * ref_zeta_s1;
        a_s2    <= a_s1;
        b_s2    <= b_s1;
        q_s2    <= q_s1;
        mode_s2 <= mode_s1;
    end

    // ---------- Stages 3..6: Modular_Reduction32 (4-cycle Montgomery pipeline) ----------
    wire [31:0] t_after_mr;
    Modular_Reduction32 MR1 (
        .clk (clk),
        .a   (mul_s2),
        .q   (q_s2),
        .r   (t_after_mr)
    );

    // Delay-match a, b, q, mode through MR's latency.
    localparam MR_LATENCY = 4;
    reg [31:0] a_pipe   [0:MR_LATENCY-1];
    reg [31:0] b_pipe   [0:MR_LATENCY-1];
    reg [31:0] q_pipe   [0:MR_LATENCY-1];
    reg        mode_pipe[0:MR_LATENCY-1];

    integer k;
    always @(posedge clk) begin
        a_pipe[0]    <= a_s2;
        b_pipe[0]    <= b_s2;
        q_pipe[0]    <= q_s2;
        mode_pipe[0] <= mode_s2;
        for (k = 1; k < MR_LATENCY; k = k + 1) begin
            a_pipe[k]    <= a_pipe[k-1];
            b_pipe[k]    <= b_pipe[k-1];
            q_pipe[k]    <= q_pipe[k-1];
            mode_pipe[k] <= mode_pipe[k-1];
        end
    end

    wire [31:0] t_aligned    = t_after_mr;
    wire [31:0] a_aligned    = a_pipe[MR_LATENCY-1];
    wire [31:0] b_aligned    = b_pipe[MR_LATENCY-1];
    wire [31:0] q_aligned    = q_pipe[MR_LATENCY-1];
    wire        mode_aligned = mode_pipe[MR_LATENCY-1];

    // ---------- Stage 35 (final add/sub + output register) ----------
    // m3 mux: CT -> t, GS -> b
    wire [31:0] m3_align = mode_aligned ? t_aligned : b_aligned;

    // out1 = (a + m3) mod q  (33-bit wide intermediate to avoid overflow)
    wire [32:0] out1_wide = {1'b0, a_aligned} + {1'b0, m3_align};
    wire [32:0] q_wide    = {1'b0, q_aligned};
    wire [31:0] out1_pre  = (out1_wide >= q_wide) ? (out1_wide - q_wide) : out1_wide[31:0];

    // sub: (a - m2) mod q where m2 = (mode ? t : b)
    wire [31:0] m2_align    = mode_aligned ? t_aligned : b_aligned;
    wire [31:0] sub_aligned = (a_aligned >= m2_align) ? (a_aligned - m2_align)
                                                      : (a_aligned + q_aligned - m2_align);

    // m4 mux: CT -> sub  (= (a-t) mod q),  GS -> t (= dm_out1 in original)
    wire [31:0] out2_pre = mode_aligned ? sub_aligned : t_aligned;

    always @(posedge clk) begin
        out1 <= out1_pre;
        out2 <= out2_pre;
    end

endmodule

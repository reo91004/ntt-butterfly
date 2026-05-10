`timescale 1ns / 1ps

// Pipelined Montgomery reduction (R = 2^32):
//   r = a * R^(-1) mod q
//
// Algorithm:
//   m   = (a[31:0] * QPRIME) mod 2^32      // QPRIME = -q^(-1) mod 2^32
//   t   = (a + m*q) >> 32                   // < 2q  (low 32 bits of a + m*q are 0)
//   r   = (t >= q) ? (t - q) : t            // < q
//
// Latency: 4 cycles. Throughput: 1 result/cycle.
// Each stage is one 32x32 multiply OR one 64-bit add OR one compare/subtract,
// all comfortably within a 10 ns (100 MHz) period on Artix-7.
//
// QPRIME is derived combinationally from the input q so the module signature
// stays compatible with the previous classical-division reducer:
//   q = 3329    (Kyber)     -> QPRIME = 32'h94570CFF
//   q = 8380417 (Dilithium) -> QPRIME = 32'hFC7FDFFF
//
// NOTE on semantics: the result is in the Montgomery domain (scaled by R^-1).
// The surrounding NTT/butterfly is expected to operate in this domain; final
// conversion (multiply by R^2 mod q, then one Montgomery reduction) happens
// outside this module.

module Modular_Reduction32 (
    input              clk,
    input  [63:0]      a,
    input  [31:0]      q,
    output [31:0]      r
);

    // -q^(-1) mod 2^32, selected from q. Two supported moduli.
    wire [31:0] qprime = (q == 32'd3329) ? 32'h94570CFF   // Kyber
                                         : 32'hFC7FDFFF;  // Dilithium (default)

    // ---------- Stage 1: m = (a_low * qprime) mod 2^32 ----------
    reg  [63:0] T_s1;
    reg  [31:0] q_s1;
    reg  [31:0] m_s1;
    wire [63:0] m_full = a[31:0] * qprime;   // only low 32 bits matter
    always @(posedge clk) begin
        T_s1 <= a;
        q_s1 <= q;
        m_s1 <= m_full[31:0];
    end

    // ---------- Stage 2: m * q (full 64 bit) ----------
    reg  [63:0] T_s2;
    reg  [31:0] q_s2;
    reg  [63:0] mq_s2;
    always @(posedge clk) begin
        T_s2  <= T_s1;
        q_s2  <= q_s1;
        mq_s2 <= m_s1 * q_s1;
    end

    // ---------- Stage 3: 65-bit add, take upper 32 bits ----------
    reg  [31:0] t_s3;
    reg  [31:0] q_s3;
    wire [64:0] sum = {1'b0, T_s2} + {1'b0, mq_s2};
    always @(posedge clk) begin
        t_s3 <= sum[63:32];   // 0 <= t_s3 < 2q
        q_s3 <= q_s2;
    end

    // ---------- Stage 4: final correction ----------
    reg  [31:0] r_s4;
    always @(posedge clk) begin
        r_s4 <= (t_s3 >= q_s3) ? (t_s3 - q_s3) : t_s3;
    end

    assign r = r_s4;

endmodule

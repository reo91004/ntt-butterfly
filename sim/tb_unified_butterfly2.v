`timescale 1ns / 1ps

// Updated for Montgomery-reduction core (R = 2^32):
//   t_after_mr = (m1 * ref_zeta) * R^-1 mod q
// Zetas in the ROM are still in regular form, so the multiplier output is
// scaled by R^-1 after reduction. Final-stage add/sub paths inherit that
// scaling on the t-bearing outputs (out2 in CT, out2 in GS); the (a+b)
// path used by GS out1 is unaffected.
//
// Pipeline latency is 7 cycles (was 67 with the long-division reducer):
//   1 (S1) + 1 (S2 mult) + 4 (Montgomery) + 1 (S7 final) = 7

module tb_unified_butterfly2_top;

    reg clk;

    reg  [31:0] a;
    reg  [31:0] b;
    reg  mode;  // 0: GS 1: CT
    reg  mode2; // 0: Kyber 1: Dil
    reg  [9:0]  k;

    wire [31:0] out1_0;
    wire [31:0] out1_1;
    wire [31:0] out2_0;
    wire [31:0] out2_1;
    wire [31:0] out1 = out1_0 + out1_1;
    wire [31:0] out2 = out2_0 + out2_1;

    integer err;

    // top latches a/b/mode/q one cycle after k (for ROM lookup), so total
    // observable latency from input change to stable output is 1 (top reg)
    // + 1 (rom) + 7 (core) = 9 cycles. Wait a couple extra to be safe.
    localparam OBS_LATENCY = 11;

    masked_unified_butterfly2_top DUT (
        .clk    (clk),
        .a0     (a),
        .a1     (32'd0),
        .b0     (b),
        .b1     (32'd0),
        .mode   (mode),
        .mode2  (mode2),
        .k      (k),
        .out1_0 (out1_0),
        .out1_1 (out1_1),
        .out2_0 (out2_0),
        .out2_1 (out2_1)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task check_result;
        input [8*20-1:0] name;
        input [31:0] exp_out1;
        input [31:0] exp_out2;
        begin
            repeat (OBS_LATENCY) @(posedge clk);
            #1;

            if ((out1 !== exp_out1) || (out2 !== exp_out2)) begin
                $display("[FAIL] %0s | out1=%0d expected=%0d, out2=%0d expected=%0d",
                         name, out1, exp_out1, out2, exp_out2);
                err = err + 1;
            end
            else begin
                $display("[PASS] %0s | out1=%0d, out2=%0d",
                         name, out1, out2);
            end
        end
    endtask

    initial begin
        err = 0;

        a     = 32'd0;
        b     = 32'd0;
        mode  = 1'b0;
        mode2 = 1'b0;
        k     = 10'd0;

        repeat (3) @(posedge clk);

        // ============================================================
        // 1. Kyber CT     (mode2=0 Kyber, mode=1 CT, k=16)
        //    ROM addr = 256 + 16 = 272, ref_zeta = Kyber zeta[16] = 296
        //    q = 3329, R = 2^32
        //    a = 3100, b = 2800
        //    T    = 2800 * 296 = 828800
        //    t    = MontReduce(T) = T * R^-1 mod q = 2950
        //    out1 = (3100 + 2950) mod 3329 = 2721
        //    out2 = (3100 - 2950) mod 3329 = 150
        // ============================================================
        a     = 32'd3100;
        b     = 32'd2800;
        mode2 = 1'b0;
        mode  = 1'b1;
        k     = 10'd16;
        check_result("Kyber CT", 32'd2721, 32'd150);

        // ============================================================
        // 2. Kyber GS     (mode2=0 Kyber, mode=0 GS, k=16)
        //    ROM addr = 0 + 16 = 16, ref_zeta = Kyber inv_zeta[16] = 2508
        //    q = 3329
        //    a = 3100, b = 2800, diff = 300
        //    out1 = (3100 + 2800) mod 3329 = 2571            (a+b path, unscaled)
        //    T    = 300 * 2508 = 752400
        //    out2 = MontReduce(T) = 2180                     (R^-1 scaled)
        // ============================================================
        a     = 32'd3100;
        b     = 32'd2800;
        mode2 = 1'b0;
        mode  = 1'b0;
        k     = 10'd16;
        check_result("Kyber GS", 32'd2571, 32'd2180);

        // ============================================================
        // 3. Dilithium CT (mode2=1 Dil, mode=1 CT, k=1)
        //    ROM addr = 768 + 1 = 769, ref_zeta = Dil zeta[1] = 0x495e02 = 4808194
        //    q = 8380417
        //    a = 7000000, b = 6000000
        //    T    = 6000000 * 4808194 = 28849164000000
        //    t    = MontReduce(T) = 152481
        //    out1 = (7000000 + 152481) mod q = 7152481
        //    out2 = (7000000 - 152481) mod q = 6847519
        // ============================================================
        a     = 32'd7000000;
        b     = 32'd6000000;
        mode2 = 1'b1;
        mode  = 1'b1;
        k     = 10'd1;
        check_result("Dil CT", 32'd7152481, 32'd6847519);

        // ============================================================
        // 4. Dilithium GS (mode2=1 Dil, mode=0 GS, k=1)
        //    ROM addr = 512 + 1 = 513, ref_zeta = Dil inv_zeta[1] = 0x3681ff = 3572223
        //    q = 8380417
        //    a = 7000000, b = 6000000, diff = 1000000
        //    out1 = (7000000 + 6000000) mod q = 4619583     (a+b path, unscaled)
        //    T    = 1000000 * 3572223 = 3572223000000
        //    out2 = MontReduce(T) = 4164795                  (R^-1 scaled)
        // ============================================================
        a     = 32'd7000000;
        b     = 32'd6000000;
        mode2 = 1'b1;
        mode  = 1'b0;
        k     = 10'd1;
        check_result("Dil GS", 32'd4619583, 32'd4164795);

        if (err == 0) begin
            $display("======================================");
            $display("All 4 tests PASSED");
            $display("======================================");
        end
        else begin
            $display("======================================");
            $display("Tests FAILED, err = %0d", err);
            $display("======================================");
        end

        $finish;
    end

endmodule

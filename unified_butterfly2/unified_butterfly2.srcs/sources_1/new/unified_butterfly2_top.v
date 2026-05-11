`timescale 1ns / 1ps 

module unified_butterfly2_top(
    input   clk,
    input  [31:0] a,b,
    input  mode, mode2, // mode: gs=0 ct:1 // mode2  0: Kyber, 1: Dil
    input  [9:0]  k,   // zeta table[k] index 
    output [31:0] out1,
    output [31:0] out2
);

 
    wire [31:0] mode_q;
    assign mode_q = (mode2 == 1'b0) ? 32'd3329 : 32'd8380417;
    
    // ROM 
    // 0   ~ 127   : Kyber inv_z0eta
    // 256 ~ 383   : Kyber zeta
    // 512 ~ 767   : Dilithium inv_zeta
    // 768 ~ 1023  : Dilithium zeta
    localparam [9:0] Kyber_inv_zeta_start = 10'd0;
    localparam [9:0] Kyber_zeta_start = 10'd256;
    localparam [9:0] DIL_inv_zeta_start = 10'd512;
    localparam [9:0] DIL_zeta_start = 10'd768;

    wire [9:0] base_addr; // 2^10 1024이므로 bit-width는 10 시작 주소 
    wire [9:0] rom_addr;

    assign base_addr =(mode2 == 1'b0) ?(mode ? Kyber_zeta_start : Kyber_inv_zeta_start):(mode ? DIL_zeta_start : DIL_inv_zeta_start);
    assign rom_addr = base_addr + k; 
    

    //ref_zeta는 input이 아니라 내부 wire(core에서 input 선언)
    wire [31:0] ref_zeta;
  
    blk_mem_gen_0 ZETA_ROM ( //width 32, depth 1024(kyper+dil) 
        .clka  (clk),
        //.ena   (1'b1),
        .addra (rom_addr),
        .douta (ref_zeta)
    );

    // ROM 출력이 1cycle delay a,b,mode,q도 1cycle delay
    reg [31:0] a_r;
    reg [31:0] b_r;
    reg [31:0] q_r;
    reg  mode_r;

    always @(posedge clk) begin
        a_r    <= a;
        b_r    <= b;
        q_r    <= mode_q;
        mode_r <= mode;
    end

    unified_butterfly2_core core (
        .clk      (clk),
        .a        (a_r),
        .b        (b_r),
        .ref_zeta (ref_zeta),
        .q        (q_r),
        .mode     (mode_r),
        .out1     (out1),
        .out2     (out2)
    );



endmodule


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
// Therefore each share can pass through an independent identical core using the
// same public ROM zeta. The logical output is recovered off-core as:
//   out1 = out1_0 + out1_1 mod q
//   out2 = out2_0 + out2_1 mod q
//
// The module intentionally does not recombine shares. The CW305 wrapper stores
// and reads the output shares separately so the capture window never contains
// the unmasked butterfly result.
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

    localparam [9:0] Kyber_inv_zeta_start = 10'd0;
    localparam [9:0] Kyber_zeta_start = 10'd256;
    localparam [9:0] DIL_inv_zeta_start = 10'd512;
    localparam [9:0] DIL_zeta_start = 10'd768;

    wire [9:0] base_addr;
    wire [9:0] rom_addr;

    assign base_addr = (mode2 == 1'b0) ?
                       (mode ? Kyber_zeta_start : Kyber_inv_zeta_start) :
                       (mode ? DIL_zeta_start : DIL_inv_zeta_start);
    assign rom_addr = base_addr + k;

    wire [31:0] ref_zeta;

    blk_mem_gen_0 ZETA_ROM_MASKED (
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

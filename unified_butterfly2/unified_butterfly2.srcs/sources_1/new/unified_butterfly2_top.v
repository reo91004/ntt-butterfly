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
`default_nettype none
`timescale 1ns / 1ps

/*
 * CW305 USB-register wrapper for unified_butterfly2_top
 * Version 4: read path uses official cw305_usb_reg_fe; write path uses direct
 * sampled USB_nWE/USB_nCS decode because some bring-up cases showed reg_write
 * not toggling while reads were OK.
 *
 * Python / ChipWhisperer register map:
 *   0x00 : A[31:0]     write/read 4 bytes, little-endian
 *   0x01 : B[31:0]     write/read 4 bytes, little-endian
 *   0x02 : K[9:0]      write/read 2 bytes, little-endian
 *   0x03 : CTRL        write/read 1 byte, bit0=mode, bit1=mode2
 *   0x04 : CMD/STATUS  write bit0=start, bit1=clear_done
 *                       read bit0=done, bit1=busy
 *   0x05 : OUT1[31:0]  read 4 bytes, little-endian
 *   0x06 : OUT2[31:0]  read 4 bytes, little-endian
 *   0x70 : debug direct_write_count
 *   0x71 : debug last_write_addr
 *   0x72 : debug last_write_bytecnt
 *   0x73 : debug last_write_data
 *   0x74 : debug raw USB pins while reading: {5'b0, usb_cen, usb_wrn, usb_rdn}
 *   0x75 : debug official_fe_write_count
 *   0x7E : ID = 0xC4
 */
module cw305_unified_butterfly2_top_v4 #(
    parameter pBYTECNT_SIZE = 7,
    parameter pADDR_WIDTH   = 21,
    parameter pUSE_INTERNAL_TRIGGER = 1
)(
    input  wire                         usb_clk,
    inout  wire [7:0]                   usb_data,
    input  wire [pADDR_WIDTH-1:0]       usb_addr,
    input  wire                         usb_rdn,
    input  wire                         usb_wrn,
    input  wire                         usb_cen,
    input  wire                         usb_trigger,

    input  wire                         j16_sel,
    input  wire                         k16_sel,
    input  wire                         k15_sel,
    input  wire                         l14_sel,
    input  wire                         pushbutton,
    output wire                         led1,
    output wire                         led2,
    output wire                         led3,

    input  wire                         pll_clk1,
    output wire                         tio_trigger,
    output wire                         tio_clkout,
    input  wire                         tio_clkin
);

    wire usb_clk_buf;
    wire [7:0] usb_din;
    wire [7:0] usb_dout;
    wire       isout;

    wire [pADDR_WIDTH-pBYTECNT_SIZE-1:0] reg_address;
    wire [pBYTECNT_SIZE-1:0]             reg_bytecnt;
    wire                                 reg_addrvalid;
    wire [7:0]                           fe_write_data;
    wire [7:0]                           read_data;
    wire                                 reg_read;
    wire                                 fe_reg_write;

    assign usb_data = isout ? usb_dout : 8'bZ;
    assign usb_din  = usb_data;

    BUFG U_usb_clk_buf (
        .I(usb_clk),
        .O(usb_clk_buf)
    );

    cw305_usb_reg_fe #(
        .pADDR_WIDTH    (pADDR_WIDTH),
        .pBYTECNT_SIZE  (pBYTECNT_SIZE),
        .pREG_RDDLY_LEN (3)
    ) U_usb_reg_fe (
        .usb_clk       (usb_clk_buf),
        .rst           (1'b0),
        .usb_din       (usb_din),
        .usb_dout      (usb_dout),
        .usb_isout     (isout),
        .usb_addr      (usb_addr),
        .usb_rdn       (usb_rdn),
        .usb_wrn       (usb_wrn),
        .usb_alen      (1'b0),
        .usb_cen       (usb_cen),
        .reg_address   (reg_address),
        .reg_bytecnt   (reg_bytecnt),
        .reg_datao     (fe_write_data),
        .reg_datai     (read_data),
        .reg_read      (reg_read),
        .reg_write     (fe_reg_write),
        .reg_addrvalid (reg_addrvalid)
    );

    // Direct write detector. This creates one internal pulse per USB write strobe.
    wire direct_wr_active = (~usb_cen) & (~usb_wrn);
    reg  direct_wr_active_d = 1'b0;
    wire direct_wr_pulse = direct_wr_active & ~direct_wr_active_d;

    wire [pADDR_WIDTH-pBYTECNT_SIZE-1:0] direct_wr_addr = usb_addr[pADDR_WIDTH-1:pBYTECNT_SIZE];
    wire [pBYTECNT_SIZE-1:0]             direct_wr_byte = usb_addr[pBYTECNT_SIZE-1:0];
    wire [7:0]                           direct_wr_data = usb_din;

    reg [31:0] a_shadow     = 32'd0;
    reg [31:0] b_shadow     = 32'd0;
    reg [9:0]  k_shadow     = 10'd0;
    reg        mode_shadow  = 1'b1;
    reg        mode2_shadow = 1'b0;

    reg [31:0] a_core       = 32'd0;
    reg [31:0] b_core       = 32'd0;
    reg [9:0]  k_core       = 10'd0;
    reg        mode_core    = 1'b1;
    reg        mode2_core   = 1'b0;

    reg [31:0] out1_reg     = 32'd0;
    reg [31:0] out2_reg     = 32'd0;
    reg        busy_reg     = 1'b0;
    reg        done_reg     = 1'b0;
    reg [7:0]  wait_count   = 8'd0;
    // The butterfly core itself is 7 cycles. From the wrapper start write,
    // out1_wire/out2_wire are valid after about 8 usb_clk cycles because the
    // top-level ROM/input register adds one alignment cycle.
    //
    // Keep busy/tio_trigger high longer than the arithmetic latency so captures
    // include a stable post-result window. CAPTURE_DELAY is therefore a trigger
    // hold/readback-latch delay, not the butterfly latency.
    localparam [7:0] CORE_RESULT_VALID_DELAY = 8'd8;
    localparam [7:0] POST_RESULT_TRIGGER_HOLD = 8'd64;
    localparam [7:0] CAPTURE_DELAY =
        CORE_RESULT_VALID_DELAY + POST_RESULT_TRIGGER_HOLD;

    reg [7:0] direct_write_count = 8'd0;
    reg [7:0] fe_write_count     = 8'd0;
    reg [7:0] last_write_addr    = 8'd0;
    reg [6:0] last_write_byte    = 7'd0;
    reg [7:0] last_write_data    = 8'd0;

    wire [31:0] out1_wire;
    wire [31:0] out2_wire;

    unified_butterfly2_top U_butterfly (
        .clk   (usb_clk_buf),
        .a     (a_core),
        .b     (b_core),
        .mode  (mode_core),
        .mode2 (mode2_core),
        .k     (k_core),
        .out1  (out1_wire),
        .out2  (out2_wire)
    );

    always @(posedge usb_clk_buf) begin
        direct_wr_active_d <= direct_wr_active;

        if (fe_reg_write)
            fe_write_count <= fe_write_count + 8'd1;

        if (busy_reg) begin
            wait_count <= wait_count + 8'd1;
            if (wait_count == CAPTURE_DELAY) begin
                out1_reg   <= out1_wire;
                out2_reg   <= out2_wire;
                busy_reg   <= 1'b0;
                done_reg   <= 1'b1;
                wait_count <= 8'd0;
            end
        end

        if (direct_wr_pulse) begin
            direct_write_count <= direct_write_count + 8'd1;
            last_write_addr    <= direct_wr_addr[7:0];
            last_write_byte    <= direct_wr_byte;
            last_write_data    <= direct_wr_data;

            case (direct_wr_addr[7:0])
                8'h00: begin
                    case (direct_wr_byte[1:0])
                        2'd0: a_shadow[7:0]   <= direct_wr_data;
                        2'd1: a_shadow[15:8]  <= direct_wr_data;
                        2'd2: a_shadow[23:16] <= direct_wr_data;
                        2'd3: a_shadow[31:24] <= direct_wr_data;
                    endcase
                end

                8'h01: begin
                    case (direct_wr_byte[1:0])
                        2'd0: b_shadow[7:0]   <= direct_wr_data;
                        2'd1: b_shadow[15:8]  <= direct_wr_data;
                        2'd2: b_shadow[23:16] <= direct_wr_data;
                        2'd3: b_shadow[31:24] <= direct_wr_data;
                    endcase
                end

                8'h02: begin
                    case (direct_wr_byte[0])
                        1'b0: k_shadow[7:0] <= direct_wr_data;
                        1'b1: k_shadow[9:8] <= direct_wr_data[1:0];
                    endcase
                end

                8'h03: begin
                    if (direct_wr_byte == 7'd0) begin
                        mode_shadow  <= direct_wr_data[0];
                        mode2_shadow <= direct_wr_data[1];
                    end
                end

                8'h04: begin
                    if (direct_wr_byte == 7'd0) begin
                        if (direct_wr_data[1])
                            done_reg <= 1'b0;
                        if (direct_wr_data[0] && !busy_reg) begin
                            a_core     <= a_shadow;
                            b_core     <= b_shadow;
                            k_core     <= k_shadow;
                            mode_core  <= mode_shadow;
                            mode2_core <= mode2_shadow;
                            busy_reg   <= 1'b1;
                            done_reg   <= 1'b0;
                            wait_count <= 8'd0;
                        end
                    end
                end
            endcase
        end
    end

    assign read_data =
        (reg_address[7:0] == 8'h00) ? ((reg_bytecnt[1:0] == 2'd0) ? a_shadow[7:0]   :
                                       (reg_bytecnt[1:0] == 2'd1) ? a_shadow[15:8]  :
                                       (reg_bytecnt[1:0] == 2'd2) ? a_shadow[23:16] :
                                                                    a_shadow[31:24]) :
        (reg_address[7:0] == 8'h01) ? ((reg_bytecnt[1:0] == 2'd0) ? b_shadow[7:0]   :
                                       (reg_bytecnt[1:0] == 2'd1) ? b_shadow[15:8]  :
                                       (reg_bytecnt[1:0] == 2'd2) ? b_shadow[23:16] :
                                                                    b_shadow[31:24]) :
        (reg_address[7:0] == 8'h02) ? ((reg_bytecnt[0] == 1'b0) ? k_shadow[7:0] : {6'b0, k_shadow[9:8]}) :
        (reg_address[7:0] == 8'h03) ? {6'b0, mode2_shadow, mode_shadow} :
        (reg_address[7:0] == 8'h04) ? {6'b0, busy_reg, done_reg} :
        (reg_address[7:0] == 8'h05) ? ((reg_bytecnt[1:0] == 2'd0) ? out1_reg[7:0]   :
                                       (reg_bytecnt[1:0] == 2'd1) ? out1_reg[15:8]  :
                                       (reg_bytecnt[1:0] == 2'd2) ? out1_reg[23:16] :
                                                                    out1_reg[31:24]) :
        (reg_address[7:0] == 8'h06) ? ((reg_bytecnt[1:0] == 2'd0) ? out2_reg[7:0]   :
                                       (reg_bytecnt[1:0] == 2'd1) ? out2_reg[15:8]  :
                                       (reg_bytecnt[1:0] == 2'd2) ? out2_reg[23:16] :
                                                                    out2_reg[31:24]) :
        (reg_address[7:0] == 8'h70) ? direct_write_count :
        (reg_address[7:0] == 8'h71) ? last_write_addr :
        (reg_address[7:0] == 8'h72) ? {1'b0, last_write_byte} :
        (reg_address[7:0] == 8'h73) ? last_write_data :
        (reg_address[7:0] == 8'h74) ? {5'b0, usb_cen, usb_wrn, usb_rdn} :
        (reg_address[7:0] == 8'h75) ? fe_write_count :
        (reg_address[7:0] == 8'h7E) ? 8'hC4 :
                                      8'h00;

    assign led1 = done_reg;
    assign led2 = busy_reg;
    assign led3 = (direct_write_count != 8'd0);

    // Default SCA build: trigger is asserted while a butterfly evaluation is
    // in flight. Set pUSE_INTERNAL_TRIGGER=0 only for legacy host-toggle tests.
    assign tio_trigger = pUSE_INTERNAL_TRIGGER ? busy_reg : usb_trigger;
    assign tio_clkout  = usb_clk_buf;

endmodule

`default_nettype wire

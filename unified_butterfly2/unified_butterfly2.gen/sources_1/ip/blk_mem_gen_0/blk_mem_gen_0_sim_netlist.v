// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (lin64) Build 5239630 Fri Nov 08 22:34:34 MST 2024
// Date        : Fri May  8 16:34:02 2026
// Host        : pacl-System-Product-Name running 64-bit Ubuntu 24.04.4 LTS
// Command     : write_verilog -force -mode funcsim -rename_top blk_mem_gen_0 -prefix
//               blk_mem_gen_0_ blk_mem_gen_0_sim_netlist.v
// Design      : blk_mem_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tftg256-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_0,blk_mem_gen_v8_4_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_9,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module blk_mem_gen_0
   (clka,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [9:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;

  wire [9:0]addra;
  wire clka;
  wire [31:0]douta;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [31:0]NLW_U0_doutb_UNCONNECTED;
  wire [9:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [9:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "10" *) 
  (* C_ADDRB_WIDTH = "10" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.622 mW" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "0" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "blk_mem_gen_0.mem" *) 
  (* C_INIT_FILE_NAME = "blk_mem_gen_0.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "1024" *) 
  (* C_READ_DEPTH_B = "1024" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "32" *) 
  (* C_READ_WIDTH_B = "32" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "1024" *) 
  (* C_WRITE_DEPTH_B = "1024" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  blk_mem_gen_0_blk_mem_gen_v8_4_9 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[31:0]),
        .eccpipece(1'b0),
        .ena(1'b0),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[9:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[9:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[31:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(1'b0),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2024.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
FPXllyX2NFs/RMngGqZy2bLYbZr92CdofeZrJOHklWXExpaPgHNYp2Lzm4MnflbnrfSkCmLwwKT5
zfRgEip7FKQ5Zhb73p0MAIADixBZ/ZRt4hQkJL0T9brm0waLHfanjnov2aCX6jN3LbQc3ujmDga6
Dd73k78u4xjRTDv1/P4=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
kr7VKKvChFoiyRCReag+OvU3jnmG9pN0cv+BxhNmMKLthg/ksgNZyU3L+fQ7cmIQELtlUjwjkBAP
Jjq5RsCnHbJxj+Ys1GNhriiBsxLqxWCP8onhAVvgZN2xZFOih0UWpqlU8NVP8Eww1ohvkDgxTstC
3kDmYehxIUJjqCC/mgRZmuezqugrFdubYmBoz16tUvD17iA5qqCIMS9xSIXYp2LBNekmWEwrVqzu
R4koEo4UlXl/CEw0XY3QvMoHnlXgu6N/6sc+nxZtKSwjiMVvGnZE9UVvJPAC3Hn3zKFGlK53mmGO
Tj0dWzhwX0ahSYzkyJC/HLdbGZmriL2UNvDyFw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
CaLc9FGt3AdRHfNtGAsGFY/QEvHY1Vv4TvvgCDsdDMqiuDeLizFJDJeskBWjeKDoE2cufK8TxiBq
mySRQNJoeOKnxTiDdf+Rx6m0iR6h/YeswegYwgghpM5KVrl6mSwF3+4yEovPM7a+9ArDQ5vl+WT8
SilNGzyW0KnTwe7+szs=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
cEnudSW1X71p0Xuq6jrXOxHnBku87IA0RA3zKqmeZHZM0r+9rEm5MSzX8RecnQ994yiqeyxbIH2l
fGEzUzr0ZzryS3fkf2LnJuB39f2YARW9eVCSiaeWaraZuY1l89T+h3vgdlurS/1LIraYLS1MyOXa
6F1LAcQp3W4OO4ctc3q1FRMZGldRS1biMsKwJ8Lxj8NEOm67UfgFrJNQAxbVXEfbWRWhKtwNxcTB
JbgC8j4EHkIA46mzoHloeBAL6KieplQUBjKXSSTb66rxglbFhWLy+mirROHcocu9J4ZbvTRYZEww
4lso1lqAllVLAoKYqa3WImZuSRoTbGDngBt9Lg==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rOyI+x4PlmKcVSFoN3oKgSYpVlmYxc194Ej04il/YmBg10xopy4zmtu5sdCP/uGSNYcNGWeAiw01
mNf98KyNgTUFXruHCA38qjhhEIvl4vfWWn3W3mFRxrIuwmnreT6qTvgMaxIkCdVBDP7Iy7O6WmCf
3Va5X5hnCHhtXgX5UYniBHiLjmupv63B8XMAYDH2n6mQ3H0DF7mtb7psBafd0Z6+IWUbmzwMtKrf
ZrRJBGAhNT0i1KrEjEh/rWjN7Z7N32zQ+Pl1kc5gYCQIX5McfdTdqSaRVXZ/HF90ymS7/8d5LDyj
Er+ORdcjnOn6oAyY4PuUUl4OYUHv5k+RglTe5Q==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2023_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
bJa7kPSpDipzoJoQu1APEjc8vFLqBfQZK/grZvWijD7/FgMTerFCWLUY6n8DWeGdvjXvTeyrqCHE
2rP/H57wUqPC8tIJlGm6ZYQGjZ3TgYqLrJshDE5zYMTO//q0vuSraWvZP7A7SLuW6y7tFE/nplpx
L8gbYORx6j70okGUwnamCMS9yhFr7Z2QTJne1k4GNFGvy66URk3k5cBPl5j4/1yc4xGV+aWYl6L8
q8RorRU/CltObHKrji/jdiY1WtdGrkpRyCEFc+XNPazL9xSLLu5bz6XlvKwoks+8a5KYT/VFUovM
JbM0bpAXM8Z7rGaPuXjqXtZBg5praTZLu/WNcA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PYKBDinOGc/kIVdFzXrz2wA4/QNFxLDrQfTWfR5TjYE6bm49vrZi0bawcr9HXp4OP1+XxPLB3oCP
oV5e/rYeDln531ebt8yEg27XCoSHEX4FU8oG8aBJ8fqgWayOnAMJt025WodOxuZXbhT1zPo7J3uh
6iO9Mv7RtYE2fZ1W+G8oN//FTOEJYPWlKYnt0cDeZrN3I4rHHptZHuu7l8T+df0PYea3x6U3Mvkl
ojZ+TwQtdu0NuYY5j3QNgx3+W2XYq1M773FAnEz/deW54EjE+jf1jjrBk2pl8SYxeKuutS15oPVF
eHdqXYVcJxoUY5JH8z04lITKEnZ4oq6sYS6dog==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
tl+2vFCWZ583gQGsVC7oopz2NCKBiJ9uOHYBGzJZheOHJMqI/ehNvo25l710eBx00tztXzM30AH6
ZhAJg+kJwE2jO0MV5fmG5dnwXmLqoGEJMBs7xwWxvYK7w/0z9M0AJKD7HnuC+IiLhNU/fIxyuE+I
+vWqp//RcfY0tMMp2I2J1yEW6GUahS1ve/4JchssZ7Xu7VthoSDWXMQWATbvsUsDzeSo2+Ruz8Kq
Dc05HqEU8NgBxDPPEKLCcdKLp4byglwj7iCAtCjsPy8P18qjgb2sycFjNgmaiNMMB51WqeD+hneG
hLOue9bqVdEojkrb3q4WbsGZKz0bAGsryxslOlYHP1b8vey3yI2ixA80wyERe8d3GRIeZiSxGykH
qWxsE6x/iyi8QRb5mXZPMApA+Fln8tYmn7+1rFCm8gF4gJWhr1PsSJqTi658symGrzT0Ghjvf2QL
SvvoaeNdy0pOsWs7jLBFndd4GiFA+9K6Y33sziLToU9EvvFokENIslod

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
oYiCujFRj1F3wKsGZlHR9niEtR9MLXEVAVfy+f/3xrmpW6Ye5a+fBCvm4TH+iRQefGHNdMPnzTNW
K/pEPAS9uMJjOdFiu+APT+LYrSRnEg4W0dX5buSDGM6LBWAuMseoTMjbJJoYDGLRckJgW43E30mX
ej4823nkbfwc+Ecbrup825qLyv8RTQLNHafvJA5lSapdqXwnlOIYRmcHn+sfAh5pGv9kW9aokcdh
ObR2XYxX99rYloyvz3x0pmjxD5ILW4SQMB1IUEuuyqX6eb5IQ+kZ41hjvsHIuQH29vzpCfV9Jqha
WC5yxxK1R+cleZSKD1H1gVzbTei8uFs/91Bgeg==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
urNc+S8AFPj+GVFdqJE5V7P8O6QI6MA3nkwYb8NKbYbVufnXKg6voJIRYYeYr7EOa8mrqirozWbY
Lln9SLWnkaAy2LvL/N6WahoQdCt++4RH+xe768XvSrVUFPrIwZRixqMLurc/tPov4i5P/ukZKl18
ZPZvXRzUNlvCZnMPcF+5QCQihqPbjcZ0YyGgWgX/ipTGG3sNqmylGN7qLa4Rgqu/mB5a2xVyu5Wc
911+/X3VVFx697WVaP5V0SbOzYN8R8+8B8kdznwixMA+f4lSbBXyRysVOSzYjo8bKEMqyKMVBQn9
xDmEuV0DvVWXdO7VPvWA1LuJFwS07OxeI2GCcQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QcP7fsLZxaDrG29e9HQeXfu2TsKsdyW7Yc1vWct6lbmDEfXkWMU1fFWSPIjPzRc9UOnfEu0bRn+B
D+8MWokqes3WF7txljBmgUPiNGZ8arUU6ENa/IY/Wv7iaB/ZKM5PtdnFAkjDIrYyKFCTz/U6Yzwi
hBGGarK/wYQOLzeeKRewiPTiNUL7tztWuMZ1t1msxD951EeKrwjrjcXIIuf/TzrOGUOlWgjHlnrl
4Q/lfMAnRLBNTSWG+5wWewCE8jK2X/gJ5AV4p3x1WP3+JglbxpP39l3pzedXqciZPbuz2XlFnRPV
KByaUaAShzJ56p8+0HjWebibqQdieGNPiPWW0Q==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 26848)
`pragma protect data_block
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
EQ==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
